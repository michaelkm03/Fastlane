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
#import "VStreamYoutubeVideoCell.h"

//ObjectManager
#import "VObjectManager+Sequence.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

@interface VStreamTableViewController()

@end

@implementation VStreamTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willCommentSequence:)
     name:kStreamsWillCommentNotification object:nil];
    
    if ([self.fetchedResultsController.fetchedObjects count] < 5)
        [self refreshAction];
    else
        [self.tableView reloadData]; //force a reload incase anything has changed
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if (([sequence isForum] || [sequence isVideo])
        && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        //This will reload the youtube video so it stops playing
        //TODO: replace this with a pause
        [(VStreamYoutubeVideoCell*)cell setSequence:((VStreamYoutubeVideoCell*)cell).sequence];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
//    commentsTable.sequence = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
//    [self.navigationController pushViewController:commentsTable animated:YES];
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.tableView.contentOffset.y > (self.tableView.contentSize.height * .75))
    {
        [self refreshAction];
    }
}
//    NSArray* visibleCells = [self.tableView visibleCells];
//    
//    if (![visibleCells count])
//        return;
//    
//    VSequence* sequence;
//    if ([visibleCells count] > 2)
//    {
//        //The 2nd one is completely on screen, use that
//        NSIndexPath* path = [self.tableView indexPathForCell:[visibleCells objectAtIndex:1]];
//        sequence = [self.fetchedResultsController objectAtIndexPath:path];
//    }
//    else
//    {
//        CGFloat currentCenterY = self.tableView.contentOffset.y + self.tableView.center.y;
//        CGFloat firstCellDiff = currentCenterY - ((UIView*)[visibleCells firstObject]).center.y;
//        CGFloat secondCellDiff = currentCenterY - ((UIView*)[visibleCells lastObject]).center.y;
//
//        if (fabsf(firstCellDiff) > fabsf(secondCellDiff))
//        {
//            //use 2nd cell
//            NSIndexPath* path = [self.tableView indexPathForCell:[visibleCells objectAtIndex:1]];
//            sequence = [self.fetchedResultsController objectAtIndexPath:path];
//        }
//        else
//        {
//            //use 1st cell
//            NSIndexPath* path = [self.tableView indexPathForCell:[visibleCells objectAtIndex:0]];
//            sequence = [self.fetchedResultsController objectAtIndexPath:path];
//        }
//    }
//    
//    self.actionBar.currentSequence = sequence;
//    [self showActionBar];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self hideActionBar];
//}

#pragma mark - Cells

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStreamViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSUInteger cellHeight;
    if ([sequence isPoll])
        cellHeight = kStreamPollCellHeight;
    
    else if (([sequence isVideo] ||[sequence isForum]) && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        cellHeight = kStreamYoutubeCellHeight;
    
    else
        cellHeight = kStreamViewCellHeight;
    
//    NSUInteger commentCount = MIN([sequence.comments count], 2);
//    CGFloat commentHeight = commentCount ? (commentCount * kStreamCommentCellHeight) + kStreamCommentHeaderHeight : 0;
    
    
    return cellHeight;// + commentHeight;
}

- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (([sequence isForum] || [sequence isVideo])
        && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return [tableView dequeueReusableCellWithIdentifier:kStreamYoutubeVideoCellIdentifier
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
    VSequence *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ((VStreamViewCell*)cell).parentTableViewController = self;
    [((VStreamViewCell*)cell) setSequence:info];

    return cell;
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamYoutubeVideoCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamYoutubeVideoCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamYoutubeVideoCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamYoutubeVideoCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamVideoCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamVideoCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamPollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamPollCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
}

#pragma mark - Refresh
- (void)refreshAction
{
    if (self.refreshControl.refreshing)
        return;
 
    [self.refreshControl beginRefreshing];
    [self.bottomRefreshIndicator startAnimating];
    
    [[VObjectManager sharedManager] loadNextPageOfSequencesForCategory:nil
                                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [self.refreshControl endRefreshing];
         [self.bottomRefreshIndicator stopAnimating];
     }
                                                             failBlock:^(NSOperation* operation, NSError* error)
     {
         [self.refreshControl endRefreshing];
         [self.bottomRefreshIndicator stopAnimating];
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

//- (void)showActionBar
//{
//    [UIView animateWithDuration:1.0f
//                     animations:^{
//                         self.actionBar.frame = CGRectMake(0, self.view.frame.size.height - VStreamActionBarHeight, self.actionBar.frame.size.width, self.actionBar.frame.size.height);
//                     }];
//}
//
//- (void)hideActionBar
//{
//    if (self.actionBar.frame.origin.y >= self.view.frame.size.height)
//        return;
//    
//    [UIView animateWithDuration:1.0f
//                     animations:^{
//                         self.actionBar.frame = CGRectMake(0, self.view.frame.size.height, self.actionBar.frame.size.width, self.actionBar.frame.size.height);
//                     }];
//}

#pragma mark - Notifications

- (void)willCommentSequence:(NSNotification *)notification
{
    VStreamViewCell *cell = (VStreamViewCell *)notification.object;
    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = cell.sequence;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

@end
