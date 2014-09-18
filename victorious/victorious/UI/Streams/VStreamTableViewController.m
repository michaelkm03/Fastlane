//
//  VStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "VPaginationManager.h"
#import "VStreamTableDataSource.h"
#import "VStreamTableViewController.h"
#import "VStreamTableViewController+ContentCreation.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConstants.h"

#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"
#import "VNewContentViewController.h"

#import "NSString+VParseHelp.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"

#import "VStreamToContentAnimator.h"
#import "VStreamToCommentAnimator.h"

// Views
#import "VNoContentView.h"

//Cells
#import "VStreamViewCell.h"
#import "VStreamPollCell.h"

//ObjectManager
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VAbstractFilter.h"

#import "VAnalyticsRecorder.h"

#import "VThemeManager.h"

@interface VStreamTableViewController() <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, VStreamTableDataDelegate>

@property (strong, nonatomic, readwrite) VStreamTableDataSource *tableDataSource;
@property (strong, nonatomic) id<UIViewControllerTransitioningDelegate> transitionDelegate;
@property (strong, nonatomic) UIActivityIndicatorView *bottomRefreshIndicator;
@property (strong, nonatomic) NSCache *preloadImageCache;
@property (strong, nonatomic) VContentViewController *contentViewController;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;

@property (strong, nonatomic) VStream *defaultStream;

@property (strong, nonatomic) NSString *streamName;

@property (nonatomic, assign) BOOL hasRefreshed;

@end

@implementation VStreamTableViewController

+ (instancetype)homeStream
{
    VStream *defaultStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStreamTableViewController *stream = [self streamWithDefaultStream:defaultStream name:@"home" title:NSLocalizedString(@"Home", nil)];
    [stream addCreateButton];
    return  stream;
}

+ (instancetype)communityStream
{
    VStream *defaultStream = [VStream streamForCategories: VUGCCategories()];
    VStreamTableViewController *stream = [self streamWithDefaultStream:defaultStream name:@"ugc" title:NSLocalizedString(@"Community", nil)];
    [stream addCreateButton];
    return  stream;
}

+ (instancetype)ownerStream
{
    VStream *defaultStream = [VStream streamForCategories: VOwnerCategories()];
    return [self streamWithDefaultStream:defaultStream name:NSLocalizedString(@"Channel", nil) title:NSLocalizedString(@"Channel", nil)];
}

+ (instancetype)hashtagStreamWithHashtag:(NSString *)hashtag
{
    VStream *defaultStream = [VStream streamForHashTag:hashtag];
    return [self streamWithDefaultStream:defaultStream name:@"hashtag" title:[@"#" stringByAppendingString:hashtag]];
}

+ (instancetype)streamWithDefaultStream:(VStream *)stream name:(NSString *)name title:(NSString *)title
{
    UIViewController   *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamTableViewController *streamTableView = (VStreamTableViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamStoryboardID];
    
    streamTableView.streamName = name;
    streamTableView.title = title;
    streamTableView.defaultStream = stream;
    streamTableView.currentStream = stream;
    
    return streamTableView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasRefreshed = NO;
    
    self.tableDataSource = [[VStreamTableDataSource alloc] initWithStream:[self currentStream]];
    self.tableDataSource.delegate = self;
    self.tableDataSource.stream = self.currentStream;
    self.tableDataSource.tableView = self.tableView;
    self.tableView.dataSource = self.tableDataSource;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    [self registerCells];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willCommentSequence:)
                                                 name:kStreamsWillCommentNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSourceDidChange:)
                                                 name:VStreamTableDataSourceDidChangeNotification
                                               object:self.tableDataSource];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (NSCache *)preloadImageCache
{
    if (!_preloadImageCache)
    {
        self.preloadImageCache = [[NSCache alloc] init];
        self.preloadImageCache.countLimit = 20;
    }
    return _preloadImageCache;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateNoContentViewAnimated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.lastSelectedIndexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[self.lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:self.viewName];
    
    VAbstractFilter *filter = [[VObjectManager sharedManager] filterForStream:self.tableDataSource.stream];
    if (!self.tableDataSource.count && ![[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter])
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

- (NSString *)viewName
{
    NSString *viewName = @"Stream";
    if (self.streamName)
    {
        viewName = [NSString stringWithFormat:@"Stream - %@", self.streamName];
    }
    return viewName;
}

- (void)setFilterType:(VStreamFilter)filterType
{
    if (_filterType == filterType)
    {
        return;
    }
    
    _filterType = filterType;
    
    switch (self.filterType)
    {
        case VStreamFilterFeatured:
            self.currentStream = [VStream hotSteamForSteamName:self.streamName];
            break;
            
        case VStreamFilterRecent:
            self.currentStream = [self defaultStream];
            break;
            
        case VStreamFilterFollowing:
            self.currentStream = [VStream followerStreamForStreamName:self.streamName user:nil];
            break;
            
        default:
            VLog(@"Unknown filter type, using default filter");
            self.currentStream = [self defaultStream];
            break;
    }
    
    self.tableView.contentOffset = CGPointMake(-self.tableView.contentInset.left, -self.tableView.contentInset.top);
    
    if ([self isViewLoaded] && self.view.window && !self.tableDataSource.count)
    {
        [self refresh:nil];
    }
}

- (void)setCurrentStream:(VStream *)currentStream
{
    _currentStream = currentStream;
    if ([self isViewLoaded])
    {
        self.tableDataSource.stream = currentStream;
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
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:[self.tableDataSource sequenceAtIndexPath:indexPath]];
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel];
    [self presentViewController:contentViewController
                       animated:YES
                     completion:nil];
//    self.lastSelectedIndexPath = indexPath;
    
//    self.contentViewController = [[VContentViewController alloc] init];
    
//    VSequence* sequence = [self.tableDataSource sequenceAtIndexPath:indexPath];
//    if ([sequence.expiresAt timeIntervalSinceNow] < 0)
//    {
//        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//        return;
//    }
    
//    self.selectedSequence = [self.tableDataSource sequenceAtIndexPath:indexPath];
//    VStreamViewCell* cell = (VStreamViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    if ([cell isKindOfClass:[VStreamPollCell class]])
//    {
//        VStreamPollCell *pollCell = (VStreamPollCell *)cell;
//        [self.contentViewController setLeftPollThumbnail:pollCell.previewImageView.image];
//        [self.contentViewController setRightPollThumbnail:pollCell.previewImageTwo.image];
//    }
//    
//    //Every time we go to the content view, update the sequence
//    [[VObjectManager sharedManager] fetchSequence:cell.sequence.remoteId
//                                     successBlock:nil
//                                        failBlock:nil];
//    
//    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
//    [self.delegate streamWillDisappear];
    
//    CGFloat contentMediaViewOffset = [VContentViewController estimatedContentMediaViewOffsetForBounds:self.view.bounds sequence:sequence];
//    if (tableView.contentOffset.y == cell.frame.origin.y - contentMediaViewOffset)
//    {
//        [self.navigationController pushViewController:self.contentViewController animated:YES];
//    }
//    else
//    {
//        self.tableView.userInteractionEnabled = NO;
//        [UIView animateWithDuration:0.2f
//                              delay:0.0f
//             usingSpringWithDamping:1.0f
//              initialSpringVelocity:0.0f
//                            options:UIViewAnimationOptionBeginFromCurrentState
//                         animations:^
//        {
//            [tableView setContentOffset:CGPointMake(cell.frame.origin.x, cell.frame.origin.y - contentMediaViewOffset) animated:NO];
//        }
//                         completion:^(BOOL finished)
//        {
//            self.tableView.userInteractionEnabled = YES;
//            [self.navigationController pushViewController:self.contentViewController animated:YES];
//        }];
//
//    }
}

#pragma mark - Cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence *sequence = [self.tableDataSource sequenceAtIndexPath:indexPath];

    CGFloat cellHeight;
    
    if ([sequence isPoll])
    {
        cellHeight = kStreamDoublePollCellHeight;
    }
    else
    {
        cellHeight = kStreamViewCellHeight;
    }
    
    return cellHeight;
}

- (UITableViewCell *)dataSource:(VStreamTableDataSource *)dataSource cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath
{
    VStreamViewCell *cell;
    
    if ([sequence isPoll])
    {
        cell = [dataSource.tableView dequeueReusableCellWithIdentifier:VStreamPollCellNibName
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
    
    if ([dataSource count] > (NSUInteger)indexPath.row + 2u)
    {
        NSIndexPath *preloadPath = [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section];
        VSequence *preloadSequence = [dataSource sequenceAtIndexPath:preloadPath];
        
        for (NSURL *imageUrl in [preloadSequence initialImageURLs])
        {
            UIImageView *preloadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
    
    [self.tableView registerNib:[UINib nibWithNibName:VStreamPollCellNibName bundle:nil]
         forCellReuseIdentifier:VStreamPollCellNibName];
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
        self.hasRefreshed = YES;
        [self updateNoContentViewAnimated:YES];
        [self.refreshControl endRefreshing];
        if (completionBlock)
        {
            completionBlock();
        }
    }
                                     failure:^(NSError *error)
    {
        self.hasRefreshed = YES;
        [self updateNoContentViewAnimated:YES];
        [self.refreshControl endRefreshing];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"RefreshError", @"");
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:3.0];
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

#pragma mark No Content

- (void)updateNoContentViewAnimated:(BOOL)animated
{
    if (![self hasNoContentView])
    {
        return;
    }
    
    void (^noContentUpdates)(void);
    
    if (self.tableDataSource.stream.sequences.count <= 0)
    {
        if (![self.tableView.backgroundView isKindOfClass:[VNoContentView class]])
        {
            VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
            self.tableView.backgroundView = noContentView;
            noContentView.titleLabel.text = self.noContentTitle;
            noContentView.messageLabel.text = self.noContentMessage;
            noContentView.iconImageView.image = self.noContentImage;
            noContentView.alpha = 0.0f;
        }
        
        self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;

        noContentUpdates = ^void(void)
        {
            self.tableView.backgroundView.alpha = (self.hasRefreshed && [self hasNoContentView]) ? 1.0f : 0.0f;
        };
    }
    else
    {
        noContentUpdates = ^void(void)
        {
            self.tableView.backgroundView.alpha = 0.0f;
        };
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:noContentUpdates
                         completion:nil];
    }
    else
    {
        noContentUpdates();
    }
}

- (BOOL)hasNoContentView
{
    return (self.noContentImage || self.noContentTitle || self.noContentMessage);
}

#pragma mark - Predicates

- (VStream *)defaultStream
{
    return _defaultStream ?: [VStream streamForCategories:[self sequenceCategories]];
}

- (NSArray *)sequenceCategories
{
    return nil;
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [newBackgroundView setBlurredImageWithURL:url
                             placeholderImage:placeholderImage
                                    tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.tableView.backgroundView = newBackgroundView;
}

#pragma mark - Notifications

- (void)willCommentSequence:(NSNotification *)notification
{
    VStreamViewCell *cell = (VStreamViewCell *)notification.object;
    
    self.lastSelectedIndexPath = [self.tableView indexPathForCell:cell];

    [self setBackgroundImageWithURL:[[cell.sequence initialImageURLs] firstObject]];
    [self.delegate streamWillDisappear];

    VCommentsContainerViewController *commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = cell.sequence;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

- (void)dataSourceDidChange:(NSNotification *)notification
{
    self.hasRefreshed = YES;
    [self updateNoContentViewAnimated:YES];
}

#pragma mark - VAnimation

- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    NSIndexPath *path = [self.tableDataSource indexPathForSequence:self.selectedSequence];
    VStreamViewCell *selectedCell = (VStreamViewCell *) [self.tableView cellForRowAtIndexPath:path];
    
    //If the tableview updates while we are in the content view it will reset the cells to their proper positions.
    //In this case, we reset them
    CGFloat centerPoint = selectedCell ? selectedCell.center.y : self.tableView.center.y + self.tableView.contentOffset.y;

    for (VStreamViewCell *cell in self.repositionedCells)
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
              for (VStreamViewCell *cell in self.repositionedCells)
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
                  [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -self.tableView.contentInset.top) animated:YES];
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
         
         NSMutableArray *repositionedCells = [[NSMutableArray alloc] init];
         
         NSIndexPath *path = [self.tableDataSource indexPathForSequence:self.selectedSequence];
         VStreamViewCell *selectedCell = (VStreamViewCell *) [self.tableView cellForRowAtIndexPath:path];
         CGFloat centerPoint = selectedCell ? selectedCell.center.y : self.tableView.center.y + self.tableView.contentOffset.y;

         for (VStreamViewCell *cell in [self.tableView visibleCells])
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
    CGFloat scrollThreshold = scrollView.contentSize.height * 0.75f;
    if (self.tableDataSource.filter.currentPageNumber.intValue < self.tableDataSource.filter.maxPageNumber.intValue &&
        self.tableDataSource.count &&
        ![self.tableDataSource isFilterLoading] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollThreshold)
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
