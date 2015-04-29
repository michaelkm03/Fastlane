//
//  VTemplateDownloadManager.m
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VTemplateDownloadManager.h"
#import "VTemplateSerialization.h"

@interface VTemplateDownloadManager ()

@property (nonatomic, strong) dispatch_queue_t privateQueue;
@property (nonatomic, strong) NSUUID *currentDownloadID;
@property (nonatomic) NSTimeInterval retryInterval;
@property (nonatomic, copy) VTemplateLoadCompletion completion;

@end

static const NSTimeInterval kDefaultTimeout = 5.0;

@implementation VTemplateDownloadManager

- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader
{
    NSParameterAssert(downloader != nil);
    self = [super init];
    if ( self != nil )
    {
        _privateQueue = dispatch_queue_create("com.getvictorious.VTemplateDownloadManager", DISPATCH_QUEUE_SERIAL);
        _downloader = downloader;
        _timeout = kDefaultTimeout;
    }
    return self;
}

- (void)loadTemplateWithCompletion:(VTemplateLoadCompletion)completion
{
    NSParameterAssert(self.downloader != nil);
    dispatch_async(self.privateQueue, ^(void)
    {
        self.completion = completion;
        self.retryInterval = self.timeout;
        
        __weak typeof(self) weakSelf = self;
        NSUUID *downloadID = [[NSUUID alloc] init];
        self.currentDownloadID = downloadID;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)),
                       self.privateQueue,
                       ^(void)
        {
            typeof(weakSelf) strongSelf = weakSelf;
            if ( strongSelf != nil )
            {
                if ( [downloadID isEqual:strongSelf.currentDownloadID] )
                {
                    [strongSelf downloadTimerExpired];
                }
            }
        });
        
        [self.downloader downloadTemplateWithCompletion:^(NSData *templateData, NSError *error)
        {
            if ( error != nil )
            {
                [weakSelf downloadDidFinishWithData:nil];
            }
            else
            {
                [weakSelf downloadDidFinishWithData:templateData];
            }
        }];
    });
}

- (void)downloadTimerExpired
{
    [self loadTemplateFromCache];
}

- (void)downloadDidFinishWithData:(NSData *)data
{
    dispatch_async(self.privateQueue, ^(void)
    {
        self.currentDownloadID = nil;
        
        NSDictionary *configuration = nil;
        if ( data != nil )
        {
            configuration = [VTemplateSerialization templateConfigurationDictionaryWithData:data];
        }
        if ( configuration == nil )
        {
            if ( self.completion != nil )
            {
                [self loadTemplateFromCache];
            }
            [self retryTemplateDownload];
            return;
        }
        else
        {
            [self saveTemplateToCache:data];
            [self executeCallbackWithTemplateConfiguration:configuration];
        }
    });
}

- (void)saveTemplateToCache:(NSData *)templateData
{
    if ( self.templateCacheFileLocation != nil )
    {
        [templateData writeToURL:self.templateCacheFileLocation atomically:YES];
    }
}

- (void)loadTemplateFromCache
{
    NSData *templateData = [NSData dataWithContentsOfURL:self.templateCacheFileLocation];
    if ( templateData == nil )
    {
        [self loadTemplateFromBundle];
        return;
    }
    
    NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    [self executeCallbackWithTemplateConfiguration:template];
}

- (void)loadTemplateFromBundle
{
    NSData *templateData = [NSData dataWithContentsOfURL:self.templateLocationInBundle];
    if ( templateData != nil )
    {
        NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
        [self executeCallbackWithTemplateConfiguration:template];
    }
}

- (void)executeCallbackWithTemplateConfiguration:(NSDictionary *)configuration
{
    if ( self.completion != nil )
    {
        self.completion(configuration);
        self.completion = nil;
    }
}

- (void)retryTemplateDownload
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), self.privateQueue, ^(void)
    {
        typeof(self) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            strongSelf.retryInterval *= 2.0;
            [strongSelf.downloader downloadTemplateWithCompletion:^(NSData *templateData, NSError *error)
            {
                [weakSelf downloadDidFinishWithData:templateData];
            }];
        }
    });
}

@end
