//
//  VDataCache.h
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 When cached items are included in the application bundle,
 the filename should be the cache ID with this constant
 for an extension.
 */
extern NSString * const VDataCacheBundleResourceExtension;

/**
 Objects conforming to this protocol can
 be used as the key for other objects
 stored in VDataCache.
 */
@protocol VDataCacheID <NSObject>

@required

/**
 Returns a unique identifier that will be used to index
 this object when stored on disk with VDataCache
 */
- (NSString *)identifierForDataCache;

@end

/**
 Saves data to a cache on disk and loads previously cached data.
 */
@interface VDataCache : NSObject

/**
 A local file URL that points to a directory where cached data will 
 be stored. When loading cached data, if none is found in this
 location the application bundle will be searched as well.
 
 This is here for unit testing purposes--there is a good default that 
 will be used if this is not set.
 */
@property (nonatomic, copy) NSURL *localCacheURL;

/**
 Saves the given data to the cache and associates it with the given ID.
 If other data has previously been cached with this ID, it will be
 overwritten.
 */
- (BOOL)cacheData:(NSData *)data forID:(id<VDataCacheID>)identifier error:(NSError **)error;

/**
 Deletes the data, if any is present, at the provided identifier.
 */
- (BOOL)removeCachedDataForID:(id<VDataCacheID>)identifier error:(NSError **)error;

/**
 Copies the file at the given URL to the cache and associates it with the given ID.
 If other data has previously been cached with this ID, it will be overwritten.
 */
- (BOOL)cacheDataAtURL:(NSURL *)fileURL forID:(id<VDataCacheID>)identifier error:(NSError **)error;

/**
 Retrieves data previously cached with the given ID. Also searches
 the application bundle for data cached at build time.
 
 @return the data previously cached, or nil if none could be found.
 */
- (nullable NSData *)cachedDataForID:(id<VDataCacheID>)identifier;

/**
 Returns YES if we've already cached data with the specified ID.
 */
- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier;

/**
 Given an NSSet of IDs, returns the subset
 for which we don't have cached data.
 */
- (NSSet *)setOfIDsWithoutCachedDataFromIDSet:(NSSet *)setOfIDs;

@end

NS_ASSUME_NONNULL_END
