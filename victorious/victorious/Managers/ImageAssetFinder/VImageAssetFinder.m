//
//  VImageAssetFinder.m
//  victorious
//
//  Created by Patrick Lynch on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetFinder.h"
#import "victorious-Swift.h"

static NSString * const kTextAsset = @"text";

@implementation VImageAssetFinder

- (VImageAsset *)assetWithPreferredMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
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

- (VImageAsset *)assetWithPreferredMaximumSize:(CGSize)maximumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
    }
    
    NSArray *assetsByDescendingArea = [self arrayDescendingByAreaFromAssets:imageAssets];
    for ( VImageAsset *imageAsset in assetsByDescendingArea )
    {
        if ( [imageAsset fitsWithinSize:maximumSize] )
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
