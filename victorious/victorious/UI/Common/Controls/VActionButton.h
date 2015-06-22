//
//  VActionButton.h
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Button designed for use in stream cells that provides an extended interface
 to help customize images and colors, as well as adds an `active` state to provide
 toggle functionality, such as for liking an item.
 */
@interface VActionButton : UIButton

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage;

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage
                         backgroundImage:(UIImage *)backgroundImage;

/**
 Uses the the activeImage and activeColor properties to update the appearance
 of the button
 */
@property (nonatomic, assign, getter=isActive) BOOL active;

/**
 *  A color representing the active state.
 */
@property (nonatomic, copy) UIColor *activeColor;

@end
