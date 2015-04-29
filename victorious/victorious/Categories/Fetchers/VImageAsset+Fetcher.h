//
//  VImageAsset+Fetcher.h
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAsset.h"

@interface VImageAsset (Fetcher)

/**
 From the supplied set of VImageAssets, returns the smallest asset by area whose width
 and height are greater than or equal to the provided minimum size.
 */
+ (VImageAsset *)assetWithPreferredMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets;

/**
 From the supplied set of VImageAssets, returns the largest asset by area whose width
 and height are less than or equal to the provided maximum size.
 */
+ (VImageAsset *)assetWithPreferredMaximumSize:(CGSize)maximumSize fromAssets:(NSSet *)imageAssets;

/**
 Returns the largest asset by area from the provided image assets.
 */
+ (VImageAsset *)largestAssetFromAssets:(NSSet *)imageAssets;

/**
 Returns the smallest asset by area from the provided image assets.
 */
+ (VImageAsset *)smallestAssetFromAssets:(NSSet *)imageAssets;

/**
 Fom the provided set, returns a sorted array of image assets ascending by area.
 */
+ (NSArray *)arrayAscendingByAreaFromAssets:(NSSet *)imageAssets;

/**
 Fom the provided set, returns a sorted array of image assets desscending by area.
 */
+ (NSArray *)arrayDescendingByAreaFromAssets:(NSSet *)imageAssets;

/**
 The area of the image in pixels squared.  Width * height;
 */
- (CGFloat)area;

/**
 Return YES if the height and width of the image asset are less than or equal
 to the width and height of the provided size.
 */
- (BOOL)fitsWithinSize:(CGSize)size;

/**
 Return YES if the height and width of the image asset are greater than or equal
 to the width and height of the provided size.
 */
- (BOOL)encompassesSize:(CGSize)size;

@end
