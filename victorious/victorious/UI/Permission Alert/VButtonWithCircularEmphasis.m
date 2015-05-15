//
//  VButtonWithCircularEmphasis.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VButtonWithCircularEmphasis.h"

@interface VButtonWithCircularEmphasis ()

@property (nonatomic, strong) CALayer *pillLayer;

@end

@implementation VButtonWithCircularEmphasis

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
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
    // Set default emphasis color
    self.emphasisColor = [UIColor blueColor];
    
    // Create and add emphasis layer
    CALayer *newLayer = [CALayer layer];
    [self.layer addSublayer:newLayer];
    self.pillLayer = newLayer;
}

- (void)setEmphasisColor:(UIColor *)emphasisColor
{
    _emphasisColor = emphasisColor;
    self.pillLayer.backgroundColor = emphasisColor.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Adjust emphasis frame to match text
    self.pillLayer.frame = CGRectInset(self.titleLabel.frame, -26.0f, -5.0f);
    self.pillLayer.cornerRadius = CGRectGetHeight(self.pillLayer.bounds) / 2;
}

@end
