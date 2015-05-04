//
//  VFetchedResultsTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFetchedResultsTableViewController : UITableViewController   <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong)   NSFetchedResultsController     *fetchedResultsController;
@property (nonatomic, strong)   UIActivityIndicatorView        *bottomRefreshIndicator;

@property (nonatomic, weak) id<UITableViewDelegate>delegate;

- (void)performFetch;

- (NSFetchedResultsController *)makeFetchedResultsController;
- (void)refreshFetchController;

- (void)clearFetchControllerWithSuccess:(void (^)(void))successBlock andFailure:(void (^)(NSError *))failureBlock;

- (void)registerCells;
- (IBAction)refresh:(UIRefreshControl *)sender;

@end
