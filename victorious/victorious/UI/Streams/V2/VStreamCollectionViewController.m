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
#import "VStreamCollectionCellPoll.h"
#import "VMarqueeCollectionCell.h"

//Controllers
#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"
#import "VUserProfileViewController.h"
#import "VMarqueeController.h"
#import "VAuthorizationViewControllerFactory.h"

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
#import "VSettingManager.h"

//Categories
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIViewController+VNavMenu.h"

#import "VConstants.h"

static NSString * const kStreamCollectionStoryboardId = @"kStreamCollection";
static CGFloat const kGreyBackgroundColor = 0.94509803921;
static CGFloat const kTemplateCLineSpacing = 8;

@interface VStreamCollectionViewController () <VNavigationHeaderDelegate, UICollectionViewDelegate, VMarqueeDelegate, VSequenceActionsDelegate>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSCache *preloadImageCache;
@property (strong, nonatomic) VMarqueeController *marquee;

@property (nonatomic, assign) BOOL hasRefreshed;

@end

@implementation VStreamCollectionViewController

#pragma mark - Factory methods

+ (instancetype)homeStreamCollection
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    VStreamCollectionViewController *homeStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream, followingStream]];
    homeStream.title = NSLocalizedString(@"Home", nil);
    homeStream.shouldShowHeaderLogo = YES;
    homeStream.shouldDisplayMarquee = YES;
    homeStream.hasAddAction = YES;
    
    return homeStream;
}

+ (instancetype)communityStreamCollection
{
    VStream *recentStream = [VStream streamForCategories: VUGCCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    VStreamCollectionViewController *communityStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream]];
    communityStream.title = NSLocalizedString(@"Community", nil);
    communityStream.hasAddAction = YES;
    
    return communityStream;
}

+ (instancetype)ownerStreamCollection
{
    VStream *recentStream = [VStream streamForCategories: VOwnerCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"owner"];
    
    VStreamCollectionViewController *ownerStream = [self streamViewControllerForDefaultStream:recentStream andAllStreams:@[hotStream, recentStream]];
    ownerStream.title = NSLocalizedString(@"Owner", nil);
    
    return ownerStream;
}

+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams
{
    VStreamCollectionViewController *streamColllection = [self streamViewControllerForStream:stream];

    streamColllection.allStreams = allStreams;
    
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:allStreams.count];
    for (VStream *stream in allStreams)
    {
        [titles addObject:stream.name];
    }
    
    [streamColllection addNewNavHeaderWithTitles:titles];
    
    return streamColllection;
}

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamCollectionViewController *streamColllection = (VStreamCollectionViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamCollectionStoryboardId];
    
    streamColllection.defaultStream = stream;
    streamColllection.currentStream = stream;
    
    return streamColllection;
}

#pragma mark - View Heirarchy

- (void)dealloc
{
    self.marquee.delegate = nil;
    self.streamDataSource.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.hasRefreshed = NO;
    
    [self.collectionView registerNib:[VMarqueeCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VStreamCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VStreamCollectionCellPoll nibForCell]
          forCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]];
    
    self.collectionView.backgroundColor = [self preferredBackgroundColor];
    
    VStream *marquee = [VStream streamForMarqueeInContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    self.marquee = [[VMarqueeController alloc] initWithStream:marquee];
    self.marquee.delegate = self;
    
    NSInteger selectedStream = [self.allStreams indexOfObject:self.currentStream];
    self.navHeaderView.navSelector.currentIndex = selectedStream;
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.streamDataSource.shouldDisplayMarquee = self.shouldDisplayMarquee;
    self.collectionView.dataSource = self.streamDataSource;
    
    [self refresh:self.refreshControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView flashScrollIndicators];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.preloadImageCache = nil;
}

#pragma mark - Properties

- (UIColor *)preferredBackgroundColor
{
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return [UIColor colorWithWhite:kGreyBackgroundColor alpha:1];
    }
    else
    {
        return [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
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
    
    UICollectionViewCell *cell = (VStreamCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    VSequence *sequence;
    
    if ([cell isKindOfClass:[VStreamCollectionCell class]])
    {
        sequence = ((VStreamCollectionCell *)cell).sequence;
    }
    else if ([cell isKindOfClass:[VMarqueeCollectionCell class]])
    {
        sequence = (VSequence *)((VMarqueeCollectionCell *)cell).marquee.currentStreamItem;
    }

    //Every time we go to the content view, update the sequence
    [[VObjectManager sharedManager] fetchSequenceByID:sequence.remoteId
                                         successBlock:nil
                                            failBlock:nil];
    
    [self setBackgroundImageWithURL:[[sequence initialImageURLs] firstObject]];
    
    VContentViewController *contentViewController = [[VContentViewController alloc] init];
    contentViewController.sequence = sequence;
    CGFloat contentMediaViewOffset = [VContentViewController estimatedContentMediaViewOffsetForBounds:self.view.bounds sequence:sequence];
    
    if (collectionView.contentOffset.y == cell.frame.origin.y - contentMediaViewOffset)
    {
        [self.navigationController pushViewController:contentViewController animated:YES];
    }
    else
    {
        collectionView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
         {
             [collectionView setContentOffset:CGPointMake(collectionView.contentOffset.x, cell.frame.origin.y - contentMediaViewOffset) animated:NO];
         }
                         completion:^(BOOL finished)
         {
             collectionView.userInteractionEnabled = YES;
             [self.navigationController pushViewController:contentViewController animated:YES];
         }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.shouldDisplayMarquee && indexPath.section == 0)
    {
        return [VMarqueeCollectionCell desiredSizeWithCollectionViewBounds:self.view.bounds];
    }
    else if ([(VSequence *)[self.currentStream.streamItems objectAtIndex:indexPath.row] isPoll])
    {
        return [VStreamCollectionCellPoll desiredSizeWithCollectionViewBounds:self.view.bounds];
    }
    return [VStreamCollectionCell desiredSizeWithCollectionViewBounds:self.view.bounds];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kTemplateCLineSpacing : 0;
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
    
    VSequence *sequence = (VSequence *)[self.currentStream.streamItems objectAtIndex:indexPath.row];
    VStreamCollectionCell *cell;
    
    if ([sequence isPoll])
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    cell.sequence = sequence;
    cell.delegate = self;
    
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

- (BOOL)navHeaderView:(VNavigationHeaderView *)navHeaderView changedToIndex:(NSInteger)index
{
    
    if (index == VStreamFilterFollowing && ![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return NO;
    }

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

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(VStreamCollectionCell *)streamCollectionCell
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

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(VStreamCollectionCell *)streamCollectionCell
{
    //If this cell is from the profile we should disable going to the profile
    BOOL fromProfile = NO;
    for (UIViewController *vc in self.parentViewController.navigationController.viewControllers)
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
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:sequence.user];
    [self.navigationController pushViewController:profileViewController animated:YES];
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
            UIImage *newImage = [UIImage resizeableImageWithColor:[self preferredBackgroundColor]];
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
