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
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VContentViewController *contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];

    [contentVC.emotiveBallisticsBar animateOut];
    
    [self performSelector:@selector(secondAnimation:) withObject:context afterDelay:.4f];
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
    
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];

    [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x,
                                                     selectedCell.frame.origin.y - kContentMediaViewOffset)
                                animated:NO];

    [UIView animateWithDuration:.2f
                     animations:^
     {
         selectedCell.overlayView.alpha = 1;
         selectedCell.shadeView.alpha = 1;
         selectedCell.overlayView.center = CGPointMake(selectedCell.overlayView.center.x,
                                                       selectedCell.overlayView.center.y + selectedCell.frame.size.height);
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
                                  if (cell != selectedCell)
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
                              CGFloat maxOffset = streamVC.tableView.contentSize.height - streamVC.tableView.frame.size.height;
                              
                              if (streamVC.tableView.contentOffset.y < 0)
                              {
                                  [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x, 0) animated:YES];
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
