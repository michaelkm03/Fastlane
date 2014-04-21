//
//  VStreamToCommentAnimator.m
//  victorious
//
//  Created by Will Long on 4/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToCommentAnimator.h"

#import "VStreamTableViewController.h"
#import "VCommentsContainerViewController.h"

#import "VStreamViewCell.h"

@implementation VStreamToCommentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VCommentsContainerViewController* commentVC = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];

    [streamVC.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:.4f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(streamVC.navigationController.navigationBar.center.x,
                                            streamVC.navigationController.navigationBar.center.y - streamVC.tableView.frame.size.height);
         streamVC.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];
         
         for (VStreamViewCell* cell in [streamVC.tableView visibleCells])
         {
             CGFloat centerPoint = streamVC.tableView.center.y + streamVC.tableView.contentOffset.y;
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
         [[context containerView] addSubview:commentVC.view];
         [context completeTransition:![context transitionWasCancelled]];
     }];
}

@end
