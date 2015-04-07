//
//  NSURL+VAssetCache.m
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VAssetCache.h"

static NSString * const kAssetPathFormat = @"assets/%@/%@";

@class VAsset;

@implementation NSURL (VAssetCache)

+ (NSURL *)cacheURLForAsset:(VAsset *)asset
{
    NSURL *baseURL = [self cacheDirectoryURL];
    NSURL *combinedURL = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:kAssetPathFormat, asset.remoteId, asset.data.lastPathComponent]];
    
    return combinedURL;
}

#pragma mark - Filesystem

+ (NSURL *)cacheDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
}

@end
