//
//  VFormValidationTextField.m
//  victorious
//
//  Created by Patrick Lynch on 2/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFormValidationTextField.h"

@implementation VFormValidationTextField

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth( context, 2.0 );
    CGContextSetStrokeColorWithColor( context, self.separatorColor.CGColor );
    CGContextMoveToPoint( context, CGRectGetMinX(rect), CGRectGetMaxY(rect) );
    CGContextAddLineToPoint( context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) );
    CGContextStrokePath( context );
}

@end
