//
//  VAsset+VAssetCache.m
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAsset+VAssetCache.h"
#import "VNode.h"
#import "VSequence.h"

static NSString * const kAssetPathFormat = @"/com.getvictorious.sequenceCache/sequences/%@/assets/%@/%@";

@implementation VAsset (VAssetCache)

- (NSURL *)cacheURLForAsset
{
    NSURL *baseURL = [self cacheDirectoryURL];
    NSURL *combinedURL = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:kAssetPathFormat, self.node.sequence.remoteId, self.remoteId, self.data.lastPathComponent]];
    
    return combinedURL;
}

#pragma mark - Filesystem

- (NSURL *)cacheDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
}

@end
