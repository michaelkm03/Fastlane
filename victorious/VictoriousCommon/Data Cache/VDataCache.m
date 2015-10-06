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
    
    NSURL *cacheURL = [self URLForCachedDataWithID:identifier];
    return [data writeToURL:cacheURL atomically:YES];
}

- (BOOL)cacheDataAtURL:(NSURL *)fileURL forID:(id<VDataCacheID>)identifier error:(NSError *__autoreleasing *)error
{
    NSParameterAssert( fileURL != nil );
    NSParameterAssert( identifier != nil );
    
    if ( ![self preparePathForWritingWithError:error] )
    {
        return NO;
    }
    
    BOOL isDirectory = NO;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:&isDirectory] ||
         isDirectory )
    {
        return NO;
    }
    
    NSURL *saveURL = [self URLForCachedDataWithID:identifier];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[saveURL path]] )
    {
        if ( ![[NSFileManager defaultManager] removeItemAtURL:saveURL error:error] )
        {
            return NO;
        }
    }
    return [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:saveURL error:error];
}

- (NSData *)cachedDataForID:(id<VDataCacheID>)identifier
{
    NSParameterAssert( identifier != nil );
    
    NSURL *cacheURL = [self URLForCachedDataWithID:identifier];
    NSData *cachedData = [NSData dataWithContentsOfURL:cacheURL];
    
    if ( cachedData == nil )
    {
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:[identifier identifierForDataCache] withExtension:VDataCacheBundleResourceExtension];
        cachedData = [NSData dataWithContentsOfURL:bundleURL];
    }
    return cachedData;
}

- (BOOL)removeCachedDataForId:(id<VDataCacheID>)identifier error:(NSError **)error
{
    NSURL *saveURL = [self URLForCachedDataWithID:identifier];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[saveURL path]] )
    {
        return [[NSFileManager defaultManager] removeItemAtURL:saveURL error:error];
    }
    return YES;
}

- (BOOL)hasCachedDataForID:(id<VDataCacheID>)identifier
{
    NSParameterAssert( identifier != nil );
    
    NSURL *cacheURL = [self URLForCachedDataWithID:identifier];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:cacheURL.path] )
    {
        return YES;
    }
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:[identifier identifierForDataCache] withExtension:VDataCacheBundleResourceExtension];
    return bundleURL != nil;
}

- (NSURL *)localCacheURL
{
    if ( _localCacheURL == nil )
    {
        NSURL *caches = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
        if ( caches == nil )
        {
            return nil;
        }
        _localCacheURL = [caches URLByAppendingPathComponent:kCacheDirectoryName isDirectory:YES];
    }
    return _localCacheURL;
}

- (NSURL *)URLForCachedDataWithID:(id<VDataCacheID>)identifier
{
    return [[self localCacheURL] URLByAppendingPathComponent:[identifier identifierForDataCache]];
}

- (NSSet *)setOfIDsWithoutCachedDataFromIDSet:(NSSet *)setOfIDs
{
    NSMutableSet *returnValue = [[NSMutableSet alloc] initWithCapacity:setOfIDs.count];
    for (id<VDataCacheID> identifier in setOfIDs)
    {
        if ( ![self hasCachedDataForID:identifier] )
        {
            [returnValue addObject:identifier];
        }
    }
    return returnValue;
}

- (BOOL)preparePathForWritingWithError:(NSError **)error
{
    if ( self.cacheLocationPrepared )
    {
        return YES;
    }
    
    NSError *myError = nil;
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:self.localCacheURL withIntermediateDirectories:YES attributes:nil error:&myError];
    if ( !created )
    {
        BOOL isDirectory = NO;
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:self.localCacheURL.path isDirectory:&isDirectory] || !isDirectory )
        {
            if ( error != nil )
            {
                *error = myError;
            }
            return NO;
        }
    }
    
    return [self.localCacheURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error];
}

@end
