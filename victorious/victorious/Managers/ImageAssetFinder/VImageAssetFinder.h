//
//  VImageAssetFinder.h
//  victorious
//
//  Created by Patrick Lynch on 6/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VImageAsset;

@interface VImageAssetFinder : NSObject

/**
 When set to YES, the asset finder will check for any VImageAssets marked `isLocal`
 and return those first, regardless of any size calculations.
 */
@property (nonatomic, assign) BOOL preferLocalImageAssets;

/**
 Returns the first asset marked `isLocal`, which is not sorted nor does the asset size
 (presumed to be known) factor in.
 */
- (VImageAsset *)localAssetFromAssets:(NSSet *)imageAssets;

/**
 From the supplied set of VImageAssets, returns the smallest asset by area whose width
 and height are greater than or equal to the provided minimum size.
 */
- (VImageAsset *)assetWithPreferredMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets;

/**
 From the supplied set of VImageAssets, returns the largest asset by area whose width
 and height are less than or equal to the provided maximum size.
 */
- (VImageAsset *)assetWithPreferredMaximumSize:(CGSize)maximumSize fromAssets:(NSSet *)imageAssets;

/**
 Returns the largest asset by area from the provided image assets.
 */
- (VImageAsset *)largestAssetFromAssets:(NSSet *)imageAssets;

/**
 Returns the smallest asset by area from the provided image assets.
 */
- (VImageAsset *)smallestAssetFromAssets:(NSSet *)imageAssets;

/**
 Fom the provided set, returns a sorted array of image assets ascending by area.
 */
- (NSArray *)arrayAscendingByAreaFromAssets:(NSSet *)imageAssets;

/**
 Fom the provided set, returns a sorted array of image assets desscending by area.
 */
- (NSArray *)arrayDescendingByAreaFromAssets:(NSSet *)imageAssets;

@end
