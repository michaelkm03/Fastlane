//
//  VCrossFadingImageView.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCrossFadingImageView : UIView

/**
    Loads the images at the provided image URLs and displays them with a blur, the provided tint color, and placeholder image
 
    @param imageURLs An array of NSURLs pointing to the images that should crossfade into one another based on the provided offset
    @param tintColor The color used to lightly tint the images at the provided URLs
    @param placeholderImage The image to display until the image has finished loading.
        The same placeholder image is applied to each of the images provided via the imageURLs
 */
- (void)setupWithImageURLs:(NSArray *)imageURLs tintColor:(UIColor *)tintColor andPlaceholderImage:(UIImage *)placeholderImage;

/**
    Determines how much of each image retrieved from each imageURL is shown based on the image's position in the imageURLs array.
        At an offset of 0, the image at index 0 is shown at full opacity;
        at an offset of 0.5, the image at index 0 is shown at 0.5 alpha and the image at index 1 is shown at 0.5 alpha, and so on.
        This value caps it's values between 0 and the count of items in the imageURLs array - 1;
        this is done so that this view never displays only a fully-transparent image. Defaults to 0.0f.
 */
@property (nonatomic, assign) CGFloat offset;

/**
    The imageURLs whose associated images will be displayed in this view based on the provided offset.
 */
@property (nonatomic, readonly) NSArray *imageURLs;

@end
