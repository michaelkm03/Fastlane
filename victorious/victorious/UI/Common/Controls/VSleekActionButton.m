//
//  VSleekActionButton.m
//  victorious
//
//  Created by Patrick Lynch on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekActionButton.h"

static const CGFloat kHighlightedAlpha = 0.7f;
static const CGFloat kHighlightedScale = 0.8f;

@interface VSleekActionButton ()

@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@end

@implementation VSleekActionButton

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.backgroundLayer == nil)
    {
        self.backgroundLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:self.backgroundLayer atIndex:0];
    }
    
    self.backgroundLayer.bounds = self.bounds;
    self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerAllCorners
                                                           cornerRadii:self.bounds.size];
    self.backgroundLayer.path = circlePath.CGPath;
    [self updateColors];
}

#pragma mark - UIControl Overrides

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self updateColors];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.alpha = highlighted ? kHighlightedAlpha : 1.0f;
    self.backgroundLayer.affineTransform = highlighted ? CGAffineTransformMakeScale(kHighlightedScale, kHighlightedScale) : CGAffineTransformIdentity;
}

- (void)updateColors
{
    self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    self.tintColor = self.selected ? self.selectedTintColor : self.unselectedTintColor;
}

#pragma mark - Property Accessors

- (void)setSelectedColor:(UIColor *)selectedTintColor
{
    _selectedTintColor = [selectedTintColor copy];
    [self updateColors];
}

- (void)setUnselectedTintColor:(UIColor *)unselectedTintColor
{
    _unselectedTintColor = [unselectedTintColor copy];
    [self updateColors];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self updateColors];
}

@end
