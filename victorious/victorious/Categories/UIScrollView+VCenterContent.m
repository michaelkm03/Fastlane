//
//  UIScrollView+VCenterContent.m
//  victorious
//
//  Created by Michael Sena on 2/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIScrollView+VCenterContent.h"

@implementation UIScrollView (VCenterContent)

- (void)v_centerContentAnimated:(BOOL)animated
{
    CGRect desiredVisibleRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    if (self.contentSize.height > self.contentSize.width)
    {
        desiredVisibleRect.origin.y = (self.contentSize.height * 0.5f) - (CGRectGetHeight(self.frame) * 0.5f);
    }
    else
    {
        desiredVisibleRect.origin.x = (self.contentSize.width * 0.5f) - (CGRectGetWidth(self.frame) * 0.5f);
    }
    [self scrollRectToVisible:desiredVisibleRect
                     animated:animated];
}

@end
