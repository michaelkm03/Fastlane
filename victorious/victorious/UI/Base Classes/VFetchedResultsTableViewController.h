//
//  VFetchedResultsTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFetchedResultsTableViewController : UITableViewController

@property (nonatomic, copy) NSString* cellIdentifier;

- (void)performFetch;

- (NSFetchedResultsController *)makeFetchedResultsController;
- (NSFetchedResultsController *)makeSearchFetchedResultsController;

- (void)registerCells;
- (void)refreshAction;

- (NSPredicate*)searchPredicateForString:(NSString *)searchString;
- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption;

@end
