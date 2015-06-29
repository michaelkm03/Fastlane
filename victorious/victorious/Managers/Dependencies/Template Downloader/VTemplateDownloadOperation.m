//
//  VTemplateDownloadOperation.m
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VTemplateDownloadOperation.h"
#import "VTemplateSerialization.h"
#import "VEnvironmentManager.h"
#import "VSessionTimer.h"

@interface VTemplateDownloadOperation ()

@property (nonatomic, strong) dispatch_queue_t privateQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSUUID *currentDownloadID;
@property (nonatomic) NSTimeInterval retryInterval;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic) BOOL delegateNotified;

@end

static const NSTimeInterval kDefaultTimeout = 5.0;

@implementation VTemplateDownloadOperation

- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader andDelegate:(id<VTemplateDownloadOperationDelegate>)delegate
{
    NSParameterAssert(downloader != nil);
    self = [super init];
    if ( self != nil )
    {
        _privateQueue = dispatch_queue_create("com.getvictorious.VTemplateDownloadManager", DISPATCH_QUEUE_SERIAL);
        _semaphore = dispatch_semaphore_create(0);
        _delegate = delegate;
        _delegateNotified = NO;
        _downloader = downloader;
        _timeout = kDefaultTimeout;
        _shouldRetry = YES;
        _progress = [NSProgress progressWithTotalUnitCount:1];
    }
    return self;
}

- (void)main
{
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
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
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
            if ( self.delegate != nil )
            {
                [self loadTemplateFromCache];
            }
            [self retryTemplateDownload];
            return;
        }
        else
        {
            [self saveTemplateToCache:data];
            [self notifyDelegateWithTemplateConfiguration:configuration];
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
    [self notifyDelegateWithTemplateConfiguration:template];
}

- (void)loadTemplateFromBundle
{
    NSData *templateData = [NSData dataWithContentsOfURL:self.templateLocationInBundle];
    if ( templateData != nil )
    {
        NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
        [self notifyDelegateWithTemplateConfiguration:template];
    }
}

- (void)notifyDelegateWithTemplateConfiguration:(NSDictionary *)configuration
{
    if ( self.delegateNotified )
    {
        return;
    }
    [self.delegate templateDownloadOperation:self didFinishLoadingTemplateConfiguration:configuration];
    self.delegateNotified = YES;
    dispatch_semaphore_signal(self.semaphore);
}

- (void)retryTemplateDownload
{
    if ( !self.shouldRetry )
    {
        [self notifyDelegateWithTemplateConfiguration:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), self.privateQueue, ^(void)
    {
        typeof(self) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            strongSelf.retryInterval *= 2.0;
            [strongSelf.downloader downloadTemplateWithCompletion:^(NSData *templateData, NSError *error)
             {
                 // `downloadDidFinishWithData` will fail with nil data, so don't worry about checking it here
                 [weakSelf downloadDidFinishWithData:templateData];
                 
                 // If a retry failed and we're using a user environment, then we should switch back to the default
                 VEnvironment *currentEnvironment = [[VEnvironmentManager sharedInstance] currentEnvironment];
                 const BOOL shouldRevertToPreviousEnvironment = currentEnvironment.isUserEnvironment && templateData == nil;
                 if ( shouldRevertToPreviousEnvironment )
                 {
                     [[VEnvironmentManager sharedInstance] revertToPreviousEnvironment];
                     NSDictionary *userInfo = @{ VEnvironmentErrorKey : error };
                     [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart
                                                                         object:weakSelf
                                                                       userInfo:userInfo];
                 }
                     
            }];
        }
    });
}

@end
