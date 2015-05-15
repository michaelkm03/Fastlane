//
//  VCrossFadingImageView.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    A view that loads, blurs, and crossfades between images from the provided imageURLs. The alpha of these images
        can be manipulated by the "offset" property
 */
@interface VCrossFadingImageView : UIView

/**
    Adds a number of blank image views to this view with proper constraints
 
    @param numberOfImageViews The number of image views to add as subviews
 */
- (void)setupWithNumberOfImageViews:(NSInteger)numberOfImageViews;

/**
    Blurs and applies the provided image to the imageView at the provided index
 
    @param image The image to blur, tint, and set in the imageView at the provided index
    @param url The url that was used to fetch the image. This is used to prevent the view from reloading unnecessarily.
    @param tintColor The color that will be shown on top of the blurred image.
    @param index The index of the imageView that should be updated with the provided image. If the index is
            out of count from the created imageViews, this function does nothing.
    @param animated Whether or not the specified imageView should be updated with an animation.
 */
- (void)updateBlurredImageViewForImage:(UIImage *)image
                               fromURL:(NSURL *)url
                         withTintColor:(UIColor *)tintColor
                               atIndex:(NSInteger)index
                              animated:(BOOL)animated;

/**
    Determines how much of each image retrieved from each imageURL is shown based on the image's position in the imageURLs array.
        At an offset of 0, the image at index 0 is shown at full opacity;
        at an offset of 0.5, the image at index 0 is shown at 0.5 alpha and the image at index 1 is shown at 0.5 alpha, and so on.
        This value caps it's values between 0 and the count of items in the imageURLs array - 1;
        this is done so that this view never displays only a fully-transparent image. Defaults to 0.0f.
 */
@property (nonatomic, assign) CGFloat offset;

/**
    The number of imageViews inside this view
 */
@property (nonatomic, readonly) NSInteger imageViewCount;

@end
