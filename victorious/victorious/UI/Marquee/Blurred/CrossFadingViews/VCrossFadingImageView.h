//
//  VCrossFadingImageView.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCrossFadingView.h"

@class VStreamItemPreviewView;

/**
    A view that loads, blurs, and crossfades between images from the provided imageURLs.
 */
@interface VCrossFadingImageView : VAbstractCrossFadingView

/**
    Adds a number of blank image views to this view with proper constraints
 
    @param numberOfImageViews The number of image views to add as subviews
 */
- (void)setupWithNumberOfImageViews:(NSInteger)numberOfImageViews;

/**
    Blurs and applies the provided image to the imageView at the provided index
 
    @param image The image to blur, tint, and set in the imageView at the provided index
    @param previewView The previewView that was used to generate the image. This is used to prevent the view from reloading unnecessarily.
    @param tintColor The color that will be shown on top of the blurred image.
    @param index The index of the imageView that should be updated with the provided image. If the index is
            out of count from the created imageViews, this function does nothing.
    @param animated Whether or not the specified imageView should be updated with an animation.
    @param concurrentAnimations Animations that will be executed while the image is animating to visible.
 */
- (void)updateBlurredImageViewForImage:(UIImage *)image
                       fromPreviewView:(VStreamItemPreviewView *)previewView
                         withTintColor:(UIColor *)tintColor
                               atIndex:(NSInteger)index
                              animated:(BOOL)animated
              withConcurrentAnimations:(void (^)(void))concurrentAnimations;

/**
    The number of imageViews inside this view
 */
@property (nonatomic, readonly) NSInteger imageViewCount;

@end
