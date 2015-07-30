//
//  VBulkDownloadOperation.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "NSURL+VDataCacheID.h"
#import "VBulkDownloadOperation.h"
#import "VDataCache.h"
#import "VDownloadOperation.h"

static const NSInteger kMaxConcurrentDownloads = 3;
static const NSTimeInterval kDefaultRetryInterval = 2.0;

@interface VBulkDownloadOperation ()

@property (nonatomic, readonly) NSMutableSet *waitingToDownload;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) dispatch_queue_t privateQueue;
@property (nonatomic, copy) VDownloadOperationCompletion completion;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation VBulkDownloadOperation

- (instancetype)initWithURLs:(NSSet *)urls completion:(VDownloadOperationCompletion)completionBlock
{
    self = [super init];
    if ( self != nil )
    {
        _shouldRetry = NO;
        _retryInterval = kDefaultRetryInterval;
        _urls = [urls copy];
        _completion = [completionBlock copy];
        _waitingToDownload = [urls mutableCopy];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = kMaxConcurrentDownloads;
        _privateQueue = dispatch_queue_create("VBulkDownloader", DISPATCH_QUEUE_SERIAL);
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)main
{
    NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:self.urls.count];
    for (NSURL *url in self.urls)
    {
        [operations addObject:[self downloadOperationForURL:url retryInterval:self.retryInterval]];
    }
    [self.operationQueue addOperations:operations waitUntilFinished:NO];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

- (void)cancel
{
    [super cancel];
    [self.operationQueue cancelAllOperations];
    dispatch_semaphore_signal(self.semaphore);
}

- (VDownloadOperation *)downloadOperationForURL:(NSURL *)url retryInterval:(NSTimeInterval)retryInterval
{
    __weak typeof(self) weakSelf = self;
    VDownloadOperation *downloadOperation = [[VDownloadOperation alloc] initWithURL:url
                                                                         completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( strongSelf == nil || strongSelf.isCancelled )
        {
            return;
        }
        
        if ( strongSelf.completion != nil )
        {
            strongSelf.completion(originalURL, error, response, downloadedFile);
        }
        
        if ( [strongSelf shouldRetryWithError:error] )
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^(void)
            {
                if ( strongSelf.isCancelled )
                {
                    return;
                }
                NSTimeInterval doubledInterval = retryInterval * 2;
                VDownloadOperation *operation = [strongSelf downloadOperationForURL:url retryInterval:doubledInterval];
                [strongSelf.operationQueue addOperation:operation];
            });
            return;
        }
        
        dispatch_async(strongSelf.privateQueue, ^(void)
        {
            [strongSelf.waitingToDownload removeObject:originalURL];
            if ( strongSelf.waitingToDownload.count == 0 )
            {
                dispatch_semaphore_signal(strongSelf.semaphore);
            }
        });
    }];
    downloadOperation.retryInterval = retryInterval;
    return downloadOperation;
}

- (BOOL)shouldRetryWithError:(NSError *)error
{
    if ( error == nil || !self.shouldRetry || ![error.domain isEqualToString:NSURLErrorDomain] )
    {
        return NO;
    }
    return [[[self class] setOfRecoverableErrorCodes] containsObject:@(error.code)];
}

+ (NSSet *)setOfRecoverableErrorCodes
{
    static NSSet *recoverableErrorCodes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        recoverableErrorCodes = [NSSet setWithObjects:@(NSURLErrorCancelled), @(NSURLErrorTimedOut), @(NSURLErrorCannotFindHost), @(NSURLErrorCannotConnectToHost),
                                 @(NSURLErrorNetworkConnectionLost), @(NSURLErrorDNSLookupFailed), @(NSURLErrorNotConnectedToInternet), @(NSURLErrorInternationalRoamingOff),
                                 @(NSURLErrorCallIsActive), @(NSURLErrorDataNotAllowed), @(NSURLErrorCannotLoadFromNetwork), nil];
    });
    return recoverableErrorCodes;
}

@end