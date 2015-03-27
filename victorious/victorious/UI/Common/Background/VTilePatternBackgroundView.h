//
//  VLoadingView.h
//  victorious
//
//  Created by Michael Sena on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VTilePatternBackgroundView provides a pattern background UI.
 */
@interface VTilePatternBackgroundView : UIView

/**
 *  The color to use to blend with the image.
 */
@property (nonatomic, copy) UIColor *color;

/**
 *  This image will be tiled across the background of the view.
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  If the tiled backgroudn should parallax with the tilt of the device.
 */
@property (nonatomic, assign) BOOL tiltParallaxEnabled;

/**
 *  Whether or not the shimmer animation should be active. The shimmer animation
 *  starts at the top-left most pattern instance and cascades across all pattern 
 *  instances to the bottom right. Repeats.
 */
@property (nonatomic, assign) BOOL shimmerAnimationActive;

@end
