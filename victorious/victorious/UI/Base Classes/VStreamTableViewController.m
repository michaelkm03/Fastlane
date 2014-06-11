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
#import "VContentViewController.h"

#import "NSString+VParseHelp.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"

#import "VStreamToContentAnimator.h"
#import "VStreamToCommentAnimator.h"

//Cells
#import "VStreamViewCell.h"
#import "VStreamPollCell.h"

//ObjectManager
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "VThemeManager.h"

@interface VStreamTableViewController() <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;

@property (strong, nonatomic) NSCache* preloadImageCache;
@end

@implementation VStreamTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willCommentSequence:)
     name:kStreamsWillCommentNotification object:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.bottomRefreshIndicator.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
}

- (NSCache*)preloadImageCache
{
    if (!_preloadImageCache)
    {
        self.preloadImageCache = [[NSCache alloc] init];
        self.preloadImageCache.countLimit = 20;
    }
    return _preloadImageCache;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.fetchedResultsController.fetchedObjects count] < 5)
        [self refresh:nil];
    else
        [self.tableView reloadData]; //force a reload incase anything has changed
    
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.origin.y = 0;
    self.navigationController.navigationBar.frame = navBarFrame;
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.preloadImageCache removeAllObjects];
    
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.origin.y = 0;
    
    [UIView animateWithDuration:.5f animations:^
     {
         self.navigationController.navigationBar.frame = navBarFrame;
     }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Properties
- (void)setFilterType:(VStreamFilter)filterType
{
    if (_filterType == filterType)
        return;
    
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        _filterType = filterType;
        [self refreshFetchController];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    self.preloadImageCache = nil;
}

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VSequence entityName]];
    NSString* sortKey = self.filterType == VStreamHotFilter ? kDisplayOrderKey : kReleasedAtKey;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    
    NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"ANY filters.filterAPIPath =[cd] %@", [self currentFilter].filterAPIPath];
    NSPredicate* datePredicate = [NSPredicate predicateWithFormat:@"(expiresAt >= %@) OR (expiresAt = nil)", [NSDate dateWithTimeIntervalSinceNow:0]];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[filterPredicate, datePredicate]]];
//    [fetchRequest setPredicate:filterPredicate];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:[self currentFilter].perPageNumber.integerValue];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:context
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([sequence isTemporarySequence] || [sequence.expiresAt timeIntervalSinceNow] < 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    self.selectedSequence = [self.fetchedResultsController objectAtIndexPath:indexPath];
    VStreamViewCell* cell = (VStreamViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    //Every time we go to the content view, update the sequence
    [[VObjectManager sharedManager] fetchSequence:cell.sequence.remoteId
                                     successBlock:nil
                                        failBlock:nil];
    
    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
    [self.delegate streamWillDisappear];
    
    CGFloat contentMediaViewOffset = [VContentViewController estimatedContentMediaViewOffsetForBounds:self.view.bounds];
    if (tableView.contentOffset.y == cell.frame.origin.y - contentMediaViewOffset)
    {
        [self.navigationController pushViewController:[VContentViewController sharedInstance] animated:YES];
    }
    else
    {
        self.tableView.userInteractionEnabled = NO;
        [tableView setContentOffset:CGPointMake(cell.frame.origin.x, cell.frame.origin.y - contentMediaViewOffset) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSIndexPath* path = [self.fetchedResultsController indexPathForObject:self.selectedSequence];
    VStreamViewCell* cell = (VStreamViewCell*)[self.tableView cellForRowAtIndexPath:path];
    if (cell)
    {
        self.tableView.userInteractionEnabled = YES;
        [self.navigationController pushViewController:[VContentViewController sharedInstance] animated:YES];
    }
}

#pragma mark - Cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];

    NSUInteger cellHeight;
    
    if ([sequence isPoll])
        cellHeight = kStreamDoublePollCellHeight;
    
    else
        cellHeight = kStreamViewCellHeight;
    
    return cellHeight;
}

- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([sequence isPoll])
        return [tableView dequeueReusableCellWithIdentifier:kStreamDoublePollCellIdentifier
                                               forIndexPath:indexPath];

    else if ([sequence isVideo])
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
    
    if ([self.fetchedResultsController.fetchedObjects count] > indexPath.row + 2)
    {
        NSIndexPath* preloadPath = [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section];
        VSequence* preloadSequence = [self.fetchedResultsController objectAtIndexPath:preloadPath];
        
        for (NSURL* imageUrl in [preloadSequence initialImageURLs])
        {
            UIImageView* preloadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [preloadView setImageWithURL:imageUrl];
            
            [self.preloadImageCache setObject:preloadView forKey:imageUrl.absoluteString];
        }
    }

    return cell;
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamVideoCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
}

#pragma mark - Refresh
- (IBAction)refresh:(UIRefreshControl *)sender
{

    RKManagedObjectRequestOperation* operation = [[VObjectManager sharedManager] refreshSequenceFilter:[self currentFilter]
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [sender endRefreshing];
     }
                                                failBlock:^(NSOperation* operation, NSError* error)
     {
         [sender endRefreshing];
     }];
    
    if (operation)
    {
        [sender endRefreshing];
    }
}

- (void)loadNextPageAction
{
    RKManagedObjectRequestOperation* operation = [[VObjectManager sharedManager] loadNextPageOfSequenceFilter:[self currentFilter]
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [self.bottomRefreshIndicator stopAnimating];
     }
                                                failBlock:^(NSOperation* operation, NSError* error)
     {
         [self.bottomRefreshIndicator stopAnimating];
     }];
    
    if (operation)
    {
        [self.bottomRefreshIndicator startAnimating];
    }
}

#pragma mark - Predicates
- (VSequenceFilter*)currentFilter
{
    switch (self.filterType) {
        case VStreamHotFilter:
            return [self hotFilter];
        case VStreamRecentFilter:
            return [self defaultFilter];
        case VStreamFollowingFilter:
            return [self followingFilter];
            
        default:
            VLog(@"Unknown filter type, using default filter");
            return [self defaultFilter];
    }
}

- (VSequenceFilter*)defaultFilter
{
    return [[VObjectManager sharedManager] sequenceFilterForCategories:[self sequenceCategories]];
}
- (VSequenceFilter*)hotFilter
{
    return [[VObjectManager sharedManager] hotSequenceFilterForStream:[self streamName]];
}
- (VSequenceFilter*)followingFilter
{
    return [[VObjectManager sharedManager] followerSequenceFilterForStream:[self streamName] user:nil];
}

- (NSString*)streamName
{
    return @"home";
}

- (NSArray*)sequenceCategories
{
    return nil;
}

#pragma mark - Actions
- (void)setBackgroundImageWithURL:(NSURL*)url
{
    UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [newBackgroundView setBlurredImageWithURL:url
                             placeholderImage:placeholderImage
                                    tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.tableView.backgroundView = newBackgroundView;
}

#pragma mark - Notifications

- (void)willCommentSequence:(NSNotification *)notification
{
    VStreamViewCell *cell = (VStreamViewCell *)notification.object;
    if ([cell.sequence isTemporarySequence])
    {
        return;
    }

    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
    [self.delegate streamWillDisappear];

    VCommentsContainerViewController* commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = cell.sequence;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

#pragma mark - Navigation
- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController*)fromVC
                                                  toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush && ([toVC isKindOfClass:[VContentViewController class]]) )
    {
        return [[VStreamToContentAnimator alloc] init];;
    }
    else if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[VCommentsContainerViewController class]])
    {
        return [[VStreamToCommentAnimator alloc] init];
    }
    return nil;
}

#pragma mark - VAnimation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    NSIndexPath* path = [self.fetchedResultsController indexPathForObject:self.selectedSequence];
    VStreamViewCell* selectedCell = (VStreamViewCell*) [self.tableView cellForRowAtIndexPath:path];
    
    //If the tableview updates while we are in the content view it will reset the cells to their proper positions.
    //In this case, we reset them
    CGFloat centerPoint = selectedCell ? selectedCell.center.y : self.tableView.center.y + self.tableView.contentOffset.y;

    for (VStreamViewCell* cell in self.repositionedCells)
    {
        
        CGRect cellRect = [self.tableView convertRect:cell.frame toView:self.tableView.superview];
        if (CGRectIntersectsRect(self.tableView.frame, cellRect))
        {
            if (cell.center.y > centerPoint)
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y + [UIScreen mainScreen].bounds.size.height);
            }
            else
            {
                cell.center = CGPointMake(cell.center.x, cell.center.y - [UIScreen mainScreen].bounds.size.height);
            }
        }
    }
    
    [UIView animateWithDuration:duration/2
                     animations:^
     {
         [selectedCell showOverlays];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration/2
                          animations:^
          {
              for (VStreamViewCell* cell in self.repositionedCells)
              {
                  CGRect cellRect = [self.tableView convertRect:cell.frame toView:self.tableView.superview];
                  if (!CGRectIntersectsRect(self.tableView.frame, cellRect))
                  {
                      if (cell.center.y > centerPoint)
                      {
                          cell.center = CGPointMake(cell.center.x, cell.center.y - [UIScreen mainScreen].bounds.size.height);
                      }
                      else
                      {
                          cell.center = CGPointMake(cell.center.x, cell.center.y + [UIScreen mainScreen].bounds.size.height);
                      }
                  }
              }
          }
                          completion:^(BOOL finished)
          {
              CGFloat minOffset = self.navigationController.navigationBar.frame.size.height;
              CGFloat maxOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
              if (self.tableView.contentOffset.y < minOffset)
              {
                  [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0) animated:YES];
              }
              else if (self.tableView.contentOffset.y >= maxOffset)
              {
                  [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, maxOffset) animated:YES];
              }
              
              self.repositionedCells = nil;
              
              if (selectedCell)
              {
                  [self.tableView deselectRowAtIndexPath:path animated:NO];
                  self.selectedSequence = nil;
              }
              
              if (completion)
              {
                  completion(finished);
              }
          }];
     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:.4f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(self.navigationController.navigationBar.center.x,
                                            self.navigationController.navigationBar.center.y - self.tableView.frame.size.height);
         self.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];
         
         NSIndexPath* path = [self.fetchedResultsController indexPathForObject:self.selectedSequence];
         VStreamViewCell* selectedCell = (VStreamViewCell*) [self.tableView cellForRowAtIndexPath:path];
         CGFloat centerPoint = selectedCell ? selectedCell.center.y : self.tableView.center.y + self.tableView.contentOffset.y;

         for (VStreamViewCell* cell in [self.tableView visibleCells])
         {
             CGRect cellRect = [self.tableView convertRect:cell.frame toView:self.tableView.superview];
             if (cell == selectedCell || !CGRectIntersectsRect(self.tableView.frame, cellRect))
             {
                 continue;
             }
         
             if (cell.center.y > centerPoint)
             {
                 cell.center = CGPointMake(cell.center.x, cell.center.y + [UIScreen mainScreen].bounds.size.height);
             }
             else
             {
                 cell.center = CGPointMake(cell.center.x, cell.center.y - [UIScreen mainScreen].bounds.size.height);
             }
             [repositionedCells addObject:cell];
         }
         self.repositionedCells = repositionedCells;
     }
                     completion:^(BOOL finished)
     {
         if (completion)
         {
             completion(finished);
         }
     }];
}


@end
