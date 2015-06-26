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

@interface VBulkDownloadOperation ()

@property (nonatomic, readonly) NSMutableSet *waitingToDownload;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSArray *operations;
@property (nonatomic, readonly) dispatch_queue_t privateQueue;

@end

@implementation VBulkDownloadOperation

- (instancetype)initWithURLs:(NSSet *)urls completion:(VDownloadOperationCompletion)completionBlock
{
    self = [super init];
    if ( self != nil )
    {
        _shouldRetry = NO;
        _urls = [urls copy];
        _waitingToDownload = [urls mutableCopy];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = kMaxConcurrentDownloads;
        _privateQueue = dispatch_queue_create("VBulkDownloader", DISPATCH_QUEUE_SERIAL);
        
        // Instantiate all the operations here, rather than in -main, to allow calling
        // code to use NSProgress to track the download progress.
        NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:urls.count];
        for (NSURL *url in urls)
        {
            VDownloadOperation *downloadOperation = [[VDownloadOperation alloc] initWithURL:url
                                                                                 completion:completionBlock];
            [operations addObject:downloadOperation];
        }
        _operations = operations;
    }
    return self;
}

- (void)main
{
    [self.operationQueue addOperations:self.operations waitUntilFinished:YES];
}

- (void)cancel
{
    [self.operationQueue cancelAllOperations];
    [super cancel];
}

@end
