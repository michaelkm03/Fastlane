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

#import "VSequence.h"

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
    
    //Sanity check that this is a stream table and a content VC
    if (![tableVC isKindOfClass:[VStreamTableViewController class]] || ![contentVC isKindOfClass:[VContentViewController class]])
    {
        [self.sourceViewController presentModalViewController:self.destinationViewController animated:YES];
        return;
    }
    
    self.upperCells = [[NSMutableArray alloc] initWithCapacity:5];
    self.bottomCells = [[NSMutableArray alloc] initWithCapacity:5];
    
    __block UIView* oldBackgroundView = tableVC.tableView.backgroundView;
    UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:oldBackgroundView.frame];
    [newBackgroundView setLightBlurredImageWithURL:[NSURL URLWithString:self.selectedCell.sequence.previewImage]
                                  placeholderImage:nil];
    tableVC.tableView.backgroundView = newBackgroundView;
    [UIView animateWithDuration:.5f
                     animations:^
                     {
                         CGPoint newNavCenter = CGPointMake(tableVC.navigationController.navigationBar.center.x,
                                                            tableVC.navigationController.navigationBar.center.y - tableVC.tableView.frame.size.height);
                         tableVC.navigationController.navigationBar.center = newNavCenter;
                         
                         for (VStreamViewCell* cell in [tableVC.tableView visibleCells])
                         {
                             if (cell != self.selectedCell)
                             {
                                 if (cell.center.y > self.selectedCell.center.y)
                                 {
                                     [self.bottomCells addObject:cell];
                                     cell.center = CGPointMake(cell.center.x, cell.center.y + tableVC.tableView.frame.size.height);
                                 }
                                 else
                                 {
                                     [self.upperCells addObject:cell];
                                     cell.center = CGPointMake(cell.center.x, cell.center.y - tableVC.tableView.frame.size.height);
                                 }
                             }
                         }
                     }
                     completion:^(BOOL finished)
                     {
                         [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
                         
                         //return the cells back to their previous spots
                         for (VStreamViewCell* cell in self.bottomCells)
                             cell.center = CGPointMake(cell.center.x, cell.center.y - tableVC.tableView.frame.size.height);

                         for (VStreamViewCell* cell in self.upperCells)
                             cell.center = CGPointMake(cell.center.x, cell.center.y + tableVC.tableView.frame.size.height);
                         
                         CGPoint oldNavCenter = CGPointMake(tableVC.navigationController.navigationBar.center.x,
                                                            tableVC.navigationController.navigationBar.center.y + tableVC.tableView.frame.size.height);
                         tableVC.navigationController.navigationBar.center = oldNavCenter;
                         tableVC.tableView.backgroundView = oldBackgroundView;
                     }];
//    
//    //Add the destination as a modal
//    [self performSelector:@selector(finish) withObject:nil afterDelay:1.0f];
}

- (void)finish
{
//    [self.navigationController pushViewController:self.destinationViewController animated:YES];

    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
}

@end
