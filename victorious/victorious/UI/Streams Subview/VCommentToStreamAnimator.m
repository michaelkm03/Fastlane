//
//  VCommentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 4/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentToStreamAnimator.h"

#import "VStreamTableViewController.h"
#import "VCommentsContainerViewController.h"

@implementation VCommentToStreamAnimator


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    __block CGRect frame = commentsContainer.conversationTableViewController.view.frame;
    frame.origin.x = 0;
    commentsContainer.conversationTableViewController.view.frame = frame;
    
    [UIView animateWithDuration:.25f
                     animations:^
     {
         frame.origin.x = CGRectGetWidth(commentsContainer.conversationTableViewController.view.frame);
         commentsContainer.conversationTableViewController.view.frame = frame;
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
         [self animateToStream:context];
         frame.origin.x = 0;
         commentsContainer.conversationTableViewController.view.frame = frame;
     }];
    
}

@end
