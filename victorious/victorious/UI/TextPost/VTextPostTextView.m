//
//  VTextPostTextView.m
//  victorious
//
//  Created by Patrick Lynch on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostTextView.h"

@implementation VTextPostTextView

- (void)setBackgroundFrames:(NSArray *)backgroundFrames
{
    _backgroundFrames = backgroundFrames;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect( context, rect );
    
    for ( NSValue *value in self.backgroundFrames )
    {
        CGRect frame = [value CGRectValue];
        CGContextAddRect( context, frame );
        CGContextSetFillColorWithColor( context, self.backgroundFrameColor.CGColor );
        CGContextFillRect( context, frame );
    }
}

@end
