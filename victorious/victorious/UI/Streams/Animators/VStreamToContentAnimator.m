//
//  VStreamToAnythingAnimator.m
//  victorious
//
//  Created by Will Long on 4/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToContentAnimator.h"

#import "VStreamContainerViewController.h"
#import "VStreamTableDataSource.h"
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
    id fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamTableViewController *streamVC = [fromVC isKindOfClass:[VStreamTableViewController class]] ? fromVC
                                                    : ((VStreamContainerViewController *)fromVC).streamTable;
    
    VContentViewController* contentVC = (VContentViewController *)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    NSIndexPath* path = [streamVC.tableDataSource indexPathForSequence:streamVC.selectedSequence];
    VStreamViewCell* selectedCell = (VStreamViewCell *) [streamVC.tableView cellForRowAtIndexPath:path];
    
    streamVC.view.userInteractionEnabled = NO;
    contentVC.view.userInteractionEnabled = NO;

    [streamVC animateOutWithDuration:.4f
                          completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.2f
                          animations:^
          {
              [selectedCell hideOverlays];
          }
                          completion:^(BOOL finished)
          {
              [[context containerView] addSubview:contentVC.view];
              
              if (selectedCell)
              {
                  contentVC.sequence = selectedCell.sequence;
              }
              else
              {
                  contentVC.sequence = contentVC.sequence;
              }
              
              [contentVC animateInWithDuration:.2f
                                    completion:^(BOOL finished)
               {
                   contentVC.actionBarVC = nil;
                   streamVC.view.userInteractionEnabled = YES;
                   contentVC.view.userInteractionEnabled = YES;
                   [context completeTransition:![context transitionWasCancelled]];
               }];
          }];
     }];
}

@end
