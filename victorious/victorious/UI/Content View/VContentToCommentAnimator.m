//
//  VContentToCommentAnimator.m
//  victorious
//
//  Created by Will Long on 4/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToCommentAnimator.h"

#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"

@implementation VContentToCommentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VContentViewController* contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];

    [UIView animateWithDuration:.5f
                     animations:^
     {
         for (UIView* view in contentVC.view.subviews)
         {
             if ([view isKindOfClass:[UIImageView class]])
                 continue;
             
             if (view.center.y > contentVC.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y + contentVC.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y - contentVC.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         [[context containerView] addSubview:commentsContainer.view];
         
         [UIView animateWithDuration:.25f
                          animations:^
          {
              for (UIView* view in commentsContainer.view.subviews)
              {
                  if ([view isKindOfClass:[UIImageView class]])
                      continue;
                  
                  if (view.center.y > commentsContainer.view.center.y)
                  {
                      view.center = CGPointMake(view.center.x, view.center.y + commentsContainer.view.frame.size.height);
                  }
                  else
                  {
                      view.center = CGPointMake(view.center.x, view.center.y - commentsContainer.view.frame.size.height);
                  }
              }
          }
                          completion:^(BOOL finished)
          {
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
