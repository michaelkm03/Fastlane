//
//  VTextBackgroundView.m
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextBackgroundView.h"

@implementation VTextBackgroundView

- (void)setBackgroundFrames:(NSArray *)backgroundFrames
{
    _backgroundFrames = backgroundFrames;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for ( NSValue *value in self.backgroundFrames )
    {
        CGRect frame = [value CGRectValue];
        CGContextAddRect( context, frame );
        CGContextSetFillColorWithColor( context, self.backgroundFrameColor.CGColor );
        CGContextFillRect( context, frame );
    }
}

@end
