//
//  VStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAutomation.h"
#import "VScaffoldViewController.h"
#import "VStreamCollectionViewController.h"
#import "VStreamCollectionViewDataSource.h"
#import "VStreamCellFactory.h"
#import "VStreamCollectionCell.h"
#import "VMarqueeCollectionCell.h"

#warning Temporary
#import "VRootViewController.h"

//Controllers
#import "VAlertController.h"
#import "VCommentsContainerViewController.h"
#import "VCreatePollViewController.h"
#import "VUploadProgressViewController.h"
#import "VUserProfileViewController.h"
#import "VMarqueeController.h"
#import "VSequenceActionController.h"
#import "VWebBrowserViewController.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"

// Workspace
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"

//Views
#import "VNoContentView.h"

//Data models
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VUser.h"
#import "VHashtag.h"

//Managers
#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Discover.h"
#import "VThemeManager.h"
#import "VSettingManager.h"

//Categories
#import "NSArray+VMap.h"
#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIViewController+VLayoutInsets.h"

#import "VWorkspacePresenter.h"
#import "VConstants.h"
#import "VTracking.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VAuthorizedAction.h"

#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kCreateButtonHeight = 44.0f;

static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kMarqueeKey = @"marquee";
static NSString * const kStreamCollectionStoryboardId = @"StreamCollection";
static NSString * const kStreamATFThresholdKey = @"streamAtfViewThreshold";

NSString * const VStreamCollectionViewControllerStreamURLKey = @"streamURL";
NSString * const VStreamCollectionViewControllerCreateSequenceIconKey = @"createSequenceIcon";
NSString * const VStreamCollectionViewControllerCellComponentKey = @"streamCell";

@interface VStreamCollectionViewController () <VMarqueeDelegate, VSequenceActionsDelegate, VUploadProgressViewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSCache *preloadImageCache;
@property (strong, nonatomic) VMarqueeController *marquee;
@property (nonatomic, strong) id<VStreamCellFactory> streamCellFactory;

@property (strong, nonatomic) VUploadProgressViewController *uploadProgressViewController;
@property (strong, nonatomic) NSLayoutConstraint *uploadProgressViewYconstraint;

@property (strong, nonatomic) VSequenceActionController *sequenceActionController;

@property (nonatomic, assign) BOOL hasRefreshed;
@property (nonatomic, assign) BOOL canAddContent;

@property (nonatomic, strong) VWorkspacePresenter *workspacePresenter;

@end

@implementation VStreamCollectionViewController

#pragma mark - Factory methods

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    VStreamCollectionViewController *streamCollection = (VStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kStreamCollectionStoryboardId];
    
    streamCollection.currentStream = stream;
    return streamCollection;
}

#pragma mark VHasManagedDependencies constructor

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    
    NSString *url = [dependencyManager stringForKey:VStreamCollectionViewControllerStreamURLKey];
    NSString *path = [url v_pathComponent];
    
    VStream *stream = [VStream streamForPath:path inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    
    VStreamCollectionViewController *streamCollectionVC = [self streamViewControllerForStream:stream];
    streamCollectionVC.dependencyManager = dependencyManager;
    streamCollectionVC.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:stream];
    streamCollectionVC.streamDataSource.delegate = streamCollectionVC;
    
    if ( [[dependencyManager numberForKey:kMarqueeKey] boolValue] )
    {
        streamCollectionVC.shouldDisplayMarquee = YES;
    }
    
    NSNumber *cellVisibilityRatio = [dependencyManager numberForKey:kStreamATFThresholdKey];
    if ( cellVisibilityRatio != nil )
    {
        streamCollectionVC.trackingMinRequiredCellVisibilityRatio = cellVisibilityRatio.floatValue;
    }
    
    return streamCollectionVC;
}

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.canShowContent = YES;
}

#pragma mark - View Heirarchy

- (void)dealloc
{
    self.marquee = nil;
    self.streamDataSource.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasRefreshed = NO;
    self.sequenceActionController = [[VSequenceActionController alloc] init];
    self.sequenceActionController.dependencyManager = self.dependencyManager;
    
    [self.collectionView registerNib:[VMarqueeCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]];
    
    self.streamCellFactory = [self.dependencyManager templateValueConformingToProtocol:@protocol(VStreamCellFactory) forKey:VStreamCollectionViewControllerCellComponentKey];
    [self.streamCellFactory registerCellsWithCollectionView:self.collectionView];
    
    self.collectionView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    if ( self.streamDataSource == nil )
    {
        self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
        self.streamDataSource.delegate = self;
        self.streamDataSource.collectionView = self.collectionView;
        self.collectionView.dataSource = self.streamDataSource;
    }
    
    self.collectionView.dataSource = self.streamDataSource;
    self.streamDataSource.collectionView = self.collectionView;
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSourceDidChange:)
                                                 name:VStreamCollectionDataSourceDidChangeNotification
                                               object:self.streamDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ( self.streamDataSource.count == 0 )
    {
        [self refresh:self.refreshControl];
    }
    else
    {
        /*
         We already have marquee content so we need to restart the timer to make sure the marquee continues
         to rotate in case it's timer has been invalidated by the presentation of another viewController
         */
        [self.marquee enableTimer];
    }

    for (VBaseCollectionViewCell *cell in self.collectionView.visibleCells)
    {
        if ( [cell isKindOfClass:[VStreamCollectionCell class]] )
        {
            [(VStreamCollectionCell *)cell reloadCommentsCount];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView flashScrollIndicators];
    [self updateCellVisibilityTracking];
    [self updateCurrentlyPlayingMediaAsset];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

- (VMarqueeController *)marquee
{
    if (!_marquee)
    {
        VStream *marquee = [VStream streamForMarqueeInContext:[VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        _marquee = [[VMarqueeController alloc] initWithStream:marquee];
        _marquee.delegate = self;
    }
    return _marquee;
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
    self.title = currentStream.name;
    self.navigationItem.title = currentStream.name;
    [super setCurrentStream:currentStream];
}

- (void)setShouldDisplayMarquee:(BOOL)shouldDisplayMarquee
{
    _shouldDisplayMarquee = shouldDisplayMarquee;
    self.streamDataSource.hasHeaderCell = shouldDisplayMarquee;
}

- (void)v_setLayoutInsets:(UIEdgeInsets)layoutInsets
{
    [super v_setLayoutInsets:layoutInsets];
    self.uploadProgressViewYconstraint.constant = layoutInsets.top;
}

#pragma mark - Sequence Creation

- (BOOL)isUserPostAllowedInStream:(VStream *)stream withDependencyManager:(VDependencyManager *)dependencyManager
{
    const BOOL isUserPostAllowedByTemplate = [[dependencyManager numberForKey:kCanAddContentKey] boolValue];
    const BOOL isUserPostAllowedByStream = stream.isUserPostAllowed.boolValue;
    
    return isUserPostAllowedByTemplate || isUserPostAllowedByStream;
}

- (void)updateUserPostAllowed
{
    [super updateUserPostAllowed];
    
    BOOL userPostAllowed = [self isUserPostAllowedInStream:self.currentStream withDependencyManager:self.dependencyManager];
    if ( userPostAllowed )
    {
        [self addUploadProgressView];
    }
    
    UINavigationItem *navigationItem = self.navigationItem;
    if ( self.multipleViewControllerChildDelegate != nil )
    {
        navigationItem = [self.multipleViewControllerChildDelegate parentNavigationItem];
    }
    [self installCreateButtonOnNavigationItem:navigationItem
                             initiallyVisible:userPostAllowed];
    
    navigationItem.rightBarButtonItem.customView.hidden = !userPostAllowed;
}

- (void)installCreateButtonOnNavigationItem:(UINavigationItem *)navigationItem
                           initiallyVisible:(BOOL)initiallyVisible
{
    if (!self.canShowContent)
    {
        return;
    }
    UIImage *image = [self.dependencyManager imageForKey:VStreamCollectionViewControllerCreateSequenceIconKey];
    UIButton *createbutton = [UIButton buttonWithType:UIButtonTypeSystem];
    createbutton.frame = CGRectMake(0, 0, kCreateButtonHeight, kCreateButtonHeight);
    [createbutton setImage:image forState:UIControlStateNormal];
    [createbutton addTarget:self action:@selector(createSequenceAction:) forControlEvents:UIControlEventTouchUpInside];
    createbutton.hidden = !initiallyVisible;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:createbutton];
    barButton.accessibilityIdentifier = VAutomationIdentifierAddPost;
    [navigationItem setRightBarButtonItem:barButton animated:NO];
}

- (void)createSequenceAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost];
    
    __weak typeof(self) weakSelf = self;
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:VAuthorizationContextCreatePost completion:^void
     {
         weakSelf.workspacePresenter = [VWorkspacePresenter workspacePresenterWithViewControllerToPresentOn:self];
         [weakSelf.workspacePresenter present];
     }];
}

#pragma mark - VMarqueeDelegate

- (void)marqueeRefreshedContent:(VMarqueeController *)marquee
{
    self.streamDataSource.hasHeaderCell = self.marquee.streamDataSource.count;
}

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image
{
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        [self showContentViewForSequence:(VSequence *)streamItem withPreviewImage:image];
    }
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
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController rootDependencyProfileWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section != [self.streamDataSource sectionIndexForContent] )
    {
        return;
    }
    
    self.lastSelectedIndexPath = indexPath;
    
    VSequence *sequence = (VSequence *)[self.streamDataSource itemAtIndexPath:indexPath];
    UIImageView *previewImageView = nil;
    UICollectionViewCell *cell = (VStreamCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[VStreamCollectionCell class]])
    {
        previewImageView = ((VStreamCollectionCell *)cell).previewImageView;
    }
    else if ([cell isKindOfClass:[VMarqueeCollectionCell class]])
    {
        previewImageView = ((VMarqueeCollectionCell *)cell).currentPreviewImageView;
    }
    
    [self showContentViewForSequence:sequence withPreviewImage:previewImageView.image];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return [VMarqueeCollectionCell desiredSizeWithCollectionViewBounds:self.view.bounds];
    }
    else
    {
        VSequence *sequence = (VSequence *)[self.streamDataSource itemAtIndexPath:indexPath];
        return [self.streamCellFactory sizeWithCollectionViewBounds:collectionView.bounds ofCellForStreamItem:sequence];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.streamCellFactory minimumLineSpacing];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell isKindOfClass:[VStreamCollectionCell class]] )
    {
        [((VStreamCollectionCell *)cell) pauseVideo];
    }
}

#pragma mark - Activity indivator footer

- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section
{
    return [super shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:section];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
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
    VStreamCollectionCell *cell = (VStreamCollectionCell *)[self.streamCellFactory collectionView:self.collectionView cellForStreamItem:sequence atIndexPath:indexPath];
    

    if ( [cell conformsToProtocol:@protocol(VSequenceActionsSender)] )
    {
        cell.sequenceActionsDelegate = self.actionDelegate ?: self;
    }
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
            [preloadView sd_setImageWithURL:imageUrl];
            
            [self.preloadImageCache setObject:preloadView forKey:imageUrl.absoluteString];
        }
    }
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(VStreamCollectionCell *)streamCollectionCell
{
    [self.sequenceActionController showCommentsFromViewController:self sequence:sequenceObject];
}

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(VStreamCollectionCell *)streamCollectionCell
{
    [self.sequenceActionController showPosterProfileFromViewController:self sequence:sequence];
}

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view videoEdit:(VDefaultVideoEdit)defaultEdit
{
    [self.sequenceActionController showRemixOnViewController:self
                                                withSequence:sequence
                                        andDependencyManager:[VRootViewController rootViewController].dependencyManager
                                              preloadedImage:nil
                                            defaultVideoEdit:defaultEdit
                                                  completion:nil];
}

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController shareFromViewController:self sequence:sequence node:[sequence firstNode]];
}

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self willRepostSequence:sequence fromView:view completion:nil];
}

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion
{
    [self.sequenceActionController repostActionFromViewController:self node:[sequence firstNode] completion:completion];
}

- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController flagSheetFromViewController:self sequence:sequence];
}

- (BOOL)hasRepostedSequence:(VSequence *)sequence
{
    return [[VObjectManager sharedManager].mainUser.repostedSequences containsObject:sequence];;
}

- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view
{
    // Error checking
    if ( hashtag == nil || !hashtag.length )
    {
        return;
    }
    
    // Prevent another stream view for the current tag from being pushed
    if ( self.currentStream.hashtag && self.currentStream.hashtag.length )
    {
        if ( [[self.currentStream.hashtag lowercaseString] isEqualToString:[hashtag lowercaseString]] )
        {
            return;
        }
    }
    
    // Instantiate and push to stack
    VHashtagStreamCollectionViewController *vc = [VHashtagStreamCollectionViewController instantiateWithHashtag:hashtag];
    vc.dependencyManager = self.dependencyManager;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{
    //Don't set the background image for template c
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return;
    }
    
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [newBackgroundView setBlurredImageWithURL:url
                             placeholderImage:placeholderImage
                                    tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.collectionView.backgroundView = newBackgroundView;
}

- (void)showContentViewForSequence:(VSequence *)sequence withPreviewImage:(UIImage *)previewImage
{
    [self.streamTrackingHelper onStreamCellSelectedWithStream:self.currentStream sequence:sequence];
    
    [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:sequence commentId:nil placeHolderImage:previewImage];
}

#pragma mark - Upload Progress View

- (void)addUploadProgressView
{
    if ( self.uploadProgressViewController != nil )
    {
        return;
    }
    
    self.uploadProgressViewController = [VUploadProgressViewController viewControllerForUploadManager:[[VObjectManager sharedManager] uploadManager]];
    self.uploadProgressViewController.delegate = self;
    [self addChildViewController:self.uploadProgressViewController];
    self.uploadProgressViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.uploadProgressViewController.view];
    [self.uploadProgressViewController didMoveToParentViewController:self];
    
    UIView *upvc = self.uploadProgressViewController.view;
    upvc.hidden = YES;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upvc]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upvc)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:upvc
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:VUploadProgressViewControllerIdealHeight]];
    self.uploadProgressViewYconstraint = [NSLayoutConstraint constraintWithItem:upvc
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0f
                                                                       constant:self.topInset];
    [self.view addConstraint:self.uploadProgressViewYconstraint];
    
    if (self.uploadProgressViewController.numberOfUploads > 0)
    {
        [self setUploadsHidden:NO];
    }
}

- (void)setUploadProgressViewController:(VUploadProgressViewController *)uploadProgressViewController
{
    [self.uploadProgressViewController willMoveToParentViewController:nil];
    [self.uploadProgressViewController.view removeFromSuperview];
    [self.uploadProgressViewController removeFromParentViewController];
    [self addChildViewController:uploadProgressViewController];
    [self.view addSubview:uploadProgressViewController.view];
    [uploadProgressViewController didMoveToParentViewController:self];
    _uploadProgressViewController = uploadProgressViewController;
}

- (void)setUploadsHidden:(BOOL)hidden
{
    if ( !hidden && self.navigationController.navigationBarHidden )
    {
        [[self v_navigationController] setNavigationBarHidden:NO];
    }
    self.uploadProgressViewController.view.hidden = hidden;
    self.navigationBarShouldAutoHide = hidden;
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
            UIImage *newImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] preferredBackgroundColor]];
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insetsFromSuper = UIEdgeInsetsZero;
    
    if ( [super respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] )
    {
        insetsFromSuper = [super collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    
    if ( self.streamDataSource.hasHeaderCell && section == 0 )
    {
        return insetsFromSuper;
    }
    
    UIEdgeInsets insetsFromCellFactory = [self.streamCellFactory sectionInsets];
    UIEdgeInsets totalInsets = UIEdgeInsetsMake(insetsFromSuper.top + insetsFromCellFactory.top,
                                                insetsFromSuper.left + insetsFromCellFactory.left,
                                                insetsFromSuper.bottom + insetsFromCellFactory.bottom,
                                                insetsFromSuper.right + insetsFromCellFactory.right);
    return totalInsets;
}

#pragma mark - VUploadProgressViewControllerDelegate methods

- (void)uploadProgressViewController:(VUploadProgressViewController *)upvc isNowDisplayingThisManyUploads:(NSInteger)uploadCount
{
    BOOL uploadsShouldBeHidden = uploadCount <= 0;
    [self setUploadsHidden:uploadsShouldBeHidden];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    [self updateCellVisibilityTracking];
    
    [self updateCurrentlyPlayingMediaAsset];
}

#pragma mark - Cell visibility

- (void)updateCellVisibilityTracking
{
    const CGRect streamVisibleRect = self.collectionView.bounds;
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    [visibleCells enumerateObjectsUsingBlock:^(VStreamCollectionCell *cell, NSUInteger idx, BOOL *stop)
     {
         if ( ![cell isKindOfClass:[VStreamCollectionCell class]] )
         {
             return;
         }
         
         // Calculate visible ratio for the whole cell
         const CGRect intersection = CGRectIntersection( streamVisibleRect, cell.frame );
         const float visibleRatio = CGRectGetHeight( intersection ) / CGRectGetHeight( cell.frame );
         [self collectionViewCell:cell didUpdateCellVisibility:visibleRatio];
     }];
}

- (void)updateCurrentlyPlayingMediaAsset
{
    const CGRect streamVisibleRect = self.collectionView.bounds;
    
    // Was a video begins playing, all other visible cells will be paused
    __block BOOL didPlayVideo = NO;
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    [visibleCells enumerateObjectsUsingBlock:^(VStreamCollectionCell *cell, NSUInteger idx, BOOL *stop)
     {
         if ( ![cell isKindOfClass:[VStreamCollectionCell class]] )
         {
             return;
         }
         
         if ( didPlayVideo )
         {
             [cell pauseVideo];
         }
         else
         {
             // Calculate visible ratio for just the media content of the cell
             const CGRect contentFrameInCell = CGRectMake( CGRectGetMinX(cell.mediaContentFrame) + CGRectGetMinX(cell.frame),
                                                          CGRectGetMinY(cell.mediaContentFrame) + CGRectGetMinY(cell.frame),
                                                          CGRectGetWidth(cell.mediaContentFrame),
                                                          CGRectGetHeight(cell.mediaContentFrame) );
             
             if ( CGRectGetHeight( contentFrameInCell ) > 0.0 )
             {
                 const CGRect contentIntersection = CGRectIntersection( streamVisibleRect, contentFrameInCell );
                 const float mediaContentVisibleRatio = CGRectGetHeight( contentIntersection ) / CGRectGetHeight( contentFrameInCell );
                 if ( mediaContentVisibleRatio >= 0.8f )
                 {
                     [cell playVideo];
                     didPlayVideo = YES;
                 }
                 else
                 {
                     [cell pauseVideo];
                 }
             }
         }
     }];
}

- (void)collectionViewCell:(VStreamCollectionCell *)cell didUpdateCellVisibility:(CGFloat)visibiltyRatio
{
    if ( visibiltyRatio >= self.trackingMinRequiredCellVisibilityRatio )
    {
        [self.streamTrackingHelper onStreamCellDidBecomeVisibleWithStream:self.currentStream sequence:cell.sequence];
    }
}

@end
