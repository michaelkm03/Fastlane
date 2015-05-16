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
    UIView *result = [super hitTest:point withEvent:event];
    if ( result == self )
    {
        if ( self.delegate != nil )
        {
            [self.delegate passthroughViewRecievedTouch:self];
        }
        return nil;
    }
    return result;
}

@end