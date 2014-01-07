//
//  VAbstractStreamTableVieControllerViewController.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const kSearchCache;

@interface VAbstractStreamViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController* searchFetchedResultsController;
@property (strong, nonatomic) NSString* filterText;
@property (nonatomic) NSInteger scopeType;

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (UITableView*)tableViewForFetchedResultsController:(NSFetchedResultsController*)controller;

- (IBAction)displaySearchBar:(id)sender;
- (IBAction)refresh:(UIRefreshControl *)sender;

#pragma mark - Filtering
- (NSPredicate*)fetchResultsPredicate;
- (void)refreshFetchController:(NSFetchedResultsController*)controller
                 withPredicate:(NSPredicate*)predicate;

#pragma mark - Predicate Lifecycle
- (NSPredicate*)searchTextPredicate;
- (NSPredicate*)scopeTypePredicate;

#pragma mark - Cell Lifecycle
- (void)registerCells;

#pragma mark - Refresh Lifecycle
- (void)refreshAction;

@end
