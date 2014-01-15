//
//  VAbstractStreamTableVieControllerViewController.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractStreamViewController.h"

#import "VSequence+RestKit.h"
#import "NSString+VParseHelp.h"

NSString* const kSearchCache = @"SearchCache";

@interface VAbstractStreamViewController ()
@end

@implementation VAbstractStreamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^()
     {
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error] && error)
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
     }];
    
    [self registerCells];
}

- (void)viewWillAppear:(BOOL)animated
{
    // scroll the search bar off-screen
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchDisplayController.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    [self refreshFetchController:self.fetchedResultsController withPredicate:[self fetchResultsPredicate]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fetchedResultsController = nil;
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshAction];
}

#pragma mark -

//The follow 2 methods and the majority of the rest of the file was based on the following stack overflow article:
//http://stackoverflow.com/questions/4471289/how-to-filter-nsfetchedresultscontroller-coredata-with-uisearchdisplaycontroll

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView*)tableViewForFetchedResultsController:(NSFetchedResultsController*)controller
{
    return controller == self.fetchedResultsController ? self.tableView
    : self.searchDisplayController.searchResultsTableView;
}

#pragma mark - NSFetchedResultsControllers

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [self fetchRequestForContext:context];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:nil
                                         cacheName:fetchRequest.entityName];
        
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (nil == _searchFetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [self fetchRequestForContext:context];
        
        _searchFetchedResultsController = [[NSFetchedResultsController alloc]
                                               initWithFetchRequest:fetchRequest
                                               managedObjectContext:context
                                               sectionNameKeyPath:nil
                                               cacheName:kSearchCache];
        
        _searchFetchedResultsController.delegate = self;
    }
    
    return _searchFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [[self tableViewForFetchedResultsController:controller] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forFetchedResultsController:[self fetchedResultsControllerForTableView:tableView]];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [[self tableViewForFetchedResultsController:controller] endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
forFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    //Update the cell
}

#pragma mark - Search Display

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
    [self refreshFetchController:self.searchFetchedResultsController
                   withPredicate:[self fetchResultsPredicate]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self viewWillAppear:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //This relies on the scope buttons being in the same order as the VStreamScope enum
    self.scopeType = selectedScope;
    [self refreshFetchController:self.searchFetchedResultsController
                   withPredicate:[self fetchResultsPredicate]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterText = searchText;
    
    [self refreshFetchController:self.searchFetchedResultsController
                   withPredicate:[self fetchResultsPredicate]];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self refreshFetchController:self.fetchedResultsController
                   withPredicate:[self fetchResultsPredicate]];
}

#pragma mark - Filtering

- (NSPredicate*)fetchResultsPredicate
{
    NSMutableArray* allFilters = [[NSMutableArray alloc] init];
    
    //Type filter
    NSPredicate* scopePredicate = [self scopeTypePredicate];
    if (scopePredicate)
    {
        [allFilters addObject:scopePredicate];
    }
    
    //Search text filter
    NSPredicate* searchTextPredicate = [self searchTextPredicate];
    if (searchTextPredicate)
    {
        [allFilters addObject:searchTextPredicate];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:allFilters];
}

- (void)refreshFetchController:(NSFetchedResultsController*)controller
                 withPredicate:(NSPredicate*)predicate
{
    //We must clear the cache before modifying anything.
    NSString* cacheName = (controller == self.fetchedResultsController) ? controller.fetchRequest.entityName : kSearchCache;
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    
    [controller.fetchRequest setPredicate:predicate];
    
    //We need to perform the fetch again
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^()
     {
        NSError *error;
        if (![controller performFetch:&error] && error)
        {
            //TODO: Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
     }];
    
    //Then reload the data
    [[self tableViewForFetchedResultsController:controller] reloadData];
}

#pragma mark - Predicate Lifecycle

- (NSPredicate*)searchTextPredicate
{
    if (!self.filterText || [self.filterText isEmpty])
    {
        return nil;
    }
    
    return [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", _filterText];
}

- (NSPredicate*)scopeTypePredicate
{
    return nil;
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[VSequence entityName] inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return fetchRequest;
}

#pragma mark - Cell Lifecycle

- (void)registerCells
{
    //Register cells here
}

#pragma mark - Refresh Lifecycle

- (void)refreshAction
{
    //Define refresh action here
}

@end
