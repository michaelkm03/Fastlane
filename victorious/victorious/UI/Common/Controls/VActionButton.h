//
//  VActionButton.h
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VActiveButton.h"

@interface VActionButton : UIButton <VActiveButton>

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage;

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage
                         backgroundImage:(UIImage *)backgroundImage;

@property (nonatomic, assign, getter=isActive) BOOL active;

@property (nonatomic, copy) UIColor *activeColor;

@end
