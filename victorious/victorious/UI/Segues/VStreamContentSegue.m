//
//  VStreamContentSegue.m
//  victorious
//
//  Created by Will Long on 3/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContentSegue.h"

#import "VStreamTableViewController.h"
#import "VContentViewController.h"

#import "VStreamViewCell.h"
#import "VStreamPollCell.h"

#import "UIImageView+Blurring.h"
#import "UIView+VFrameManipulation.h"

#import "VSequence+Fetcher.h"

@interface VStreamContentSegue ()

@property (strong, nonatomic) NSMutableArray* upperCells;
@property (strong, nonatomic) NSMutableArray* bottomCells;

@end

@implementation VStreamContentSegue

- (void)perform
{
    //Custom animation code
    VStreamTableViewController* tableVC = self.sourceViewController;
    VContentViewController* contentVC = self.destinationViewController;
    
    //Sanity check that this is a stream table
    if (![tableVC isKindOfClass:[VStreamTableViewController class]])
    {
        [tableVC presentViewController:contentVC animated:NO completion:nil];
        return;
    }
    
    [UIView animateWithDuration:.2f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(tableVC.navigationController.navigationBar.center.x,
                                            tableVC.navigationController.navigationBar.center.y - tableVC.tableView.frame.size.height);
         tableVC.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];
         
         for (VStreamViewCell* cell in [tableVC.tableView visibleCells])
         {
             if (cell != self.selectedCell)
             {
                 if (cell.center.y > self.selectedCell.center.y)
                 {
                     cell.center = CGPointMake(cell.center.x, cell.center.y + tableVC.tableView.frame.size.height);
                 }
                 else
                 {
                     cell.center = CGPointMake(cell.center.x, cell.center.y - tableVC.tableView.frame.size.height);
                 }
                 [repositionedCells addObject:cell];
             }
         }
         tableVC.repositionedCells = repositionedCells;
     }
                     completion:^(BOOL finished)
     {
         //Skip this animation if we aren't going to a content view
         if ([contentVC isKindOfClass:[VContentViewController class]])
         {
             [UIView animateWithDuration:.2f
                              animations:^
              {
                  self.selectedCell.overlayView.alpha = self.selectedCell.shadeView.alpha = 0;
                  self.selectedCell.overlayView.center = CGPointMake(self.selectedCell.overlayView.center.x,
                                                                     self.selectedCell.overlayView.center.y - self.selectedCell.frame.size.height);
              }
                              completion:^(BOOL finished)
              {
                  [contentVC.previewImage setSize:self.selectedCell.previewImageView.image.size];
                  [tableVC presentViewController:contentVC animated:NO completion:nil];
              }];
         }
         else
         {
             [contentVC.navigationController setNavigationBarHidden:YES animated:NO];
             [tableVC presentViewController:contentVC animated:YES completion:nil];
         }
     }];
}


@end
