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

@interface VFetchedResultsTableViewController ()
@end

@implementation VFetchedResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hideSearchBar];
    [self registerCells];
    [self performFetch];
    
    self.searchDisplayController.searchBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:kVStreamSearchBarColor];
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(displaySearchBar:)];
    self.navigationItem.rightBarButtonItems= @[searchButtonItem];}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshFetchController:self.fetchedResultsController withPredicate:[self fetchResultsPredicateForString:nil option:0]];
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
        self.fetchedResultsController = [self makeFetchedResultsController];
        self.fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}
- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (nil == _searchFetchedResultsController)
    {
        self.searchFetchedResultsController = [self makeSearchFetchedResultsController];
        self.searchFetchedResultsController.delegate = self;
    }
    
    return _searchFetchedResultsController;
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

- (void)refreshFetchController:(NSFetchedResultsController*)controller
                 withPredicate:(NSPredicate*)predicate
{
    //We must clear the cache before modifying anything.
    [NSFetchedResultsController deleteCacheWithName:controller.cacheName];
    
    [controller.fetchRequest setPredicate:predicate];
    
    [self performFetch];
}

- (void)hideSearchBar
{
    [self.searchDisplayController.searchBar removeFromSuperview];
}

- (IBAction)displaySearchBar:(id)sender
{
    [self.view addSubview:self.searchDisplayController.searchBar];
    [self.searchDisplayController.searchBar becomeFirstResponder];

//    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
//    [self viewWillAppear:NO];
//    [UIView animateWithDuration:.4f animations:^{
//
//    }];
//    [self.view addSubview: self.searchDisplayController.searchBar];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshAction];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITablViewDataSource

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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//        return 0;
//    else
//        return 22;
//}

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
            if (!newIndexPath)
            {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
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

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    [self hideSearchBar];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self refreshFetchController:self.searchFetchedResultsController withPredicate:[self fetchResultsPredicateForString:searchString option:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];

    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    
    [self refreshFetchController:self.searchFetchedResultsController withPredicate:[self fetchResultsPredicateForString:self.searchDisplayController.searchBar.text option:searchOption]];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self hideSearchBar];
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

- (NSFetchedResultsController *)makeFetchedResultsController
{
    return nil;
}

- (NSFetchedResultsController *)makeSearchFetchedResultsController
{
    return nil;
}

- (void)registerCells
{
    
}

- (void)refreshAction
{
    [self performFetch];
}

- (NSPredicate*)searchPredicateForString:(NSString *)searchString
{
    if (!searchString || [searchString isEmpty])
    {
        return nil;
    }
    
    return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
}

- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption
{
    return nil;
}

@end
