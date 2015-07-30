//
//  VBundleWriterDataCache.m
//  victorious
//
//  Created by Josh Hinman on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBundleWriterDataCache.h"

NS_ASSUME_NONNULL_BEGIN

@implementation VBundleWriterDataCache

- (instancetype)initWithBundleURL:(NSURL *)bundleURL
{
    self = [super init];
    if ( self != nil )
    {
        _bundleURL = bundleURL;
    }
    return self;
}

- (BOOL)cacheData:(NSData *)data forID:(id<VDataCacheID>)identifier error:(NSError *__autoreleasing *)error
{
    NSParameterAssert( data != nil );
    NSParameterAssert( identifier != nil );
    
    NSURL *cacheURL = [self bundleURLForCachedDataWithID:identifier];
    return [data writeToURL:cacheURL atomically:YES];
}

- (BOOL)cacheDataAtURL:(NSURL *)fileURL forID:(id<VDataCacheID>)identifier error:(NSError *__autoreleasing *)error
{
    NSParameterAssert( fileURL != nil );
    NSParameterAssert( identifier != nil );
    
    BOOL isDirectory = NO;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:&isDirectory] ||
        isDirectory )
    {
        return NO;
    }
    
    NSURL *saveURL = [self bundleURLForCachedDataWithID:identifier];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[saveURL path]] )
    {
        if ( ![[NSFileManager defaultManager] removeItemAtURL:saveURL error:error] )
        {
            return NO;
        }
    }
    return [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:saveURL error:error];
}

- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier
{
    NSURL *cacheURL = [self bundleURLForCachedDataWithID:identifier];
    return [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path];
}

- (NSURL *)bundleURLForCachedDataWithID:(id<VDataCacheID>)identifier
{
    return [[self.bundleURL URLByAppendingPathComponent:[identifier identifierForDataCache] isDirectory:NO] URLByAppendingPathExtension:VDataCacheBundleResourceExtension];
}

@end

NS_ASSUME_NONNULL_END
