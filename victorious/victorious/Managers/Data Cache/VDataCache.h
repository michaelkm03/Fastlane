//
//  VDataCache.h
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 When cached items are included in the application bundle,
 the filename should be the cache ID with this constant
 for an extension.
 */
extern NSString * const VDataCacheBundleResourceExtension;

@protocol VDataCacheID <NSObject>

@required

/**
 Returns a unique identifier that will be used to index
 this object when stored on disk with VDataCache
 */
- (NSString *)identifierForDataCache;

@end

/**
 Saves data to a cache on desk and loads previously cached data.
 */
@interface VDataCache : NSObject

/**
 A local file URL that points to a directory where data should be cached.
 When loading cached data, if none is found in this location, the
 application bundle will be searched as well.
 
 This is here for unit testing purposes--there is a good default that 
 will be used if this is not set.
 */
@property (nonatomic, copy) NSURL *localCachePath;

/**
 Saves the given data to the cache and associates it with the given ID.
 If other data has previously been cached with this ID, it will be
 overwritten.
 */
- (BOOL)cacheData:(NSData *)data forID:(id<VDataCacheID>)identifier error:(NSError **)error;

/**
 Retrieves data previously cached with the given ID.
 
 @return the data previously cached, or nil if none could be found.
 */
- (NSData *)cachedDataForID:(id<VDataCacheID>)identifier;

/**
 Returns YES if we've already cached data with the specified ID.
 */
- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier;

@end
