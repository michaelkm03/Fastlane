//
//  VStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableDataSource.h"
#import "VStreamTableViewController.h"
#import "VStreamTableViewController+ContentCreation.h"
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

#import "VAnalyticsRecorder.h"

#import "VThemeManager.h"

@interface VStreamTableViewController() <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, VStreamTableDataDelegate>

@property (strong, nonatomic, readwrite) VStreamTableDataSource* tableDataSource;
@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;
@property (strong, nonatomic) UIActivityIndicatorView* bottomRefreshIndicator;
@property (strong, nonatomic) NSCache* preloadImageCache;
@property (strong, nonatomic) VContentViewController *contentViewController;

@property (strong, nonatomic) VSequenceFilter* defaultFilter;

@property (strong, nonatomic) NSString* streamName;

@end

@implementation VStreamTableViewController

+ (instancetype)homeStream
{
    VSequenceFilter* defaultFilter = [[VObjectManager sharedManager] sequenceFilterForCategories:
                                      [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStreamTableViewController* stream = [self streamWithDefaultFilter:defaultFilter name:@"home" title:NSLocalizedString(@"HomeTitle", nil)];
    [stream addCreateButton];
    return  stream;
}

+ (instancetype)communityStream
{
    VSequenceFilter* defaultFilter = [[VObjectManager sharedManager] sequenceFilterForCategories:VUGCCategories()];
    VStreamTableViewController* stream = [self streamWithDefaultFilter:defaultFilter name:@"ugc" title:NSLocalizedString(@"UGCTitle", nil)];
    [stream addCreateButton];
    return  stream;
}

+ (instancetype)ownerStream
{
    VSequenceFilter* defaultFilter = [[VObjectManager sharedManager] sequenceFilterForCategories:VOwnerCategories()];
    return [self streamWithDefaultFilter:defaultFilter name:@"owner" title:[[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
}

+ (instancetype)hashtagStreamWithHashtag:(NSString*)hashtag
{
    VSequenceFilter* defaultFilter = [[VObjectManager sharedManager] sequenceFilterForHashTag:hashtag];
    return [self streamWithDefaultFilter:defaultFilter name:@"hashtag" title:[@"#" stringByAppendingString:hashtag]];
}

+ (instancetype)streamWithDefaultFilter:(VSequenceFilter*)filter name:(NSString*)name title:(NSString*)title
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamTableViewController* stream = (VStreamTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamStoryboardID];
    
    stream.streamName = name;
    stream.title = title;
    stream.defaultFilter = filter;
    stream.currentFilter = filter;
    
    return stream;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableDataSource = [[VStreamTableDataSource alloc] initWithFilter:[self currentFilter]];
    self.tableDataSource.delegate = self;
    self.tableDataSource.filter = self.currentFilter;
    self.tableDataSource.tableView = self.tableView;
    self.tableView.dataSource = self.tableDataSource;
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    [self registerCells];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willCommentSequence:)
     name:kStreamsWillCommentNotification object:nil];
    
    self.clearsSelectionOnViewWillAppear = NO;
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
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:[@"Stream - " stringByAppendingString:self.streamName]];
    
    if (!self.tableDataSource.count && !self.tableDataSource.filter.updating.boolValue)
    {
        [self refresh:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
    
    [self.preloadImageCache removeAllObjects];
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
    {
        return;
    }
    
    _filterType = filterType;
    
    switch (self.filterType)
    {
        case VStreamHotFilter:
            self.currentFilter = [self hotFilter];
            break;
            
        case VStreamRecentFilter:
            self.currentFilter = [self defaultFilter];
            break;
            
        case VStreamFollowingFilter:
            self.currentFilter = [self followingFilter];
            break;
            
        default:
            VLog(@"Unknown filter type, using default filter");
            self.currentFilter = [self defaultFilter];
            break;
    }
    
    self.tableView.contentOffset = CGPointMake(-self.tableView.contentInset.left, -self.tableView.contentInset.top);
    
    if ([self isViewLoaded] && self.view.window && !self.tableDataSource.count)
    {
        [self refresh:nil];
    }
}

- (void)setCurrentFilter:(VSequenceFilter *)currentFilter
{
    _currentFilter = currentFilter;
    if ([self isViewLoaded])
    {
        self.tableDataSource.filter = currentFilter;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    self.preloadImageCache = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.contentViewController = [[VContentViewController alloc] init];
    
    VSequence* sequence = [self.tableDataSource sequenceAtIndexPath:indexPath];
    if ([sequence isTemporarySequence] || [sequence.expiresAt timeIntervalSinceNow] < 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    self.selectedSequence = [self.tableDataSource sequenceAtIndexPath:indexPath];
    VStreamViewCell* cell = (VStreamViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[VStreamPollCell class]])
    {
        VStreamPollCell *pollCell = (VStreamPollCell *)cell;
        [self.contentViewController setLeftPollThumbnail:pollCell.previewImageView.image];
        [self.contentViewController setRightPollThumbnail:pollCell.previewImageTwo.image];
    }
    
    //Every time we go to the content view, update the sequence
    [[VObjectManager sharedManager] fetchSequence:cell.sequence.remoteId
                                     successBlock:nil
                                        failBlock:nil];
    
    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
    [self.delegate streamWillDisappear];
    
    
    CGFloat contentMediaViewOffset = [VContentViewController estimatedContentMediaViewOffsetForBounds:self.view.bounds];
    if (tableView.contentOffset.y == cell.frame.origin.y - contentMediaViewOffset)
    {
        [self.navigationController pushViewController:self.contentViewController animated:YES];
    }
    else
    {
        self.tableView.userInteractionEnabled = NO;
        [tableView setContentOffset:CGPointMake(cell.frame.origin.x, cell.frame.origin.y - contentMediaViewOffset) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.selectedSequence)
    {
        self.tableView.userInteractionEnabled = YES;
        [self.navigationController pushViewController:self.contentViewController animated:YES];
    }
}

#pragma mark - Cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = [self.tableDataSource sequenceAtIndexPath:indexPath];

    NSUInteger cellHeight;
    
    if ([sequence isPoll])
        cellHeight = kStreamDoublePollCellHeight;
    
    else
        cellHeight = kStreamViewCellHeight;
    
    return cellHeight;
}

- (UITableViewCell *)dataSource:(VStreamTableDataSource *)dataSource cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath
{
    VStreamViewCell *cell;
    
    if ([sequence isPoll])
    {
        cell = [dataSource.tableView dequeueReusableCellWithIdentifier:kStreamDoublePollCellIdentifier
                                                          forIndexPath:indexPath];
    }
    else if ([sequence isVideo])
    {
        cell = [dataSource.tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                                          forIndexPath:indexPath];
    }
    else
    {
        cell = [dataSource.tableView dequeueReusableCellWithIdentifier:kStreamViewCellIdentifier
                                                          forIndexPath:indexPath];
    }
    
    cell.parentTableViewController = self;
    [cell setSequence:sequence];
    
    if ([dataSource count] > indexPath.row + 2)
    {
        NSIndexPath* preloadPath = [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section];
        VSequence* preloadSequence = [dataSource sequenceAtIndexPath:preloadPath];
        
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
    [self refreshWithCompletion:nil];
}

- (void)refreshWithCompletion:(void(^)(void))completionBlock
{
    [self.tableDataSource refreshWithSuccess:^(void)
    {
        [self.refreshControl endRefreshing];
        if (completionBlock)
        {
            completionBlock();
        }
    }
                                     failure:^(NSError *error)
    {
        [self.refreshControl endRefreshing];
    }];
    
    [self.refreshControl beginRefreshing];
    self.refreshControl.hidden = NO;
}

- (void)loadNextPageAction
{
    [self.tableDataSource loadNextPageWithSuccess:^(void)
    {
        [self hideBottomRefreshIndicator];
    }
                                          failure:^(NSError *error)
    {
        [self hideBottomRefreshIndicator];
    }];
    [self showBottomRefreshIndicator];
}

- (void)showBottomRefreshIndicator
{
    if (!self.bottomRefreshIndicator)
    {
        self.bottomRefreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.bottomRefreshIndicator.hidesWhenStopped = YES;
        self.bottomRefreshIndicator.color = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.bottomRefreshIndicator.frame) + 10.0f)];
    [self.tableView.tableFooterView addSubview:self.bottomRefreshIndicator];
    self.bottomRefreshIndicator.center = CGPointMake(CGRectGetMidX(self.tableView.tableFooterView.bounds), CGRectGetMidY(self.tableView.tableFooterView.bounds));
    [self.bottomRefreshIndicator startAnimating];
}

- (void)hideBottomRefreshIndicator
{
    self.tableView.tableFooterView = nil;
}

#pragma mark - Predicates

- (VSequenceFilter*)defaultFilter
{
    return _defaultFilter ?: [[VObjectManager sharedManager] sequenceFilterForCategories:[self sequenceCategories]];
}
- (VSequenceFilter*)hotFilter
{
    return [[VObjectManager sharedManager] hotSequenceFilterForStream:self.streamName];
}
- (VSequenceFilter*)followingFilter
{
    return [[VObjectManager sharedManager] followerSequenceFilterForStream:self.streamName user:nil];
}

- (NSArray*)sequenceCategories
{
    return nil;
}

#pragma mark - Actions
- (void)setBackgroundImageWithURL:(NSURL*)url
{
    UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
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
    NSIndexPath* path = [self.tableDataSource indexPathForSequence:self.selectedSequence];
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
         
         NSIndexPath* path = [self.tableDataSource indexPathForSequence:self.selectedSequence];
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableDataSource.filter.currentPageNumber.intValue < self.tableDataSource.filter.maxPageNumber.intValue &&
        self.tableDataSource.count &&
        ![[[self currentFilter] updating] boolValue] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
    
    // Notify the container about the scroll so it can handle the header
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

@end
