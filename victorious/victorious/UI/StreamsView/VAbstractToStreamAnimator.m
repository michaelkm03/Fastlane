//
//  VAbstractToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 4/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractToStreamAnimator.h"

#import "VStreamTableViewController.h"
#import "VContentViewController.h"
#import "VStreamViewCell.h"

@implementation VAbstractToStreamAnimator

- (void)animateToStream:(id<UIViewControllerContextTransitioning>)context
{
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (![streamVC isKindOfClass:[VStreamTableViewController class]])
    {
        [context completeTransition:![context transitionWasCancelled]];
        return;
    }
    
    [[context containerView] addSubview:streamVC.view];
    
    VStreamViewCell* selectedCell = (VStreamViewCell*) [streamVC.tableView cellForRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow];
    
    //If the tableview updates while we are in the content view it will reset the cells to their proper positions.
    //In this case, we reset them
    for (VStreamViewCell* cell in streamVC.repositionedCells)
    {
        if ([fromVC isKindOfClass:[VContentViewController class]] && cell == selectedCell)
        {
            continue;
        }
        
        CGFloat centerPoint = selectedCell ? selectedCell.center.y : streamVC.tableView.center.y + streamVC.tableView.contentOffset.y;
        CGRect cellRect = [streamVC.tableView convertRect:cell.frame toView:streamVC.tableView.superview];
        if (CGRectIntersectsRect(streamVC.tableView.frame, cellRect))
        {
            if (cell.center.y > centerPoint)
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y + streamVC.tableView.frame.size.height);
            }
            else
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y - streamVC.tableView.frame.size.height);
            }
        }
    }
    
    [UIView animateWithDuration:.2f
                     animations:^
     {
         [selectedCell showOverlays];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.2f
                          animations:^
          {
              for (VStreamViewCell* cell in streamVC.repositionedCells)
              {
                  if ([fromVC isKindOfClass:[VContentViewController class]] && cell == selectedCell)
                  {
                      continue;
                  }

                  CGFloat centerPoint = selectedCell ? selectedCell.center.y : streamVC.tableView.center.y + streamVC.tableView.contentOffset.y;
                  CGRect cellRect = [streamVC.tableView convertRect:cell.frame toView:streamVC.tableView.superview];
                  if (!CGRectIntersectsRect(streamVC.tableView.frame, cellRect))
                  {
                      if (cell.center.y > centerPoint)
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
                  [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x, 0) animated:YES];
              }
              else if (streamVC.tableView.contentOffset.y >= maxOffset)
              {
                  [streamVC.tableView setContentOffset:CGPointMake(selectedCell.frame.origin.x, maxOffset) animated:YES];
              }
          }
                          completion:^(BOOL finished)
          {
              streamVC.repositionedCells = nil;
              
              if (selectedCell)
              {
                  [streamVC.tableView deselectRowAtIndexPath:streamVC.tableView.indexPathForSelectedRow animated:NO];
              }
              
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
