//
//  VBulkDownloader.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "NSURL+VDataCacheID.h"
#import "VBulkDownloader.h"
#import "VDataCache.h"
#import "VDownloadOperation.h"

static const NSInteger kMaxConcurrentDownloads = 3;

@interface VBulkDownloader ()

@property (nonatomic, readonly) NSMutableSet *waitingToDownload;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) NSArray *operations;
@property (nonatomic, readonly) dispatch_queue_t privateQueue;

@end

@implementation VBulkDownloader

- (instancetype)initWithURLs:(NSSet *)urls completion:(VBulkDownloadCompletion)completionBlock
{
    self = [super init];
    if ( self != nil )
    {
        _urls = [urls copy];
        _waitingToDownload = [urls mutableCopy];
        _dataCache = [[VDataCache alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = kMaxConcurrentDownloads;
        _privateQueue = dispatch_queue_create("VBulkDownloader", DISPATCH_QUEUE_SERIAL);
        
        // Instantiate all the operations here, rather than in -main, to allow calling
        // code to use NSProgress to track the download progress.
        NSMutableArray *operations = [[NSMutableArray alloc] initWithCapacity:urls.count];
        for (NSURL *url in urls)
        {
            __weak typeof(self) weakSelf = self;
            VDownloadOperation *downloadOperation = [[VDownloadOperation alloc] initWithURL:url
                                                                                 completion:^(NSError *error, NSURLResponse *response, NSURL *downloadedFile)
            {
                typeof(weakSelf) strongSelf = weakSelf;
                if ( strongSelf != nil )
                {
                    [strongSelf.dataCache cacheDataAtURL:downloadedFile forID:url error:nil];
                    dispatch_sync(strongSelf.privateQueue, ^(void)
                    {
                        [strongSelf.waitingToDownload removeObject:url];
                        
                        if ( strongSelf.waitingToDownload.count == 0 )
                        {
                            if (completionBlock)
                            {
                                completionBlock();
                            }
                        }
                    });
                }
            }];
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
