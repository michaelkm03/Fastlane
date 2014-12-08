//
//  VInboxBadgeView.m
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VBadgeLabel.h"
#import "VDependencyManager.h"

static CGFloat const kMargin = 4.0f;
static NSInteger const kLargeNumberCutoff = 100; ///< Numbers equal to or greater than this cutoff will not display

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
    self.backgroundColor = [UIColor colorWithRed:0.88f green:0.18f blue:0.22f alpha:1.0f];
    self.textColor = [UIColor whiteColor];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    
    if ( size.width == 0 || size.height == 0 )
    {
        return CGSizeZero;
    }
    
    // The label should be at least as wide as it is tall, or it looks lemon-shaped with the corner radius!
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

- (void)drawTextInRect:(CGRect)rect
{
    CGRect fixedRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0, 1));
    [super drawTextInRect:fixedRect];
}

- (void)setText:(NSString *)text
{
    NSAssert(NO, @"unsupported. Use -setBadgeNumber: instead");
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if (badgeNumber == 0)
    {
        super.text = @"";
    }
    else if (badgeNumber < kLargeNumberCutoff)
    {
        super.text = [NSString stringWithFormat:@"%ld", (long)badgeNumber];
    }
    else
    {
        super.text = [NSString stringWithFormat:NSLocalizedString(@"%ld+", @"Number and symbol meaning \"more than\", e.g. \"99+ items\". (%ld is a placeholder for a number)"), (long)(kLargeNumberCutoff - 1)];
    }
}

@end
