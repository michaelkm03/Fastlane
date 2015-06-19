//
//  VActionButton.m
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VActionButton.h"
#import "UIView+AutoLayout.h"

@interface VActionButton()

@property (nonatomic, copy) UIColor *defaultTintColor;
@property (nonatomic, strong) UIImage *inactiveImage;
@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) CALayer *backgroundImageLayer;

@end


@implementation VActionButton

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage
{
    return [self actionButtonWithImage:inactiveImage activeImage:inactiveImage backgroundImage:nil];
}

+ (VActionButton *)actionButtonWithImage:(UIImage *)inactiveImage
                             activeImage:(UIImage *)activeImage
                         backgroundImage:(UIImage *)backgroundImage
{
    VActionButton *actionButton = [VActionButton buttonWithType:UIButtonTypeSystem];
    actionButton.inactiveImage = inactiveImage;
    actionButton.activeImage = activeImage;
    actionButton.active = NO;
    actionButton.backgroundImage = backgroundImage;
    
    return actionButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.backgroundImageLayer == nil)
    {
        self.backgroundImageLayer = [CALayer layer];
        [self.layer insertSublayer:self.backgroundImageLayer atIndex:0];
    }
    
    CGSize imageSize = self.backgroundImage.size;
    CGPoint imagePosition = CGPointMake( (CGRectGetWidth(self.bounds) - imageSize.width) * 0.5f,
                                         (CGRectGetHeight(self.bounds) - imageSize.height) * 0.5f );
    self.backgroundImageLayer.frame = CGRectMake( imagePosition.x, imagePosition.y, imageSize.width, imageSize.height );
    self.backgroundImageLayer.contentsGravity = kCAGravityResizeAspect;
    self.backgroundImageLayer.contents = (id)self.backgroundImage.CGImage;
    self.backgroundImageLayer.opacity = self.enabled ? 1.0f : 0.5f;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    UIImage *image = active ? self.activeImage : self.inactiveImage;
    if ( self.activeColor != nil )
    {
        super.tintColor = active ? self.activeColor : self.defaultTintColor; //< Use super.tintColor, self is overridden
    }
    [self setImage:image forState:UIControlStateNormal];
    [self sizeToFit];
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = tintColor;
    self.defaultTintColor = tintColor;
}

@end
