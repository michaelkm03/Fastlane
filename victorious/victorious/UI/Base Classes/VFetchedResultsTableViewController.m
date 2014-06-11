//
//  VFetchedResultsTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import CoreData;

#import "VFetchedResultsTableViewController.h"
#import "NSString+VParseHelp.h"
#import "VThemeManager.h"

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
    
    if (![self.fetchedResultsController.fetchedObjects count] < 5)
        [self refresh:self.refreshControl];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self performFetch];
    [self.refreshControl endRefreshing];
}

- (void)loadNextPageAction
{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
    
    //Notify the container about the scroll so it can handle the header
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
    
//    //TODO: remove this, this is just here until we port the profile view
//    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
//    CGRect navBarFrame = self.navigationController.navigationBar.frame;
//    
//    if (translation.y < 0 && CGRectContainsRect(self.view.frame, navBarFrame))
//    {
//        navBarFrame.origin.y = -navBarFrame.size.height;
//    }
//    else if (translation.y > 0 && !CGRectContainsRect(self.view.frame, navBarFrame))
//    {
//        navBarFrame.origin.y = 0;
//    }
//    else
//    {
//        return;
//    }
//    
//    [UIView animateWithDuration:.5f animations:^
//     {
//         self.navigationController.navigationBar.frame = navBarFrame;
//     }];
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
    if (self.tableView.window == nil)
        return;

    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.tableView.window == nil)
        return;
    
    switch(type)
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
    if (self.tableView.window == nil)
        return;

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    return nil;
}

- (void)registerCells
{
    
}

@end
