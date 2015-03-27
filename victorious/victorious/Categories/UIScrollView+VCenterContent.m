//
//  UIScrollView+VCenterContent.m
//  victorious
//
//  Created by Michael Sena on 2/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIScrollView+VCenterContent.h"

@implementation UIScrollView (VCenterContent)

- (void)v_centerZoomedContentAnimated:(BOOL)animated
{
    if (![self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        return;
    }
    
    UIView *zoomingView = [self.delegate viewForZoomingInScrollView:self];
    
    CGFloat magnitude = 0.0f;
    if (CGRectGetWidth(zoomingView.bounds) > CGRectGetHeight(zoomingView.bounds))
    {
        magnitude = CGRectGetHeight(zoomingView.bounds);
    }
    else
    {
        magnitude = CGRectGetWidth(zoomingView.bounds);
    }
    
    [self zoomToRect:CGRectMake(CGRectGetMidX(zoomingView.bounds) - (magnitude/2),
                                                 CGRectGetMidY(zoomingView.bounds) - (magnitude/2),
                                                 magnitude,
                                                 magnitude)
                             animated:animated];
}

@end
