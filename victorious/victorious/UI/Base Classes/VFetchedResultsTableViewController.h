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
@property (nonatomic, strong)   UIActivityIndicatorView*        bottomRefreshIndicator;

- (void)performFetch;

- (NSFetchedResultsController *)makeFetchedResultsController;
- (void)refreshFetchController;

- (void)registerCells;
- (void)refreshAction;

@end
