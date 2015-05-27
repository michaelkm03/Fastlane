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
    return [superview convertRect:self.frame toView:self.window];
}

- (CGPoint)absoluteOrigin
{
    UIView *superview = self.superview;
    if ( superview == nil )
    {
        return self.frame.origin;
    }
    return [superview convertPoint:self.frame.origin toView:self.window];
}

@end
