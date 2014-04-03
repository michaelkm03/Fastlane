//
//  VStreamViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"

typedef NS_ENUM(NSInteger, VStreamScope)
{
    VStreamFilterAll = 0,
    VStreamFilterImages,
    VStreamFilterVideos,
    VStreamFilterPolls
};

@interface VStreamTableViewController : VFetchedResultsTableViewController

- (NSArray*)categoriesForOption:(NSUInteger)searchOption;

- (IBAction)showMenu;

@property (strong, nonatomic) NSArray* repositionedCells;;

@end
