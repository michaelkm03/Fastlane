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
@property (nonatomic, strong) UIColor *circleColor;

@end

static UIEdgeInsets const kMargin = { 2.0f, 4.0f, 2.0f, 4.0f };
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
    _circleColor = [UIColor colorWithRed:0.88f green:0.18f blue:0.22f alpha:1.0f];
    super.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    
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
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.label intrinsicContentSize];
    
    if ( size.width == 0 || size.height == 0 )
    {
        return CGSizeZero;
    }
    
    // We should be at least as wide as we are tall, or we look lemon-shaped with the corner radius!
    return CGSizeMake(MAX(size.width + kMargin.left + kMargin.right, size.height + kMargin.top + kMargin.bottom),
                      size.height + kMargin.top + kMargin.bottom);
}

- (void)drawRect:(CGRect)rect
{
    CGFloat cornerRadius = CGRectGetHeight(rect) * 0.5f;
    UIBezierPath *background = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    [self.backgroundColor setFill];
    [background fill];
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

- (UIColor *)backgroundColor
{
    return self.circleColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.circleColor = backgroundColor;
}

- (UIColor *)textColor
{
    return self.label.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.label.textColor = textColor;
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
