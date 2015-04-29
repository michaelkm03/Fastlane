//
//  VImageAsset+Fetcher.m
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAsset+Fetcher.h"
#import "NSData+ImageContentType.h"

@implementation VImageAsset (Fetcher)

+ (VImageAsset *)assetWithMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
    }
    
    NSArray *assetsByAscendingArea = [[imageAssets allObjects] sortedArrayUsingComparator:^NSComparisonResult( VImageAsset *asset1, VImageAsset *asset2 )
                                      {
                                          return [@(asset1.area) compare:@(asset2.area)];
                                      }];
    
    for ( VImageAsset *imageAsset in assetsByAscendingArea )
    {
        if ( [imageAsset isLargerThanSize:minimumSize] )
        {
            return imageAsset;
        }
    }
    
    return nil;
}

+ (VImageAsset *)assetWithMaximumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets
{
    if ( imageAssets == nil || imageAssets.count == 0 )
    {
        return nil;
    }
    
    NSArray *assetsByDescendingArea = [[imageAssets allObjects] sortedArrayUsingComparator:^NSComparisonResult( VImageAsset *asset1, VImageAsset *asset2 )
                                       {
                                           return [@(asset2.area) compare:@(asset1.area)];
                                       }];
    
    for ( VImageAsset *imageAsset in assetsByDescendingArea )
    {
        if ( [imageAsset isLargerThanSize:minimumSize] )
        {
            return imageAsset;
        }
    }
    
    return nil;
}

- (CGFloat)area
{
    return self.width.floatValue * self.height.floatValue;
}

- (BOOL)isSmallerThanSize:(CGSize)size
{
    return self.width.floatValue <= size.width && self.height.floatValue >= size.height;
}

- (BOOL)isLargerThanSize:(CGSize)size
{
    return self.width.floatValue >= size.width && self.height.floatValue >= size.height;
}

@end
