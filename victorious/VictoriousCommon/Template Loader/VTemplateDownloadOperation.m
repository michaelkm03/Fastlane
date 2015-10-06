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

@interface VTemplateDownloadOperation ()

@property (nonatomic, strong) NSOperationQueue *currentQueue;
@property (nonatomic, strong) dispatch_queue_t privateQueue;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSUUID *currentDownloadID;
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

- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader andDelegate:(id<VTemplateDownloadOperationDelegate>)delegate
{
    NSParameterAssert(downloader != nil);
    self = [super init];
    if ( self != nil )
    {
        _privateQueue = dispatch_queue_create("com.getvictorious.VTemplateDownloadManager", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_privateQueue, &kPrivateQueueSpecific, &kPrivateQueueSpecific, NULL);
        _semaphore = dispatch_semaphore_create(0);
        _delegate = delegate;
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
            self.templateConfiguration = configuration;
            
            __weak typeof(self) weakSelf = self;
            void (^saveTemplateToDisk)() = ^(void)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    id<VDataCacheID> templateConfigurationCacheID = strongSelf.templateConfigurationCacheID;
                    if ( templateConfigurationCacheID != nil && !strongSelf.isCancelled )
                    {
                        [strongSelf.dataCache cacheData:data forID:templateConfigurationCacheID error:nil];
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
            
            [self startTimerForImageDownloads];
            
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
                if ( !strongSelf.isCancelled )
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

- (void)loadTemplateFromCache
{
    if ( self.cacheUsed )
    {
        return;
    }
    
    [self updateCachedTemplate];
    
    NSData *templateData = [self.dataCache cachedDataForID:self.templateConfigurationCacheID];
    if ( templateData == nil )
    {
        if ( [self.delegate respondsToSelector:@selector(templateDownloadOperationFailedWithNoFallback:)] )
        {
            [self.delegate templateDownloadOperationFailedWithNoFallback:self];
        }
        return;
    }
    
    NSDictionary *template = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    if ( template != nil )
    {
        self.templateConfiguration = template;
        if ( [self.delegate respondsToSelector:@selector(templateDownloadOperationDidFallbackOnCache:)] )
        {
            [self.delegate templateDownloadOperationDidFallbackOnCache:self];
        }
        self.cacheUsed = YES;
    }
}

- (void)updateCachedTemplate
{
    NSAssert(self.buildNumber != nil, @"VTemplateDownloadOperation should have build number set before loading the template");
    if ( self.buildNumber == nil )
    {
        return;
    }
    
    NSString *oldBuildNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTemplateBuildNumberKey];
    if ( oldBuildNumber == nil || ![self.buildNumber isEqualToString:oldBuildNumber] )
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.buildNumber forKey:kTemplateBuildNumberKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.dataCache removeCachedDataForId:self.templateConfigurationCacheID error:nil];
    }
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
