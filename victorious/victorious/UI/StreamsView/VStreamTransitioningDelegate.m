//
//  VStreamTransitioningDelegate.m
//  victorious
//
//  Created by Will Long on 3/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTransitioningDelegate.h"

#import "VContentToStreamAnimator.h"

@implementation VStreamTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    VContentToStreamAnimator *animator = [[VContentToStreamAnimator alloc] init];
    animator.indexPathForSelectedCell = self.indexPathForSelectedCell;
    return animator;
}

@end
