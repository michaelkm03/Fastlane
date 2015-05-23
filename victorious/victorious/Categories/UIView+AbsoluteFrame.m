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
    return [self.superview convertRect:self.frame toView:nil];
}

- (CGPoint)absoluteOrigin
{
    return [self.superview convertPoint:self.frame.origin toView:nil];
}

@end
