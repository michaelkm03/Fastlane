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

+ (VActionButton *)actionButtonWithImage:(UIImage *)unselectedImage
                           selectedImage:(UIImage *)selectedImage;

+ (VActionButton *)actionButtonWithImage:(UIImage *)unselectedImage
                           selectedImage:(UIImage *)selectedImage
                         backgroundImage:(UIImage *)backgroundImage;

/**
 *  A tint color representing the active state.
 */
@property (nonatomic, copy) UIColor *selectedTintColor;

/**
 *  A tint color representing the default (non-active) state.
 */
@property (nonatomic, copy) UIColor *unselectedTintColor;

@end
