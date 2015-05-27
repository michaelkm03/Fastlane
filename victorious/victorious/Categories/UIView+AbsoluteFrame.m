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
    UIView *superview = self.superview;
    if ( superview == nil )
    {
        return self.frame;
    }
    while ( superview.superview != nil )
    {
        superview = superview.superview;
    }
    return [self.superview convertRect:self.frame toView:superview];
}

- (CGPoint)absoluteOrigin
{
    UIView *superview = self.superview;
    if ( superview == nil )
    {
        return self.frame.origin;
    }
    while ( superview.superview != nil )
    {
        superview = superview.superview;
    }
    return [self.superview convertPoint:self.frame.origin toView:superview];
}

@end
