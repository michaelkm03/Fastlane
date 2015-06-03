//
//  VImageAssetFinder.m
//  victorious
//
//  Created by Patrick Lynch on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetFinder.h"
#import "VImageAsset+Fetcher.h"

@implementation VImageAssetFinder

- (VImageAsset *)localAssetFromAssets:(NSSet *)imageAssets
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocal == YES"];
    return [imageAssets filteredSetUsingPredicate:predicate].allObjects.firstObject;
}

- (VImageAsset *)assetWithPreferredMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
    }
    
    if ( self.preferLocalImageAssets )
    {
        VImageAsset *localAsset = [self localAssetFromAssets:imageAssets];
        if ( localAsset != nil )
        {
            NSLog( @"^V^V^V^V^V^V^V^ Using lcoal asset" );
            return localAsset;
        }
    }
    
    NSArray *assetsByAscendingArea = [self arrayAscendingByAreaFromAssets:imageAssets];
    for ( VImageAsset *imageAsset in assetsByAscendingArea )
    {
        if ( [imageAsset encompassesSize:minimumSize] )
        {
            return imageAsset;
        }
    }
    
    return assetsByAscendingArea.lastObject;
}

- (VImageAsset *)assetWithPreferredMaximumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
    }
    
    if ( self.preferLocalImageAssets )
    {
        VImageAsset *localAsset = [self localAssetFromAssets:imageAssets];
        if ( localAsset != nil )
        {
            return localAsset;
        }
    }
    
    NSArray *assetsByDescendingArea = [self arrayDescendingByAreaFromAssets:imageAssets];
    for ( VImageAsset *imageAsset in assetsByDescendingArea )
    {
        if ( [imageAsset fitsWithinSize:minimumSize] )
        {
            return imageAsset;
        }
    }
    
    return assetsByDescendingArea.lastObject;
}

- (VImageAsset *)largestAssetFromAssets:(NSSet *)imageAssets
{
    return [self arrayAscendingByAreaFromAssets:imageAssets].lastObject;
}

- (VImageAsset *)smallestAssetFromAssets:(NSSet *)imageAssets
{
    return [self arrayAscendingByAreaFromAssets:imageAssets].firstObject;
}

- (NSArray *)arrayAscendingByAreaFromAssets:(NSSet *)imageAssets
{
    return [[imageAssets allObjects] sortedArrayUsingComparator:^NSComparisonResult( VImageAsset *asset1, VImageAsset *asset2 )
            {
                return [@(asset1.area) compare:@(asset2.area)];
            }];
}

- (NSArray *)arrayDescendingByAreaFromAssets:(NSSet *)imageAssets
{
    return [[imageAssets allObjects] sortedArrayUsingComparator:^NSComparisonResult( VImageAsset *asset1, VImageAsset *asset2 )
            {
                return [@(asset2.area) compare:@(asset1.area)];
            }];
}

@end
