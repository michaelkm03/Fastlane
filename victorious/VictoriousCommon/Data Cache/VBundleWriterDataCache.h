//
//  VBundleWriterDataCache.h
//  victorious
//
//  Created by Josh Hinman on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDataCache.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A special subclass of VDataCache that directs all writes
 to an application bundle instead of a caches directory.
 */
@interface VBundleWriterDataCache : VDataCache

@property (nonatomic, readonly) NSURL *bundleURL; ///< The location to which cached data will be written

/**
 Initializes a new instance of VBundleWriterDataCache with 
 the specified file URL, pointing to an application bundle
 */
- (instancetype)initWithBundleURL:(NSURL *)bundleURL;

@end

NS_ASSUME_NONNULL_END
