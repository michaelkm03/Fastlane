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
@property (nonatomic, copy) VTemplateLoadCompletion completion;

@end

@implementation VTemplateDownloadManager

- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader
{
    NSParameterAssert(downloader != nil);
    self = [super init];
    if ( self != nil )
    {
        _privateQueue = dispatch_queue_create("com.getvictorious.VTemplateDownloadManager", DISPATCH_QUEUE_SERIAL);
        _downloader = downloader;
    }
    return self;
}

- (void)loadTemplateWithCompletion:(VTemplateLoadCompletion)completion
{
    NSParameterAssert(self.downloader != nil);
    dispatch_async(self.privateQueue, ^(void)
    {
        self.completion = completion;
        
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
        
        [self.downloader downloadTemplateWithCompletion:^(NSDictionary *templateConfiguration, NSError *error)
        {
            [weakSelf downloadDidFinishWithConfiguration:templateConfiguration];
        }];
    });
}

- (void)downloadTimerExpired
{
    [self loadTemplateFromCache];
}

- (void)downloadDidFinishWithConfiguration:(NSDictionary *)configuration
{
    dispatch_async(self.privateQueue, ^(void)
    {
        self.currentDownloadID = nil;
        if ( configuration == nil )
        {
            [self loadTemplateFromCache];
        }
        [self executeCallbackWithTemplateConfiguration:configuration];
    });
}

- (void)loadTemplateFromCache
{
    NSData *templateData = [NSData dataWithContentsOfURL:self.templateCacheFileLocation];
    if ( templateData == nil )
    {
        [self loadtemplateFromBundle];
        return;
    }
    
    NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    [self executeCallbackWithTemplateConfiguration:template];
}

- (void)loadtemplateFromBundle
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

@end
