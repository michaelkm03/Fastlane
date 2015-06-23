//
//  VRoundedBackgroundButton.m
//  victorious
//
//  Created by Michael Sena on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRoundedBackgroundButton.h"
#import <objc/runtime.h>

static const CGFloat kHighlightedAlpha = 0.7f;
static const CGFloat kHighlightedScale = 0.8f;

@interface VRoundedBackgroundButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation VRoundedBackgroundButton

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.circleLayer == nil)
    {
        self.circleLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:self.circleLayer atIndex:0];
    }
    
    self.circleLayer.fillColor = self.selected ? self.selectedTintColor.CGColor : self.unselectedTintColor.CGColor;
    self.circleLayer.bounds = self.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:UIRectCornerAllCorners
                                                           cornerRadii:self.bounds.size];
    self.circleLayer.path = circlePath.CGPath;
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
    self.circleLayer.affineTransform = highlighted ? CGAffineTransformMakeScale(kHighlightedScale, kHighlightedScale) : CGAffineTransformIdentity;
}

- (void)updateColors
{
    self.circleLayer.fillColor = self.selected ? self.selectedTintColor.CGColor : self.unselectedTintColor.CGColor;
    self.tintColor = self.selected ? self.selectedTintColor : self.unselectedTintColor;
}

#pragma mark - Property Accessors

- (void)setSelectedColor:(UIColor *)selectedTintColor
{
    _selectedTintColor = [selectedTintColor copy];
    
    self.circleLayer.fillColor = self.selected ? selectedTintColor.CGColor : self.unselectedTintColor.CGColor;
    [self setNeedsLayout];
}

- (void)setUnselectedTintColor:(UIColor *)unselectedTintColor
{
    _unselectedTintColor = [unselectedTintColor copy];
    
    self.circleLayer.fillColor = self.selected ? self.selectedTintColor.CGColor : _unselectedTintColor.CGColor;
    [self setNeedsLayout];
}

@end
