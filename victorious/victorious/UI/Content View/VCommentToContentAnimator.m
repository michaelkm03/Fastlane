//
//  VCommentToContentAnimator.m
//  victorious
//
//  Created by Will Long on 3/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentToContentAnimator.h"

#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"
#import "VRootViewController.h"

@implementation VCommentToContentAnimator


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    VContentViewController* contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
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
         [UIView animateWithDuration:.25f
                          animations:^{
                              for (UIView* view in contentVC.view.subviews)
                              {
                                  if ([view isKindOfClass:[UIImageView class]])
                                      continue;
                                  
                                  if (view.center.y > contentVC.view.center.y)
                                  {
                                      view.center = CGPointMake(view.center.x, view.center.y - contentVC.view.frame.size.height);
                                  }
                                  else
                                  {
                                      view.center = CGPointMake(view.center.x, view.center.y + contentVC.view.frame.size.height);
                                  }
                              }
                          }
                          completion:^(BOOL finished) {
                              [context completeTransition:YES]; // vital
                          }];
     }];
}
     
@end
