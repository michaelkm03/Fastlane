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
#import "VTemplateDownloadOperation.h"
#import "VTemplatePackageManager.h"
#import "VTemplateSerialization.h"
#import "VEnvironmentManager.h"
#import "VSessionTimer.h"

#import <VictoriousCommon/VictoriousCommon-Swift.h>

@interface VTemplateDownloadOperation ()

@property (nonatomic, strong) NSOperationQueue *currentQueue;
@property (nonatomic, strong) dispatch_queue_t privateQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic) NSTimeInterval retryInterval;
@property (nonatomic) BOOL cacheUsed;
@property (nonatomic) BOOL templateDownloaded;
@property (nonatomic, strong, readwrite) NSDictionary *templateConfiguration;
@property (nonatomic, strong) VBulkDownloadOperation *bulkDownloadOperation;
@property (nonatomic, strong) NSBlockOperation *saveTemplateOperation;

@end

static const NSTimeInterval kDefaultTemplateDownloadTimeout = 5.0;
static const NSTimeInterval kDefaultImageDownloadTimeout = 15.0;
static NSString * const kTemplateBuildNumberKey = @"com.victorious.currentBuildNumber";

static char kPrivateQueueSpecific;

@implementation VTemplateDownloadOperation

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader
{
    NSParameterAssert(downloader != nil);
    self = [super init];
    if ( self != nil )
    {
        _privateQueue = dispatch_queue_create("com.getvictorious.VTemplateDownloadManager", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_privateQueue, &kPrivateQueueSpecific, &kPrivateQueueSpecific, NULL);
        _semaphore = dispatch_semaphore_create(0);
        _cacheUsed = NO;
        _templateDownloaded = NO;
        _completedSuccessfully = NO;
        _downloader = downloader;
        _dataCache = [[VDataCache alloc] init];
        _templateDownloadTimeout = kDefaultTemplateDownloadTimeout;
        _imageDownloadTimeout = kDefaultImageDownloadTimeout;
        _shouldRetry = YES;
    }
    return self;
}

- (void)main
{
    self.retryInterval = self.templateDownloadTimeout;
    self.currentQueue = [NSOperationQueue currentQueue];
    NSAssert(self.currentQueue != nil, @"Can't get a current queue. Are you trying to run this operation outside of an NSOperationQueue?");
    
    __weak typeof(self) weakSelf = self;
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

- (NSDictionary *)templateConfiguration
{
    if ( dispatch_get_specific(&kPrivateQueueSpecific) )
    {
        return _templateConfiguration;
    }
    
    __block NSDictionary *templateConfiguration;
    dispatch_sync(self.privateQueue, ^(void)
    {
        templateConfiguration = _templateConfiguration;
    });
    return templateConfiguration;
}

- (void)downloadDidFinishWithData:(NSData *)data
{
    dispatch_async(self.privateQueue, ^(void)
    {
        NSDictionary *configuration = nil;
        if ( data != nil )
        {
            configuration = [VTemplateSerialization templateConfigurationDictionaryWithData:data];
        }
        if ( configuration == nil )
        {
            [self retryTemplateDownload];
            return;
        }
        else
        {
            self.templateConfiguration = configuration;
            
            __weak typeof(self) weakSelf = self;
            void (^saveTemplateToDisk)() = ^(void)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    if ( strongSelf.templateCache != nil && !strongSelf.isCancelled )
                    {
                        [strongSelf.templateCache cacheTemplateData:data error:nil];
                        self.completedSuccessfully = YES;
                    }
                }
            };
            
            void (^signal)() = ^(void)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    dispatch_semaphore_signal(strongSelf.semaphore);
                }
            };
            
            NSSet *missingURLs = [self missingReferencedURLsFromTemplate:configuration];
            if ( missingURLs.count == 0 )
            {
                saveTemplateToDisk();
                signal();
                return;
            }
            
            self.bulkDownloadOperation = [[VBulkDownloadOperation alloc] initWithURLs:missingURLs completion:[self downloadOperationCompletion]];
            self.bulkDownloadOperation.shouldRetry = self.shouldRetry;
            
            self.saveTemplateOperation = [NSBlockOperation blockOperationWithBlock:^(void)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    dispatch_sync(strongSelf.privateQueue, saveTemplateToDisk);
                }
            }];
            [self.saveTemplateOperation addDependency:self.bulkDownloadOperation];
            
            NSOperation *signalOperation = [NSBlockOperation blockOperationWithBlock:signal];
            [signalOperation addDependency:self.bulkDownloadOperation];
            [signalOperation addDependency:self.saveTemplateOperation];
            
            [self.currentQueue addOperation:self.bulkDownloadOperation];
            [self.currentQueue addOperation:self.saveTemplateOperation];
            [self.currentQueue addOperation:signalOperation];
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
            }
        }
    };
}

- (NSSet *)missingReferencedURLsFromTemplate:(NSDictionary *)template
{
    VTemplatePackageManager *packageManager = [[VTemplatePackageManager alloc] initWithTemplateJSON:template];
    NSSet *urls = [packageManager referencedURLs];
    return [self.dataCache setOfIDsWithoutCachedDataFromIDSet:urls];
}

- (void)retryTemplateDownload
{
    if ( !self.shouldRetry )
    {
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), self.privateQueue, ^(void)
    {
        __strong typeof(self) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            if ( self.cancelled )
            {
                return;
            }
            strongSelf.retryInterval *= 2.0;
            [strongSelf.downloader downloadTemplateWithCompletion:^(NSData *templateData, NSError *error)
            {
                // `downloadDidFinishWithData` will fail with nil data, so don't worry about checking it here
                [weakSelf downloadDidFinishWithData:templateData];
            }];
        }
    });
}

@end
