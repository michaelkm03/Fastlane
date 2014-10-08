//
//  VStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VStreamCollectionCell.h"
#import "VMarqueeCollectionCell.h"

//Controllers
#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"
#import "VUserProfileViewController.h"
#import "VMarqueeController.h"

//Views
#import "VNavigationHeaderView.h"
#import "VNoContentView.h"
#import "MBProgressHUD.h"

//Data models
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"

//Managers
#import "VObjectManager+Sequence.h"
#import "VAnalyticsRecorder.h"
#import "VThemeManager.h"

//Categories
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

#import "VConstants.h"

static NSString * const kStreamCollectionStoryboardId = @"kStreamCollection";

@interface VStreamCollectionViewController () <VNavigationHeaderDelegate, UICollectionViewDelegate, VMarqueeDelegate>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSCache *preloadImageCache;
@property (strong, nonatomic) NSString *headerTitle;
@property (strong, nonatomic) VMarqueeController *marquee;

@property (nonatomic, assign) BOOL hasRefreshed;
@property (nonatomic) BOOL shouldDisplayMarquee;

@end

@implementation VStreamCollectionViewController

#pragma mark - Factory methods

+ (instancetype)homeStreamCollection
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    VStreamCollectionViewController *homeStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream, followingStream]];
    homeStream.headerTitle = NSLocalizedString(@"Home", nil);
    homeStream.shouldShowHeaderLogo = YES;
    homeStream.shouldDisplayMarquee = YES;
    return homeStream;
}


+ (instancetype)communityStream
{
    VStream *recentStream = [VStream streamForCategories: VUGCCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    VStreamCollectionViewController *homeStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream]];
    homeStream.headerTitle = NSLocalizedString(@"Community", nil);

//    [stream addCreateButton];
    
    return homeStream;
}

+ (instancetype)ownerStream
{
    VStream *recentStream = [VStream streamForCategories: VOwnerCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    VStreamCollectionViewController *homeStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream]];
    homeStream.headerTitle = NSLocalizedString(@"Community", nil);
    
    //    [stream addCreateButton];
    
    return homeStream;
}


+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamCollectionViewController *streamColllection = (VStreamCollectionViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamCollectionStoryboardId];
    
    streamColllection.defaultStream = stream;
    streamColllection.currentStream = stream;
    streamColllection.allStreams = allStreams;
    
    return streamColllection;
}

#pragma mark - View Heirarchy

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.hasRefreshed = NO;
    
    [self.collectionView registerNib:[VMarqueeCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]];
    
    UINib *nib = [UINib nibWithNibName:VStreamCollectionCellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VStreamCollectionCellName];
    
    self.collectionView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    
    VStream *marquee = [VStream streamForMarqueeInContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    self.marquee = [[VMarqueeController alloc] initWithStream:marquee];
    self.marquee.delegate = self;
    
    NSInteger selectedStream = [self.allStreams indexOfObject:self.currentStream];
    [self.navHeaderView.segmentedControl setSelectedSegmentIndex:selectedStream];
    self.navHeaderView.headerText = self.headerTitle ?: self.currentStream.name;
    self.navHeaderView.showHeaderLogoImage = self.shouldShowHeaderLogo;

    self.streamDataSource.shouldDisplayMarquee = self.shouldDisplayMarquee;
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navHeaderView updateUI];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.preloadImageCache = nil;
}

#pragma mark - Properties

- (NSCache *)preloadImageCache
{
    if (!_preloadImageCache)
    {
        self.preloadImageCache = [[NSCache alloc] init];
        self.preloadImageCache.countLimit = 20;
    }
    return _preloadImageCache;
}

- (void)setCurrentStream:(VStream *)currentStream
{
    if ([currentStream.apiPath isEqualToString:self.defaultStream.apiPath])
    {
        self.streamDataSource.shouldDisplayMarquee =  self.shouldDisplayMarquee;
    }
    else
    {
        self.streamDataSource.shouldDisplayMarquee = NO;
    }
    
    [super setCurrentStream:currentStream];
}

#pragma mark - VMarqueeDelegate

- (void)marqueeRefreshedContent:(VMarqueeController *)marquee
{
    NSInteger count = self.marquee.streamDataSource.count;
    
    if (self.streamDataSource.shouldDisplayMarquee != count)
    {
        self.streamDataSource.shouldDisplayMarquee = count;
    }
}

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)marquee:(VMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
{
    //If this cell is from the profile we should disable going to the profile
    BOOL fromProfile = NO;
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VUserProfileViewController class]])
        {
            fromProfile = YES;
        }
    }
    if (fromProfile)
    {
        return;
    }
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastSelectedIndexPath = indexPath;
    
    VContentViewController *contentViewController = [[VContentViewController alloc] init];
    VStreamCollectionCell *cell = (VStreamCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

//    the old setup code
//    //TODO: we'll need to clean this up once they decide on the animation
//    if ([cell isKindOfClass:[VMarqueeTableViewCell class]])
//    {
//        if ([((VMarqueeTableViewCell *)cell).currentItem isKindOfClass:[VSequence class]])
//        {
//            self.contentViewController.sequence = (VSequence *)((VMarqueeTableViewCell *)cell).currentItem;
//            [self.navigationController pushViewController:self.contentViewController animated:YES];
//        }
//        return;
//    }
//    
//    if ([cell isKindOfClass:[VStreamPollCell class]])
//    {
//        VStreamPollCell *pollCell = (VStreamPollCell *)cell;
//        [self.contentViewController setLeftPollThumbnail:pollCell.previewImageView.image];
//        [self.contentViewController setRightPollThumbnail:pollCell.previewImageTwo.image];
//    }
    
    VSequence *sequence = (VSequence *)[self.streamDataSource itemAtIndexPath:indexPath];
    contentViewController.sequence = sequence;
    
    //Every time we go to the content view, update the sequence
    [[VObjectManager sharedManager] fetchSequenceByID:sequence.remoteId
                                         successBlock:nil
                                            failBlock:nil];
    
    [self setBackgroundImageWithURL:[[sequence initialImageURLs] firstObject]];
    
    CGFloat contentMediaViewOffset = [VContentViewController estimatedContentMediaViewOffsetForBounds:self.view.bounds sequence:sequence];
    if (collectionView.contentOffset.y == cell.frame.origin.y - contentMediaViewOffset)
    {
        [self.navigationController pushViewController:contentViewController animated:YES];
    }
    else
    {
        self.collectionView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
         {
             [collectionView setContentOffset:CGPointMake(cell.frame.origin.x, cell.frame.origin.y - contentMediaViewOffset) animated:NO];
         }
                         completion:^(BOOL finished)
         {
             self.collectionView.userInteractionEnabled = YES;
             [self.navigationController pushViewController:contentViewController animated:YES];
         }];
    }
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.shouldDisplayMarquee && indexPath.section == 0)
    {
        VMarqueeCollectionCell *cell = [dataSource.collectionView dequeueReusableCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]
                                                                                            forIndexPath:indexPath];
        cell.marquee = self.marquee;
        CGSize desiredSize = [VMarqueeCollectionCell desiredSizeWithCollectionViewBounds:self.view.bounds];
        cell.bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
        [cell restartAutoScroll];
        return cell;
    }
    
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    VStreamCollectionCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VStreamCollectionCellName forIndexPath:indexPath];
    cell.sequence = (VSequence *)item;
    
    [self preloadSequencesAfterIndexPath:indexPath forDataSource:dataSource];
    
    return cell;
}

- (void)preloadSequencesAfterIndexPath:(NSIndexPath *)indexPath forDataSource:(VStreamCollectionViewDataSource *)dataSource
{
    if ([dataSource count] > (NSUInteger)indexPath.row + 2u)
    {
        NSIndexPath *preloadPath = [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section];
        VSequence *preloadSequence = (VSequence *)[dataSource itemAtIndexPath:preloadPath];
        
        for (NSURL *imageUrl in [preloadSequence initialImageURLs])
        {
            UIImageView *preloadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [preloadView setImageWithURL:imageUrl];
            
            [self.preloadImageCache setObject:preloadView forKey:imageUrl.absoluteString];
        }
    }
}

#pragma mark - VNavigationHeaderDelegate

- (BOOL)navHeaderView:(VNavigationHeaderView *)navHeaderView segmentControlChangeToIndex:(NSInteger)index
{
    if (self.allStreams.count <= (NSUInteger)index)
    {
        return NO;
    }
    
    self.currentStream = self.allStreams[index];
    
    if (!self.currentStream.streamItems.count)
    {
        [self refresh:self.refreshControl];
    }
    
    return YES;
}

#pragma mark - VStreamViewCellDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject inStreamCollectionCell:(VStreamCollectionCell *)streamCollectionCell
{
    VStreamCollectionCell *cell = streamCollectionCell;
    
    self.lastSelectedIndexPath = [self.collectionView indexPathForCell:cell];
    
    [self setBackgroundImageWithURL:[[sequenceObject initialImageURLs] firstObject]];
    //TODO: probly need to hide this
    //    [self.delegate streamWillDisappear];
    
    VCommentsContainerViewController *commentsTable = [VCommentsContainerViewController commentsContainerView];
    commentsTable.sequence = sequenceObject;
    [self.navigationController pushViewController:commentsTable animated:YES];
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [newBackgroundView setBlurredImageWithURL:url
                             placeholderImage:placeholderImage
                                    tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.collectionView.backgroundView = newBackgroundView;
}

#pragma mark - Notifications

- (void)dataSourceDidChange:(NSNotification *)notification
{
    self.hasRefreshed = YES;
    [self updateNoContentViewAnimated:YES];
}

- (void)updateNoContentViewAnimated:(BOOL)animated
{
    if (!self.noContentView)
    {
        return;
    }
    
    void (^noContentUpdates)(void);
    
    if (self.streamDataSource.stream.streamItems.count <= 0)
    {
        if (![self.collectionView.backgroundView isEqual:self.noContentView])
        {
            self.collectionView.backgroundView = self.noContentView;
        }
        
        self.refreshControl.layer.zPosition = self.collectionView.backgroundView.layer.zPosition + 1;
        
        noContentUpdates = ^void(void)
        {
            self.collectionView.backgroundView.alpha = (self.hasRefreshed && self.noContentView) ? 1.0f : 0.0f;
        };
    }
    else
    {
        noContentUpdates = ^void(void)
        {
            UIImage *newImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor]];
            self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:newImage];
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

@end
