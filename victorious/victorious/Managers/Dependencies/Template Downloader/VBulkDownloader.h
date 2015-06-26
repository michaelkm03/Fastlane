//
//  VBulkDownloader.h
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDataCache;

/**
 This block is called when all the URLs have 
 successfully downloaded. No need for a bool
 to indicate success, or an error property,
 because this class just keeps retrying 
 until it's successful!
 */
typedef void (^VBulkDownloadCompletion)(void);

/**
 Downloads a set of URLs into a data cache. Does
 not give up until they're all downloaded.
 */
@interface VBulkDownloader : NSOperation

@property (nonatomic, readonly) NSSet *urls; ///< The URLs being downloaded

/**
 The data cache to save to. This is here for unit
 testing purposes--there is a good default that
 will be used if this is not set.
 */
@property (nonatomic, strong) VDataCache *dataCache;

/**
 Initializes a new instance of VBulkDownloader with the given urls and completion block.
 
 @param urls An NSSet of NSURL objects
 */
- (instancetype)initWithURLs:(NSSet *)urls completion:(VBulkDownloadCompletion)completionBlock NS_DESIGNATED_INITIALIZER;

@end
