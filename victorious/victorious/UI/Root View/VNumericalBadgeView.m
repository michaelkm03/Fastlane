//
//  VNumericalBadgeView.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VNumericalBadgeView.h"
#import "VDependencyManager.h"

@interface VNumericalBadgeView ()

@property (nonatomic, weak) UILabel *label;

@end

static CGFloat const kMargin = 4.0f;
static NSInteger const kLargeNumberCutoff = 100; ///< Numbers equal to or greater than this cutoff will not display

@implementation VNumericalBadgeView

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
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    _label = label;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:1.0f]];
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0.88f green:0.18f blue:0.22f alpha:1.0f];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.label intrinsicContentSize];
    
    if ( size.width == 0 || size.height == 0 )
    {
        return CGSizeZero;
    }
    
    // We should be at least as wide as we are tall, or we look lemon-shaped with the corner radius!
    return CGSizeMake(MAX(size.width + kMargin, size.height + kMargin), size.height + kMargin);
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

- (UIFont *)font
{
    return self.label.font;
}

- (void)setFont:(UIFont *)font
{
    self.label.font = font;
    [self invalidateIntrinsicContentSize];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if (badgeNumber == _badgeNumber)
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    if (badgeNumber == 0)
    {
        self.label.text = @"";
    }
    else if (badgeNumber < kLargeNumberCutoff)
    {
        self.label.text = [NSString stringWithFormat:@"%ld", (long)badgeNumber];
    }
    else
    {
        self.label.text = [NSString stringWithFormat:NSLocalizedString(@"%ld+", @"Number and symbol meaning \"more than\", e.g. \"99+ items\". (%ld is a placeholder for a number)"), (long)(kLargeNumberCutoff - 1)];
    }
    [self invalidateIntrinsicContentSize];
}

@end
