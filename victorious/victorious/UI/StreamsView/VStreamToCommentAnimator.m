//
//  VStreamToCommentAnimator.m
//  victorious
//
//  Created by Will Long on 4/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToCommentAnimator.h"

#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"
#import "VCommentsContainerViewController.h"

#import "VStreamViewCell.h"

@implementation VStreamToCommentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VStreamContainerViewController* container = (VStreamContainerViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamTableViewController *streamVC = container.streamTable;
    VCommentsContainerViewController* commentVC = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    container.view.userInteractionEnabled = NO;
    commentVC.view.userInteractionEnabled = NO;
    
     [streamVC animateOutWithDuration:.4f
                           completion:^(BOOL finished)
     {
         [[context containerView] addSubview:commentVC.view];
         [commentVC animateInWithDuration:.4f
                               completion:^(BOOL finished)
          {
              container.view.userInteractionEnabled = YES;
              commentVC.view.userInteractionEnabled = YES;
             [context completeTransition:![context transitionWasCancelled]];
         }];
     }];
}

@end
