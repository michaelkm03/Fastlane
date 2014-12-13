//
//  VBadgeBackgroundView.m
//  victorious
//
//  Created by Josh Hinman on 12/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBadgeBackgroundView.h"

@implementation VBadgeBackgroundView

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
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat cornerRadius = CGRectGetHeight(rect) * 0.5f;
    UIBezierPath *background = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    [self.color setFill];
    [background fill];
}

@end
