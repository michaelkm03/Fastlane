//
//  VContentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 3/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToStreamAnimator.h"

#import "VRootViewController.h"
#import "VStreamTableViewController.h"
#import "VContentViewController.h"

#import "VStreamViewCell.h"

#import "VEmotiveBallisticsBarViewController.h"

#import "UIView+VFrameManipulation.h"

@interface VContentToStreamAnimator ()

@property (strong, nonatomic) VStreamTableViewController* streamVC;
@property (strong, nonatomic) UIViewController* originalStreatSuperview;

@end

@implementation VContentToStreamAnimator 

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];

    VRootViewController* rootVC = (VRootViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC = (VStreamTableViewController*)((UINavigationController*)rootVC.contentViewController).topViewController;
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:self.indexPathForSelectedCell];
   
    
    
    [UIView animateWithDuration:.2f animations:^
    {
        contentVC.orImageView.alpha = 0;
        [contentVC.previewImage setSize:selectedCell.frame.size];
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
    
    [UIView animateWithDuration:.2
                     animations:^
     {
         [contentVC.topActionsView setYOrigin:contentVC.mediaView.frame.origin.y];
         contentVC.topActionsView.alpha = 0;
     }
                     completion:^(BOOL finished) {
                         [self thirdAnimation:context];
                         contentVC.view.hidden = YES;
                     }];
}

- (void)thirdAnimation:(id<UIViewControllerContextTransitioning>)context
{
    VRootViewController* rootVC = (VRootViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamTableViewController *streamVC = (VStreamTableViewController*)((UINavigationController*)rootVC.contentViewController).topViewController;
    if (![streamVC isKindOfClass:[VStreamTableViewController class]])
    {
        [context completeTransition:YES]; // vital
        return;
    }
    
    __block UIView* originalSuperView = streamVC.view.superview;
    
    [[context containerView] addSubview:streamVC.view];
    
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:self.indexPathForSelectedCell];

    [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x,
                                                     selectedCell.frame.origin.y - kContentMediaViewOffset)
                                animated:NO];
    
    //If the tableview updates while we are in the content view it will reset the cells to their proper positions.
    //In this case, we reset them
    for (VStreamViewCell* cell in [streamVC.tableView visibleCells])
    {
        CGRect cellRect = [streamVC.tableView convertRect:cell.frame toView:streamVC.tableView.superview];
        if (cell != selectedCell && CGRectIntersectsRect(streamVC.tableView.frame, cellRect))
        {
            if (cell.center.y > selectedCell.center.y)
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y + streamVC.tableView.frame.size.height);
            }
            else
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y - streamVC.tableView.frame.size.height);
            }
        }
    }
    selectedCell.overlayView.alpha = 0;
    selectedCell.shadeView.alpha = 0;
    selectedCell.animationImage.alpha = 0;
    selectedCell.overlayView.center = CGPointMake(selectedCell.center.x,
                                                  selectedCell.center.y - selectedCell.frame.size.height);
    
    [UIView animateWithDuration:.2f
                     animations:^
     {
         selectedCell.overlayView.alpha = 1;
         selectedCell.shadeView.alpha = 1;
         selectedCell.animationImage.alpha = 1;
         selectedCell.overlayView.center = CGPointMake(selectedCell.center.x,
                                                       selectedCell.center.y + selectedCell.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.2f
                          animations:^{
                              CGPoint newNavCenter = CGPointMake(streamVC.navigationController.navigationBar.center.x,
                                                                 streamVC.navigationController.navigationBar.center.y + streamVC.tableView.frame.size.height);
                              streamVC.navigationController.navigationBar.center = newNavCenter;
                              
                              for (VStreamViewCell* cell in [streamVC.tableView visibleCells])
                              {
                                  CGRect cellRect = [streamVC.tableView convertRect:cell.frame toView:streamVC.tableView.superview];
                                  if (cell != selectedCell && !CGRectIntersectsRect(streamVC.tableView.frame, cellRect))
                                  {
                                      if (cell.center.y > selectedCell.center.y)
                                      {
                                          cell.center = CGPointMake(cell.center.x, cell.center.y - streamVC.tableView.frame.size.height);
                                      }
                                      else
                                      {
                                          cell.center = CGPointMake(cell.center.x, cell.center.y + streamVC.tableView.frame.size.height);
                                      }
                                  }
                              }
                              
                              CGFloat minOffset = streamVC.navigationController.navigationBar.frame.size.height;
                              CGFloat maxOffset = streamVC.tableView.contentSize.height - streamVC.tableView.frame.size.height;
                              
                              if (streamVC.tableView.contentOffset.y < minOffset)
                              {
//                                  [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x, minOffset) animated:YES];
                              }
                              else if (streamVC.tableView.contentOffset.y >= maxOffset)
                              {
                                  [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x,
                                                                                   maxOffset)
                                                              animated:YES];
                              }
                          }
                          completion:^(BOOL finished)
          {
              if (selectedCell)
              {
                  [streamVC.tableView deselectRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow animated:NO];
              }
              [originalSuperView addSubview:streamVC.view];
              [context completeTransition:YES]; // vital
          }];
     }];
}

@end
