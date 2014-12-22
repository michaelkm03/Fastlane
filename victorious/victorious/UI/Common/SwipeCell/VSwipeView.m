//
//  VSwipeView.m
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeView.h"

@implementation VSwipeView

#pragma mark - UIView overrides

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( CGRectContainsPoint( self.activeOutOfBoundsArea, point) )
    {
        return YES;
    }
    
    return [super pointInside:point withEvent:event];
}

@end
