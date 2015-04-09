//
//  VAsset+VCachedData.m
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAsset+VCachedData.h"
#import "VAsset+VAssetCache.h"

@implementation VAsset (VCachedData)

- (BOOL)assetDataIsCached
{
    NSURL *cacheLocation = [self cacheURLForAsset];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheLocation.path];
    return fileExists;
}

@end
