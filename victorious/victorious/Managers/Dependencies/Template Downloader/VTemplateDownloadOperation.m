//
//  VTemplateDownloadOperation.m
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VDataCacheID.h"
#import "VConstants.h"
#import "VDataCache.h"
#import "VBulkDownloadOperation.h"
#import "VRunBlockOperation.h"
#import "VTemplateDownloadOperation.h"
#import "VTemplatePackageManager.h"
#import "VTemplateSerialization.h"
#import "VEnvironmentManager.h"
#import "VSessionTimer.h"

@interface VTemplateDownloadOperation ()

@property (nonatomic, strong) dispatch_queue_t privateQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSUUID *currentDownloadID;
@property (nonatomic) NSTimeInterval retryInterval;
@property (nonatomic) BOOL delegateNotified;
@property (nonatomic) BOOL templateDownloaded;
@property (nonatomic, strong) VBulkDownloadOperation *bulkDownloadOperation;
@property (nonatomic, strong) VRunBlockOperation *saveTemplateOperation;

@end

static const NSTimeInterval kDefaultTemplateDownloadTimeout = 5.0;
static const NSTimeInterval kDefaultImageDownloadTimeout = 15.0;

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
        _templateDownloaded = NO;
        _downloader = downloader;
        _templateDownloadTimeout = kDefaultTemplateDownloadTimeout;
        _imageDownloadTimeout = kDefaultImageDownloadTimeout;
        _shouldRetry = YES;
    }
    return self;
}

- (void)main
{
    NSParameterAssert(self.templateConfigurationCacheID != nil);
    self.retryInterval = self.templateDownloadTimeout;
    
    __weak typeof(self) weakSelf = self;
    NSUUID *downloadID = [[NSUUID alloc] init];
    self.currentDownloadID = downloadID;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.templateDownloadTimeout * NSEC_PER_SEC)),
                   self.privateQueue,
                   ^(void)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            if ( !strongSelf.isCancelled &&
                 !strongSelf.templateDownloaded &&
                 [downloadID isEqual:strongSelf.currentDownloadID] )
            {
                [strongSelf downloadTimerExpired];
            }
        }
    });
    
    [self.downloader downloadTemplateWithCompletion:^(NSData *templateData, NSError *error)
    {
        if ( weakSelf.isCancelled )
        {
            return;
        }
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

- (void)cancel
{
    [super cancel];
    [self.saveTemplateOperation cancel];
    [self.bulkDownloadOperation cancel];
    dispatch_semaphore_signal(self.semaphore);
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
            __weak typeof(self) weakSelf = self;
            void (^saveTemplateToDiskAndNotifyDelegate)() = ^(void)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    dispatch_async(strongSelf.privateQueue, ^(void)
                    {
                        if ( !strongSelf.isCancelled )
                        {
                            [strongSelf.dataCache cacheData:data forID:strongSelf.templateConfigurationCacheID error:nil];
                            [strongSelf notifyDelegateWithTemplateConfiguration:configuration];
                        }
                    });
                }
            };
            
            NSSet *missingURLs = [self missingReferencedURLsFromTemplate:configuration];
            if ( missingURLs.count == 0 )
            {
                saveTemplateToDiskAndNotifyDelegate();
                return;
            }
            
            [self startTimerForImageDownloads];
            
            self.bulkDownloadOperation = [[VBulkDownloadOperation alloc] initWithURLs:missingURLs completion:[self downloadOperationCompletion]];
            self.bulkDownloadOperation.shouldRetry = self.shouldRetry;
            
            self.saveTemplateOperation = [[VRunBlockOperation alloc] init];
            self.saveTemplateOperation.block = saveTemplateToDiskAndNotifyDelegate;
            self.saveTemplateOperation.queue = self.privateQueue;
            [self.saveTemplateOperation addDependency:self.bulkDownloadOperation];
            
            [self.delegate templateDownloadOperation:self needsAnOperationAddedToTheQueue:self.bulkDownloadOperation];
            [self.delegate templateDownloadOperation:self needsAnOperationAddedToTheQueue:self.saveTemplateOperation];
        }
    });
}

- (VDownloadOperationCompletion)downloadOperationCompletion
{
    __weak typeof(self) weakSelf = self;
    return ^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            if ( error != nil ||
                ![strongSelf.dataCache cacheDataAtURL:downloadedFile forID:originalURL error:nil] )
            {
                [strongSelf.saveTemplateOperation cancel];
                typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil && !strongSelf.isCancelled )
                {
                    dispatch_async(strongSelf.privateQueue, ^(void)
                    {
                        [strongSelf loadTemplateFromCache];
                    });
                }
            }
        }
    };
}

- (void)startTimerForImageDownloads
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.imageDownloadTimeout * NSEC_PER_SEC)),
                   self.privateQueue,
                   ^(void)
    {
        typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            if ( !strongSelf.isCancelled )
            {
                [strongSelf downloadTimerExpired];
            }
        }
    });
}

- (BOOL)loadTemplateFromCache
{
    NSData *templateData = [self.dataCache cachedDataForID:self.templateConfigurationCacheID];
    if ( templateData == nil )
    {
        return NO;
    }
    
    NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    NSSet *missingURLs = [self missingReferencedURLsFromTemplate:template];
    
    if ( missingURLs.count == 0 )
    {
        [self notifyDelegateWithTemplateConfiguration:template];
        return YES;
    }
    return NO;
}

- (NSSet *)missingReferencedURLsFromTemplate:(NSDictionary *)template
{
    VTemplatePackageManager *packageManager = [[VTemplatePackageManager alloc] initWithTemplateJSON:template];
    NSSet *urls = [packageManager referencedURLs];
    return [self.dataCache setOfIDsWithoutCachedDataFromIDSet:urls];
}

- (void)notifyDelegateWithTemplateConfiguration:(NSDictionary *)configuration
{
    if ( !self.delegateNotified )
    {
        [self.delegate templateDownloadOperation:self didFinishLoadingTemplateConfiguration:configuration];
        self.delegateNotified = YES;
    }
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
        __strong typeof(self) strongSelf = weakSelf;
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
