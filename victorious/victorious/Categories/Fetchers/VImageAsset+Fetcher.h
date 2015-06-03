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
