//
//  UIView+Masking.m
//  victorious
//
//  Created by Gary Philipp on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIView+Masking.h"

@implementation UIView (Masking)

- (void)maskWithImage:(UIImage *)mask
{
    [self maskWithImage:mask size:mask.size];
}

- (void)maskWithImage:(UIImage *)mask size:(CGSize)maskSize
{
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, maskSize.width, maskSize.height);
    maskLayer.contents = (__bridge id)[mask CGImage];
    
    // Apply the mask to your uiview layer
    self.layer.mask = maskLayer;
}

- (void)removeMask
{
    self.layer.mask = nil;
}

@end
