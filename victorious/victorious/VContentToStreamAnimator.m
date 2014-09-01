//
//  VContentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 3/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToStreamAnimator.h"

#import "VStreamContainerViewController.h"
#import "VStreamTableDataSource.h"
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
    
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toVC.view.userInteractionEnabled = NO;
    contentVC.view.userInteractionEnabled = NO;
    
    if ([contentVC isVideoLoadingOrLoaded])
    {
        [contentVC unloadVideoAnimated:YES withDuration:0.2f completion:nil];
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^(void)
    {
        contentVC.leftSmallPreviewImageWidthConstraint.constant = 160.0f;
        contentVC.rightSmallPreviewImageWidthConstraint.constant = 160.0f;
        [contentVC.pollPreviewView layoutIfNeeded];
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
    
    UIViewController* toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC;
    
    if ([toVC isKindOfClass:[VStreamTableViewController class]])
        streamVC = (VStreamTableViewController*)toVC;
    else
        streamVC = ((VStreamContainerViewController*)toVC).streamTable;

    
    [UIView animateWithDuration:.2
                     animations:^
     {
         CGRect frame = contentVC.topActionsView.frame;
         contentVC.topActionsView.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(contentVC.mediaView.frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
         contentVC.topActionsView.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         NSIndexPath* path = [streamVC.tableDataSource indexPathForSequence:contentVC.sequence];
         //Reselect the cell; it will be unselected if the fetched results controller was updated
         [streamVC.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
         
         VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:path];
         [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x,
                                                          selectedCell.frame.origin.y - [contentVC contentMediaViewOffset])
                                     animated:NO];
         
         [[context containerView] addSubview:toVC.view];
         
         [streamVC animateInWithDuration:.4f completion:^(BOOL finished)
          {
              if ([toVC isKindOfClass:[VStreamContainerViewController class]])
              {
                  [UIView animateWithDuration:.2f
                                   animations:^
                   {
                       [(VStreamContainerViewController*)toVC showHeader];
                   }
                                   completion:^(BOOL finished)
                   {
                       toVC.view.userInteractionEnabled = YES;
                       contentVC.view.userInteractionEnabled = YES;
                       [[[(VStreamContainerViewController*)toVC tableViewController] tableView] setBackgroundView:nil];
                       [context completeTransition:![context transitionWasCancelled]];
                   }];
              }
              else
              {
                  toVC.view.userInteractionEnabled = YES;
                  contentVC.view.userInteractionEnabled = YES;
                  
                  [context completeTransition:![context transitionWasCancelled]];
              }
          }];
     }];
}

@end
