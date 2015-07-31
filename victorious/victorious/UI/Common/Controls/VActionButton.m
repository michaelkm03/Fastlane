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

@property (nonatomic, strong) UIImage *inactiveImage;
@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) CALayer *backgroundImageLayer;

@end

@implementation VActionButton

+ (VActionButton *)actionButtonWithImage:(UIImage *)unselectedImage
                           selectedImage:(UIImage *)selectedImage
{
    return [self actionButtonWithImage:unselectedImage selectedImage:selectedImage backgroundImage:nil];
}

+ (VActionButton *)actionButtonWithImage:(UIImage *)unselectedImage
                           selectedImage:(UIImage *)selectedImage
                         backgroundImage:(UIImage *)backgroundImage
{
    VActionButton *actionButton = [VActionButton buttonWithType:UIButtonTypeCustom];
    [actionButton setImage:selectedImage forState:UIControlStateSelected];
    [actionButton setImage:unselectedImage forState:UIControlStateNormal];
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
    
    [self updateColors];
}

- (void)setSelected:(BOOL)selected
{
    super.selected = selected;
    [self updateColors];
}

- (void)updateColors
{
    self.tintColor = self.selected && self.selectedTintColor != nil ? self.selectedTintColor : self.unselectedTintColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( !self.enabled && [self pointInside:[self convertPoint:point toView:self] withEvent:event] )
    {
        return self;
    }
    return [super hitTest:point withEvent:event];
}

@end
