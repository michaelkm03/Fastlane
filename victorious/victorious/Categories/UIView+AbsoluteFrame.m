//
//  UIView+AbsoluteFrame.m
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIView+AbsoluteFrame.h"

@implementation UIView (AbsoluteFrame)

- (CGRect)absoluteFrame
{
    CGRect frame = self.frame;
    frame.origin = [self absoluteOrigin];
    return frame;
}

- (CGPoint)absoluteOrigin
{
    UIView *currentView = self;
    CGRect frame = currentView.frame;
    currentView = currentView.superview;
    while ( currentView != nil )
    {
        frame.origin.x += CGRectGetMinX(currentView.frame);
        frame.origin.y += CGRectGetMinY(currentView.frame);
        currentView = currentView.superview;
    }
    return frame.origin;
}

@end
