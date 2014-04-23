//
//  VStreamToAnythingAnimator.m
//  victorious
//
//  Created by Will Long on 4/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToContentAnimator.h"

#import "VStreamTableViewController.h"
#import "VStreamViewCell.h"

#import "VContentViewController.h"

#import "VSequence+Fetcher.h"

@implementation VStreamToContentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VContentViewController* contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    [streamVC.navigationController setNavigationBarHidden:NO animated:YES];
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];
    

    [streamVC animateOutWithDuration:.4f
                          completion:^(BOOL finished)
     {
         contentVC.sequence = selectedCell.sequence;
         
         [UIView animateWithDuration:.2f
                          animations:^
          {
              selectedCell.overlayView.alpha = selectedCell.shadeView.alpha = 0;
              selectedCell.overlayView.center = CGPointMake(selectedCell.overlayView.center.x,
                                                            selectedCell.overlayView.center.y - selectedCell.frame.size.height);
              
          }
                          completion:^(BOOL finished)
          {
              [[context containerView] addSubview:contentVC.view];
              
              CGRect topActionsFrame = contentVC.topActionsView.frame;
              contentVC.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), CGRectGetMinY(contentVC.mediaView.frame),
                                                     CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
              
              contentVC.orImageView.hidden = ![contentVC.sequence isPoll];
              contentVC.orImageView.center = [contentVC.pollPreviewView convertPoint:contentVC.pollPreviewView.center toView:contentVC.orContainerView];
              
              contentVC.firstPollButton.alpha = 0;
              contentVC.secondPollButton.alpha = 0;
              
              contentVC.topActionsView.alpha = 0;
              [UIView animateWithDuration:.2f
                               animations:^
               {
                   contentVC.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), 0, CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
                   contentVC.topActionsView.alpha = 1;
                   contentVC.firstPollButton.alpha = 1;
                   contentVC.secondPollButton.alpha = 1;
               }
                               completion:^(BOOL finished)
               {
                   contentVC.actionBarVC = nil;
                   [context completeTransition:![context transitionWasCancelled]];
               }];
          }];
     }];
}

@end
