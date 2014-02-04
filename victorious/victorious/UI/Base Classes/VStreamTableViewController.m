//
//  VStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConstants.h"

#import "VCommentsContainerViewController.h"

#import "NSString+VParseHelp.h"
//Cells
#import "VStreamViewCell.h"
#import "VStreamVideoCell.h"
#import "VStreamPollCell.h"

//ObjectManager
#import "VObjectManager+Sequence.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

@implementation VStreamTableViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillSegueNotification
                                                        object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.fetchedResultsController.fetchedObjects count] < 5)
        [self refreshAction];
}

#pragma mark - FetchedResultsControllers
- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VSequence entityName]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"releasedAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:context
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

- (NSFetchedResultsController *)makeSearchFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VSequence entityName]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"releasedAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return  [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:context
                                                  sectionNameKeyPath:nil
                                                           cacheName:kSearchCache];

}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:commentsTable animated:YES];
}

#pragma mark - Cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([sequence isPoll])
        return kStreamPollCellHeight;
    
    else if (([sequence isVideo] ||[sequence isForum]) && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return kStreamYoutubeCellHeight;
    
    return kStreamViewCellHeight;
}

- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (([sequence isForum] || [sequence isVideo])
        && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return [tableView dequeueReusableCellWithIdentifier:kStreamYoutubeCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isPoll] && [[sequence firstNode] firstAsset])
        return [tableView dequeueReusableCellWithIdentifier:kStreamPollCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isPoll])
        return [tableView dequeueReusableCellWithIdentifier:kStreamDoublePollCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isForum] || [sequence isVideo])
        return [tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                               forIndexPath:indexPath];
    
    else
        return [tableView dequeueReusableCellWithIdentifier:kStreamViewCellIdentifier
                                               forIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamViewCell *cell = [self tableView:tableView streamViewCellForIndex:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath forFetchedResultsController:self.fetchedResultsController];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
forFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    VSequence *info = [fetchedResultsController objectAtIndexPath:theIndexPath];
    ((VStreamViewCell*)theCell).parentTableViewController = self;
    [((VStreamViewCell*)theCell) setSequence:info];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamVideoCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamVideoCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamPollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamPollCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
}

#pragma mark - Refresh
- (void)refreshAction
{
    [[VObjectManager sharedManager] loadNextPageOfSequencesForCategory:nil
                                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [self.refreshControl endRefreshing];
     }
                                                             failBlock:^(NSOperation* operation, NSError* error)
     {
         [self.refreshControl endRefreshing];
     }];
}

#pragma mark - Predicates
- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption
{
    NSMutableArray* allPredicates = [[NSMutableArray alloc] init];
    for (NSString* categoryName in [self categoriesForOption:searchOption])
    {
        [allPredicates addObject:[self categoryPredicateForString:categoryName]];
    }
    return [NSCompoundPredicate orPredicateWithSubpredicates:allPredicates];
}

- (NSPredicate*)categoryPredicateForString:(NSString*)categoryName
{
    //TODO: double check this, I think its wrong
    return [NSPredicate predicateWithFormat:@"category == %@", categoryName];
}

- (NSArray*)categoriesForOption:(NSUInteger)searchOption
{
    return nil;
}

#pragma mark - Actions

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

@end
