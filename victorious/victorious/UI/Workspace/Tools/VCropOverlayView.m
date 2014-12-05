//
//  VCropOverlay.m
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCropOverlayView.h"

@implementation VCropOverlayView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        [[[UIColor blackColor] colorWithAlphaComponent:0.5f] setStroke];
        
        // First Vertical
        UIBezierPath *firstVertical = [UIBezierPath bezierPath];
        [firstVertical moveToPoint:CGPointMake(CGRectGetWidth(rect) * (1.0f/3.0f) , CGRectGetMinY(rect))];
        [firstVertical addLineToPoint:CGPointMake(CGRectGetWidth(rect) * (1.0f/3.0f), CGRectGetMaxY(rect))];
        firstVertical.lineWidth = 0.5;
        [firstVertical stroke];
        
        // Second Vertical
        UIBezierPath *secondVertical = [UIBezierPath bezierPath];
        [secondVertical moveToPoint:CGPointMake(CGRectGetWidth(rect) * (2.0f/3.0f), CGRectGetMinY(rect))];
        [secondVertical addLineToPoint:CGPointMake(CGRectGetWidth(rect) * (2.0f/3.0f), CGRectGetMaxY(rect))];
        secondVertical.lineWidth = 0.5;
        [secondVertical stroke];
        
        // First Horizontal
        UIBezierPath *firstHorizontal = [UIBezierPath bezierPath];
        [firstHorizontal moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetHeight(rect) * (1.0f/3.0f))];
        [firstHorizontal addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetHeight(rect) * (1.0f/3.0f))];
        firstHorizontal.lineWidth = 0.5;
        [firstHorizontal stroke];
        
        // Second Horizontal
        UIBezierPath *secondHorizontal = [UIBezierPath bezierPath];
        [secondHorizontal moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetHeight(rect) * (2.0f/3.0f))];
        [secondHorizontal addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetHeight(rect) * (2.0f/3.0f))];
        secondHorizontal.lineWidth = 0.5;
        [secondHorizontal stroke];
    }
    CGContextRestoreGState(context);
}

@end
