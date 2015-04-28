//
//  VPassthroughContainerView.m
//  victorious
//
//  Created by Patrick Lynch on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPassthroughContainerView.h"

@implementation VPassthroughContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for ( UIView *subview in self.subviews )
    {
        if ( !subview.userInteractionEnabled )
        {
            continue;
        }
        
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        UIView *result = [subview hitTest:subPoint withEvent:event];
        
        if ( result != nil )
        {
            return result;
        }
    }
    return nil;
}

@end