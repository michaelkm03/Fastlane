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
    
    [UIView animateWithDuration:.4f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(streamVC.navigationController.navigationBar.center.x,
                                            streamVC.navigationController.navigationBar.center.y - streamVC.tableView.frame.size.height);
         streamVC.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];
         
         for (VStreamViewCell* cell in [streamVC.tableView visibleCells])
         {
             if ([contentVC isKindOfClass:[VContentViewController class]] && cell == selectedCell)
             {
                 continue;
             }
             
             CGFloat centerPoint = [contentVC isKindOfClass:[VContentViewController class]] ? selectedCell.center.y
             : streamVC.tableView.center.y + streamVC.tableView.contentOffset.y;
             if (cell.center.y > centerPoint)
             {
                 cell.center = CGPointMake(cell.center.x, cell.center.y + [UIScreen mainScreen].bounds.size.height);
             }
             else
             {
                 cell.center = CGPointMake(cell.center.x, cell.center.y - [UIScreen mainScreen].bounds.size.height);
             }
             [repositionedCells addObject:cell];
         }
         streamVC.repositionedCells = repositionedCells;
     }
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
              contentVC.topActionsView.frame = CGRectMake(CGRectGetMinX(topActionsFrame), CGRectGetMinY(contentVC.mediaView.frame), CGRectGetWidth(topActionsFrame), CGRectGetHeight(topActionsFrame));
              
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
