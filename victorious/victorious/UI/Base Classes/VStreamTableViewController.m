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
#import "VObjectManager+SequenceFilters.h"

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
    self.filterType = VStreamRecentFilter;
    
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willCommentSequence:)
     name:kStreamsWillCommentNotification object:nil];
    
    self.preloadImageCache = [[NSCache alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.bottomRefreshIndicator.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = self;
    
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
    
    if (self.navigationController.delegate == self)
    {
        self.navigationController.delegate = nil;
    }
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
    
    _filterType = filterType;
    [self refreshFetchController];
}

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VSequence entityName]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"releasedAt" ascending:NO];
    
    NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"ANY filters.filterAPIPath =[cd] %@", [self currentFilter].filterAPIPath];
    [fetchRequest setPredicate:filterPredicate];
    
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
    if ([sequence isTemporarySequence] || [sequence.releasedAt timeIntervalSinceNow] < 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    VStreamViewCell* cell = (VStreamViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
    [self.delegate streamWillDisappear];
    
    if (tableView.contentOffset.y == cell.frame.origin.y - kContentMediaViewOffset)
    {
        [self.navigationController pushViewController:[VContentViewController sharedInstance] animated:YES];
    }
    else
    {
        self.tableView.userInteractionEnabled = NO;
        [tableView setContentOffset:CGPointMake(cell.frame.origin.x, cell.frame.origin.y - kContentMediaViewOffset) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    VStreamViewCell* cell = (VStreamViewCell*)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    if (cell)
    {
        self.tableView.userInteractionEnabled = YES;
        [self.navigationController pushViewController:[VContentViewController sharedInstance] animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
    
    //Notify the container about the scroll so it can handle the header
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    
    if (translation.y < 0 && CGRectContainsRect(self.view.frame, navBarFrame))
    {
        navBarFrame.origin.y = -navBarFrame.size.height;
    }
    else if (translation.y > 0 && !CGRectContainsRect(self.view.frame, navBarFrame))
    {
        navBarFrame.origin.y = 0;
    }
    else
    {
        return;
    }
    
    [UIView animateWithDuration:.5f animations:^
    {
        self.navigationController.navigationBar.frame = navBarFrame;
    }];
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
    [[VObjectManager sharedManager] refreshSequenceFilter:[self currentFilter]
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         [self.refreshControl endRefreshing];
     }
                                                failBlock:^(NSOperation* operation, NSError* error)
     {
         [self.refreshControl endRefreshing];
     }];
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
    [newBackgroundView setLightBlurredImageWithURL:url
                                  placeholderImage:placeholderImage];
    
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
    commentsTable.parentVC = self;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

#pragma marke- Navigation
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
    self.fetchedResultsController.delegate = nil;
    VStreamViewCell* selectedCell = (VStreamViewCell*) [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    
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
                  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
              }
              
              self.fetchedResultsController.delegate = self;
              
              if (completion)
              {
                  completion(finished);
              }
          }];
     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    self.fetchedResultsController.delegate = nil;
    [UIView animateWithDuration:.4f
                     animations:^
     {
         CGPoint newNavCenter = CGPointMake(self.navigationController.navigationBar.center.x,
                                            self.navigationController.navigationBar.center.y - self.tableView.frame.size.height);
         self.navigationController.navigationBar.center = newNavCenter;
         
         NSMutableArray* repositionedCells = [[NSMutableArray alloc] init];

         VStreamViewCell* selectedCell = (VStreamViewCell*) [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
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
         self.fetchedResultsController.delegate = self;
         
         if (completion)
         {
             completion(finished);
         }
     }];
}


@end
