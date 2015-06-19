//
//  VDataCache.m
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDataCache.h"

NSString * const VDataCacheBundleResourceExtension = @"cachedData";
static NSString * const kCacheDirectoryName = @"VDataCache";

@interface VDataCache ()

@property (nonatomic) BOOL cacheLocationPrepared;

@end

@implementation VDataCache

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _cacheLocationPrepared = NO;
    }
    return self;
}

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
    NSData *cachedData = [NSData dataWithContentsOfURL:cacheURL];
    
    if ( cachedData == nil )
    {
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:[identifier identifierForDataCache] withExtension:VDataCacheBundleResourceExtension];
        cachedData = [NSData dataWithContentsOfURL:bundleURL];
    }
    return cachedData;
}

- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier
{
    NSURL *cacheURL = [self pathForCachedDataWithID:identifier];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path] )
    {
        return YES;
    }
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:[identifier identifierForDataCache] withExtension:VDataCacheBundleResourceExtension];
    return bundleURL != nil;
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
    if ( self.cacheLocationPrepared )
    {
        return YES;
    }
    
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:self.localCachePath withIntermediateDirectories:YES attributes:nil error:error];
    if ( !created )
    {
        return NO;
    }
    
    return [self.localCachePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error];
}

@end
