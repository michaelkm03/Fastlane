//
//  VContentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 3/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToStreamAnimator.h"

#import "VStreamContainerViewController.h"
#import "VStreamTableViewController.h"
#import "VContentViewController.h"
#import "VContentViewController+Videos.h"

#import "VStreamViewCell.h"

#import "VActionBarViewController.h"

@implementation VContentToStreamAnimator 

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamContainerViewController* container = (VStreamContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC = container.streamTable;

    
    streamVC.view.userInteractionEnabled = NO;
    contentVC.view.userInteractionEnabled = NO;
    
    if ([contentVC isVideoLoadingOrLoaded])
    {
        [contentVC unloadVideoWithDuration:0.2f completion:nil];
    }
    
    [contentVC.actionBarVC animateOutWithDuration:.2f
                                       completion:^(BOOL finished)
                                        {
                                            [self secondAnimation:context];
                                        }];
}

- (void)secondAnimation:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamContainerViewController* container = (VStreamContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC = container.streamTable;
    
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
         
         [[context containerView] addSubview:container.view];
         [streamVC animateInWithDuration:.4f completion:^(BOOL finished)
          {
              [UIView animateWithDuration:.2f
                               animations:^
               {
                   [container showHeader];
               }
                               completion:^(BOOL finished)
               {
                   streamVC.view.userInteractionEnabled = YES;
                   contentVC.view.userInteractionEnabled = YES;
                   
                   [context completeTransition:![context transitionWasCancelled]];
               }];
          }];
     }];
}

@end
