//
//  VStreamToAnythingAnimator.m
//  victorious
//
//  Created by Will Long on 4/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToAnythingAnimator.h"

#import "VStreamTableViewController.h"
#import "VStreamViewCell.h"

#import "VContentViewController.h"

@implementation VStreamToAnythingAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];    
    VContentViewController* contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];
    
    contentVC.sequence = selectedCell.sequence;
    
    [UIView animateWithDuration:.2f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(streamVC.navigationController.navigationBar.center.x,
                                            streamVC.navigationController.navigationBar.center.y - streamVC.tableView.frame.size.height);
         streamVC.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];
         
         for (VStreamViewCell* cell in [streamVC.tableView visibleCells])
         {
             if (cell != selectedCell)
             {
                 if (cell.center.y > selectedCell.center.y)
                 {
                     cell.center = CGPointMake(cell.center.x, cell.center.y + streamVC.tableView.frame.size.height);
                 }
                 else
                 {
                     cell.center = CGPointMake(cell.center.x, cell.center.y - streamVC.tableView.frame.size.height);
                 }
                 [repositionedCells addObject:cell];
             }
         }
         streamVC.repositionedCells = repositionedCells;
     }
                     completion:^(BOOL finished)
     {
         //Skip this animation if we aren't going to a content view
         if ([contentVC isKindOfClass:[VContentViewController class]])
         {
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
                  [context completeTransition:![context transitionWasCancelled]];
              }];
         }
         else
         {
             [[context containerView] addSubview:contentVC.view];
//             [context completeTransition:![context transitionWasCancelled]];
             [context completeTransition:YES];
         }
     }];
}

@end
