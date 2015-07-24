//
//  VCameraFocusView.m
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCameraFocusView.h"

static CGFloat const kBlurRadius = 2.0f;
static CGFloat const kLineWidth = 1.0f;

@implementation VCameraFocusView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    {
        // Shadow Declaration
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor: UIColor.whiteColor];
        [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
        [shadow setShadowBlurRadius: kBlurRadius];
        
        // Oval Drawing
        CGFloat insetAmount = (kLineWidth * 0.5f) + (kBlurRadius * 0.5f);
        CGRect insetRectForDrawing = CGRectInset(self.bounds, insetAmount, insetAmount);
        UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:insetRectForDrawing];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
        [UIColor.whiteColor setStroke];
        ovalPath.lineWidth = kLineWidth;
        [ovalPath stroke];
    }
    CGContextRestoreGState(context);
}

@end
