//
//  VActionButton.m
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionButton.h"

@interface VActionButton()

@property (nonatomic, strong) UIImage *inactiveImage;
@property (nonatomic, strong) UIImage *activeImage;

@end


@implementation VActionButton

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage activeImage:(UIImage *)activeImage
{
    VActionButton *actionButton = [VActionButton buttonWithType:UIButtonTypeSystem];
    actionButton.inactiveImage = inactiveImage;
    actionButton.activeImage = activeImage;
    actionButton.active = NO;
    return actionButton;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    UIImage *image = active ? self.activeImage : self.inactiveImage;
    [self setImage:image forState:UIControlStateNormal];
    [self sizeToFit];
}

@end
