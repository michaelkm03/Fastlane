//
//  VCommentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 4/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentToStreamAnimator.h"

#import "VStreamContainerViewController.h"
#import "VCommentsContainerViewController.h"

@implementation VCommentToStreamAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController *)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC;
    
    if ([toVC isKindOfClass:[VStreamTableViewController class]])
    {
        streamVC = (VStreamTableViewController *)toVC;
    }
    else
    {
        streamVC = ((VStreamContainerViewController *)toVC).streamTable;
    }
    
    commentsContainer.view.userInteractionEnabled = NO;
    toVC.view.userInteractionEnabled = NO;
    
    
    [commentsContainer animateOutWithDuration:.2f
                                   completion:^(BOOL finished)
     {
         [[context containerView] addSubview:toVC.view];
         
         if ([toVC isKindOfClass:[VStreamContainerViewController class]])
         {
             [UIView animateWithDuration:.6f animations:^
              {
                  [(VStreamContainerViewController *)toVC v_showHeader];
              }];
         }
         
         [streamVC animateInWithDuration:.6f completion:^(BOOL finished)
          {
              commentsContainer.view.userInteractionEnabled = YES;
              toVC.view.userInteractionEnabled = YES;
              
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
