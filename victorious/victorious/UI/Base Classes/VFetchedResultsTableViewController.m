//
//  VFetchedResultsTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import CoreData;

#import "VFetchedResultsTableViewController.h"

@interface VFetchedResultsTableViewController ()    <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong)   NSFetchedResultsController*     fetchedResultsController;
@property (nonatomic, strong)   NSFetchedResultsController*     searchFetchedResultsController;
@end

@implementation VFetchedResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hideSearchBar];
    [self registerCells];
    [self performFetch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fetchedResultsController = nil;
}

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription*    entity = [NSEntityDescription entityForName:self.entityName
                                                     inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:self.predicate];
        [fetchRequest setSortDescriptors:self.sortDescriptors];
        if (self.batchSize > 0)
            [fetchRequest setFetchBatchSize:self.batchSize];

        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:self.entityName];
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

 - (void)setPredicate:(NSPredicate *)predicate
{
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
    _predicate = predicate;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
    _sortDescriptors = sortDescriptors;
}

#pragma mark - Actions

- (void)performFetch
{
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Update to handle the error appropriately.
            VLog(@"Unresolved Fetch Error %@, %@", error, [error userInfo]);
        }
        
        [self.tableView reloadData];
    }];
}

- (void)reloadSearchFetchRequestControllerForPredicate:(NSPredicate*)predicate
                                            withEntity:(NSString*)entity
                                             inContext:(NSManagedObjectContext*)context
                                   withSortDescriptors:(NSArray*)sortDescriptors
                                withSectionNameKeyPath:(NSString*)sectionNameKeyPath
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    request.fetchBatchSize = 15;
    
    self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                              managedObjectContext:context
                                                                                sectionNameKeyPath:sectionNameKeyPath
                                                                                         cacheName:@"search.cache.getVictorious.com"];
    self.searchFetchedResultsController.delegate = self;
    
    [self.searchFetchedResultsController.managedObjectContext performBlockAndWait:^{
        NSError *error;
        if (![self.searchFetchedResultsController performFetch:&error])
        {
            VLog(@"Unresolved Search Fetch Error %@, %@", error, [error userInfo]);
        }
    }];
}

- (void)hideSearchBar
{
    // scroll search bar out of sight
    CGRect newBounds = self.tableView.bounds;
    if (self.tableView.bounds.origin.y < 44)
    {
        newBounds.origin.y = newBounds.origin.y + self.searchDisplayController.searchBar.bounds.size.height;
        self.tableView.bounds = newBounds;
    }

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:0 animated:YES];
}

- (IBAction)displaySearchBar:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

    NSTimeInterval delay;
    if (self.tableView.contentOffset.y >1000)
        delay = 0.4;
    else
        delay = 0.1;
    [self performSelector:@selector(activateSearch) withObject:nil afterDelay:delay];
}

- (void)activateSearch
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshAction];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        return 0;
    else
        return 22;
}

#pragma mark - Helper Functions

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return (tableView == self.tableView) ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    return (fetchedResultsController == self.fetchedResultsController) ? self.tableView : self.searchDisplayController.searchResultsTableView;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForFetchedResultsController:controller] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForFetchedResultsController:controller] endUpdates];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0)
    {
        [self reloadSearchFetchRequestControllerForPredicate:[self fetchResultsPredicateForString:searchString
                                                                                           option:self.searchDisplayController.searchBar.selectedScopeButtonIndex]
                                                  withEntity:self.entityName
                                                   inContext:self.managedObjectContext
                                         withSortDescriptors:self.sortDescriptors
                                      withSectionNameKeyPath:nil];
    }
    else
    {
        return NO;
    }

    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self reloadSearchFetchRequestControllerForPredicate:[self fetchResultsPredicateForString:self.searchDisplayController.searchBar.text
                                                                                       option:searchOption]
                                              withEntity:self.entityName
                                               inContext:self.managedObjectContext
                                     withSortDescriptors:self.sortDescriptors
                                  withSectionNameKeyPath:nil];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self viewWillAppear:YES];
}

- (NSPredicate*)fetchResultsPredicateForString:(NSString *)searchString option:(NSUInteger)option
{
    NSMutableArray* allFilters = [NSMutableArray array];
    NSPredicate* searchTextPredicate = [self searchPredicateForString:searchString];
    if (searchTextPredicate)
        [allFilters addObject:searchTextPredicate];

    NSPredicate* searchScopePredicate = [self scopeTypePredicateForOption:option];
    if (searchScopePredicate)
        [allFilters addObject:searchScopePredicate];

    return [NSCompoundPredicate andPredicateWithSubpredicates:allFilters];
}

#pragma mark - Overrides

- (void)registerCells
{
    
}

- (void)refreshAction
{
    [self performFetch];
}

- (NSPredicate*)searchPredicateForString:(NSString *)searchString
{
    return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
}

- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption
{
    return nil;
}

@end
