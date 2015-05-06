//
//  VFetchedResultsTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFetchedResultsTableViewController.h"
#import "NSString+VParseHelp.h"
#import "VPaginationManager.h"
#import "VAbstractFilter.h"

@implementation VFetchedResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    
    [self refreshFetchController];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.bottomRefreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.bottomRefreshIndicator.frame = CGRectMake(0, 0, 24, 24);
    self.bottomRefreshIndicator.hidesWhenStopped = YES;
    [self.tableView.backgroundView addSubview:self.bottomRefreshIndicator];
    float yCenter = self.tableView.backgroundView.frame.size.height - self.bottomRefreshIndicator.frame.size.height;
    self.bottomRefreshIndicator.center = CGPointMake(self.tableView.backgroundView.center.x,
                                                     yCenter);
}

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        self.fetchedResultsController = [self makeFetchedResultsController];
        self.fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

#pragma mark - Actions

- (void)performFetch
{
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Update to handle the error appropriately.
            VLog(@"Unresolved Fetch Error %@, %@", error, [error userInfo]);
        }

        [self.tableView reloadData];
    }];
}

- (void)refreshFetchController
{
    //We must clear the cache before modifying anything.
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
    
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
    [self performFetch];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self performFetch];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITablViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.tableView.window)
    {
        return;
    }
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.tableView.window)
    {
        return;
    }
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if (!newIndexPath)
            {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.tableView.window)
    {
        return;
    }

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.tableView.window == nil)
    {
        [self.tableView reloadData];
        return;
    }

    [self.tableView endUpdates];
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldLoadNextPageOfFilter:(VAbstractFilter *)filter
{
    CGFloat threshold = scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds);
    return [self scrollView:scrollView shouldLoadNextPageOfFilter:filter forScrollThreshold:threshold];
}

//TODO: Stop this method from returning YES when items are being inserted into the table
- (BOOL)scrollView:(UIScrollView *)scrollView shouldLoadNextPageOfFilter:(VAbstractFilter *)filter forScrollThreshold:(CGFloat)threshold
{
    BOOL canLoadFilter = ![[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter] && [filter.currentPageNumber integerValue] < [filter.maxPageNumber integerValue];
    BOOL offsetTriggersLoad = scrollView.contentSize.height > CGRectGetHeight(scrollView.bounds) && scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > threshold;
    BOOL fetchedFirstPage = [[self.fetchedResultsController sections][0] numberOfObjects] >= [filter.perPageNumber unsignedIntegerValue];
    return canLoadFilter && offsetTriggersLoad && fetchedFirstPage;
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    return nil;
}

- (void)registerCells
{
    
}

@end
