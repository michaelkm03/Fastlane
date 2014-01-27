//
//  VFetchedResultsTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFetchedResultsTableViewController : UITableViewController   <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong)   NSFetchedResultsController*     fetchedResultsController;
@property (nonatomic, strong)   NSFetchedResultsController*     searchFetchedResultsController;

- (void)performFetch;

- (NSFetchedResultsController *)makeFetchedResultsController;
- (NSFetchedResultsController *)makeSearchFetchedResultsController;

- (IBAction)displaySearchBar:(id)sender;
- (void)hideSearchBar;

- (void)registerCells;
- (void)refreshAction;

- (NSPredicate*)searchPredicateForString:(NSString *)searchString;
- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption;

@end
