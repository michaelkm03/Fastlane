//
//  VCVideoPlayerToolbarSlider.m
//  victorious
//
//  Created by Josh Hinman on 6/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"
#import "VCVideoPlayerToolbarSlider.h"

static const CGFloat kTrackHeight = 3.0f;

@implementation VCVideoPlayerToolbarSlider

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self setThumbImage:[[UIImage imageNamed:@"player-handle"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
               forState:UIControlStateNormal];
    [self setMinimumTrackImage:[self minimumTrackImageWithColor:[UIColor whiteColor] cornerRadius:1.5f]
               forState:UIControlStateNormal];
    [self setMaximumTrackImage:[UIImage v_imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]]
               forState:UIControlStateNormal];
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0.0f,
                      CGRectGetMidY(bounds) - kTrackHeight * 0.5f,
                      CGRectGetWidth(bounds),
                      kTrackHeight);
}

- (UIImage *)minimumTrackImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    CGSize roundedRectSize = CGSizeMake(cornerRadius * 2.0f + 1.0f, cornerRadius * 2.0f);
    UIGraphicsBeginImageContextWithOptions(roundedRectSize, NO, 0);
    [color setFill];
    
    CGPathRef roundedRect = CGPathCreateWithRoundedRect(CGRectMake(0.0f, 0.0f, roundedRectSize.width, roundedRectSize.height), cornerRadius, cornerRadius, NULL);
    CGContextAddPath(UIGraphicsGetCurrentContext(), roundedRect);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    CGPathRelease(roundedRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, cornerRadius, 0.0f, cornerRadius)];
}

@end
