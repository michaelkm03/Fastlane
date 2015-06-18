//
//  VDataCache.m
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDataCache.h"

static NSString * const kCacheDirectoryName = @"VDataCache";

@implementation VDataCache

- (BOOL)cacheData:(NSData *)data forID:(id<VDataCacheID>)identifier error:(NSError *__autoreleasing *)error
{
    NSParameterAssert( data != nil );
    NSParameterAssert( identifier != nil );
    
    if ( ![self preparePathForWritingWithError:error] )
    {
        return NO;
    }
    
    NSURL *cacheURL = [self pathForCachedDataWithID:identifier];
    return [data writeToURL:cacheURL atomically:YES];
}

- (NSData *)cachedDataForID:(id<VDataCacheID>)identifier
{
    NSURL *cacheURL = [self pathForCachedDataWithID:identifier];
    return [NSData dataWithContentsOfURL:cacheURL];
}

- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier
{
    NSURL *cacheURL = [self pathForCachedDataWithID:identifier];
    return [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path];
}

- (NSURL *)localCachePath
{
    if ( _localCachePath == nil )
    {
        NSURL *caches = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
        if ( caches == nil )
        {
            return nil;
        }
        _localCachePath = [caches URLByAppendingPathComponent:kCacheDirectoryName isDirectory:YES];
    }
    return _localCachePath;
}

- (NSURL *)pathForCachedDataWithID:(id<VDataCacheID>)identifier
{
    return [[self localCachePath] URLByAppendingPathComponent:[identifier identifierForDataCache]];
}

- (BOOL)preparePathForWritingWithError:(NSError **)error
{
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:self.localCachePath withIntermediateDirectories:YES attributes:nil error:error];
    if ( !created )
    {
        return NO;
    }
    
    return [self.localCachePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error];
}

@end
