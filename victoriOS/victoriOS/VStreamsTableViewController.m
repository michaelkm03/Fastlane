//
//  VStreamsTableViewController.m
//  victoriOS
//
//  Created by goWorld on 12/2/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VStreamsTableViewController.h"
#import "VSequence.h"
#import "REFrostedViewController.h"
#import "NSString+VParseHelp.h"

typedef NS_ENUM(NSInteger, VStreamScope) {
    VStreamFilterAll = 0,
    VStreamFilterImages,
    VStreamFilterVideos,
    VStreamFilterVideoForums,
    VStreamFilterPolls
};

@interface VStreamsTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController* searchFetchedResultsController;
@property (nonatomic) VStreamScope scopeType;
@property (strong, nonatomic) NSString* filterText;
@property (nonatomic, strong) UIPageViewController* pageController;
@end

static NSString* kStreamCache = @"StreamCache";
static NSString* kSearchCache = @"SearchCache";

@implementation VStreamsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        _scopeType = VStreamFilterAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageController =   [self.storyboard instantiateViewControllerWithIdentifier:@"featured"];

    NSError *error;
	if (![self.fetchedResultsController performFetch:&error])
    {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewWillAppear:(BOOL)animated
{    
    // scroll the search bar off-screen
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchDisplayController.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fetchedResultsController = nil;
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
    forFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    VSequence *info = [fetchedResultsController objectAtIndexPath:theIndexPath];
    theCell.textLabel.text = info.name;
    theCell.imageView.image = [UIImage imageNamed:@"avatar.jpg"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kVideoPhotoCellIdentifier = @"VideoPhoto";
    static NSString *kForumPollCellIdentifier = @"ForumPoll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVideoPhotoCellIdentifier];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath
        forFetchedResultsController:[self fetchedResultsControllerForTableView:tableView]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*     containerView   =   [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 120.0)];
    [self addChildViewController:self.pageController];
    [containerView addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    return containerView;
}

#pragma mark - NSFetchedResultsControllers

- (void)updatePredicateForFetchedResultsController:(NSFetchedResultsController*)controller
{
    //We must clear the cache before modifying anything.
    NSString* cacheName = (controller == _fetchedResultsController) ? kStreamCache : kSearchCache;
    [NSFetchedResultsController deleteCacheWithName:cacheName];

    NSFetchRequest* fetchRequest = controller.fetchRequest;

    //Define the appropriate filter
    NSPredicate* typeFilter;
    
    //Start by filtering by type
    switch (_scopeType)
    {
        case VStreamFilterVideoForums:
            typeFilter = [NSPredicate predicateWithFormat:@"category == 'video_forum'"];
            break;
            
        case VStreamFilterPolls:
            typeFilter = [NSPredicate predicateWithFormat:@"category == 'poll'"];
            break;
            
        case VStreamFilterImages:
            typeFilter = [NSPredicate predicateWithFormat:@"category == 'image'"];
            break;
            
        case VStreamFilterVideos:
            typeFilter = [NSPredicate predicateWithFormat:@"category == 'video'"];
            break;
            
        default:
            //TODO: remove "|| general " from this filter.
            typeFilter = [NSPredicate predicateWithFormat:@"category == 'video_forum' || category == 'poll' || category == 'image' || category == 'video' || category == 'general'"];
            break;
    }
    
    //And filter by the search text
    
    NSMutableArray* allFilters = [[NSMutableArray alloc] init];
    if (typeFilter)
        [allFilters addObject:typeFilter];
    if (_filterText && ![_filterText isEmpty])
        [allFilters addObject:[NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", _filterText]];
    
    NSPredicate* filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:allFilters];
    
    [fetchRequest setPredicate:filterPredicate];

    //We need to perform the fetch again
    NSError *error;
	if (![controller performFetch:&error])
    {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    //Then reload the data
    [[self tableViewForFetchedResultsController:controller] reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [self fetchRequestForContext:context];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:kStreamCache];
        self.fetchedResultsController.delegate = self;
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
        
        self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:kSearchCache];
        self.searchFetchedResultsController.delegate = self;
    }
    
    return _searchFetchedResultsController;
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sequence" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return fetchRequest;
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //This relies on the scope buttons being in the same order as the VStreamScope enum
    _scopeType = selectedScope;
    [self updatePredicateForFetchedResultsController:_searchFetchedResultsController];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _filterText = searchText;
    [self updatePredicateForFetchedResultsController:_searchFetchedResultsController];
}

#pragma mark - Search Display

- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self viewWillAppear:YES];
    [self updatePredicateForFetchedResultsController:_fetchedResultsController];
}

@end
