//
//  VInboxBadgeView.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VBadgeLabel.h"
#import "VDependencyManager.h"

static CGFloat const kMarginWidth = 4.0f;

@implementation VBadgeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.textAlignment = NSTextAlignmentCenter;
    self.clipsToBounds = YES;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.font = [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.textColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    CGFloat biggerDimension = MAX(size.width, size.height);
    
    if (biggerDimension == 0)
    {
        return CGSizeZero;
    }
    return CGSizeMake(biggerDimension + kMarginWidth, biggerDimension + kMarginWidth);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat newCornerRadius = CGRectGetHeight(self.bounds) * 0.5f;
    
    if (newCornerRadius != self.layer.cornerRadius)
    {
        self.layer.cornerRadius = newCornerRadius;
    }
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect fixedRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0, 1));
    [super drawTextInRect:fixedRect];
}

@end
