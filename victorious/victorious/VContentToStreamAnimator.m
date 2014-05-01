//
//  VContentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 3/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToStreamAnimator.h"

#import "VStreamTableViewController.h"
#import "VContentViewController.h"

#import "VStreamViewCell.h"

#import "VActionBarViewController.h"

@implementation VContentToStreamAnimator 

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];
    
    [UIView animateWithDuration:.2f animations:^
    {
        CGRect frame = contentVC.previewImage.frame;
        contentVC.previewImage.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(selectedCell.frame), CGRectGetHeight(selectedCell.frame));
    }];
    
    [contentVC.actionBarVC animateOutWithDuration:.2f
                                       completion:^(BOOL finished)
                                        {
                                            [self secondAnimation:context];
                                        }];
}

- (void)secondAnimation:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:.2
                     animations:^
     {
         CGRect frame = contentVC.topActionsView.frame;
         contentVC.topActionsView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(contentVC.mediaView.frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
         contentVC.topActionsView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];
         [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x,
                                                          selectedCell.frame.origin.y - kContentMediaViewOffset)
                                     animated:NO];
         
         [[context containerView] addSubview:streamVC.view];
         [streamVC animateInWithDuration:.4f completion:^(BOOL finished)
          {
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
