//
//  VFetchedResultsTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VAbstractFilter;

@interface VFetchedResultsTableViewController : UITableViewController   <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong)   NSFetchedResultsController     *fetchedResultsController;
@property (nonatomic, strong)   UIActivityIndicatorView        *bottomRefreshIndicator;
@property (nonatomic, readonly) NSPredicate *customPredicate;

@property (nonatomic, weak) id<UITableViewDelegate>delegate;

- (void)performFetch;

- (NSFetchedResultsController *)makeFetchedResultsController;
- (void)refreshFetchController;

- (void)registerCells;
- (IBAction)refresh:(UIRefreshControl *)sender;

- (BOOL)scrollView:(UIScrollView *)scrollView shouldLoadNextPageOfFilter:(VAbstractFilter *)filter;
- (BOOL)scrollView:(UIScrollView *)scrollView shouldLoadNextPageOfFilter:(VAbstractFilter *)filter forScrollThreshold:(CGFloat)threshold;

@end
