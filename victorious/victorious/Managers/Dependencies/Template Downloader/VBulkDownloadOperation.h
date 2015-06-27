//
//  VBulkDownloadOperation.h
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDownloadOperation.h"

#import <Foundation/Foundation.h>

@class VDataCache;

/**
 Manages multiple simultaneous VDownloadOperation objects with an
 internal operation queue. Can be configured to retry failed
 downloads.
 */
@interface VBulkDownloadOperation : NSOperation

@property (nonatomic, readonly) NSSet *urls; ///< The URLs being downloaded
@property (nonatomic, readonly) NSProgress *progress; ///< Use this property to monitor the file download progress

/**
 If YES, failed downloads will be retried.
 If NO, the completion block will be called for failed downloads.
 Default is NO.
 */
@property (nonatomic) BOOL shouldRetry;

/**
 The time interval between the first and second download attempts.
 This interval will be progressively increased for each retry
 attempt to avoid overwhelming the server.
 */
@property (nonatomic) NSTimeInterval retryInterval;

/**
 Initializes a new instance of VBulkDownloader with the given urls and completion block.
 
 @param urls An NSSet of NSURL objects
 @param completionBlock Will be called once for each URL.
 */
- (instancetype)initWithURLs:(NSSet *)urls completion:(VDownloadOperationCompletion)completionBlock NS_DESIGNATED_INITIALIZER;

@end
