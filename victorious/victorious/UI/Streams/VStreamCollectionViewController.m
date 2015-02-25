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
#import "VStreamCollectionCell.h"
#import "VStreamCollectionCellPoll.h"
#import "VMarqueeCollectionCell.h"
#import "VStreamCollectionCellWebContent.h"

#warning Temporary
#import "VRootViewController.h"

//Controllers
#import "VAlertController.h"
#import "VCommentsContainerViewController.h"
#import "VCreatePollViewController.h"
#import "VUploadProgressViewController.h"
#import "VUserProfileViewController.h"
#import "VMarqueeController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VSequenceActionController.h"
#import "VWebBrowserViewController.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VWorkspaceFlowController.h"

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
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIViewController+VLayoutInsets.h"

#import "VConstants.h"
#import "VTracking.h"
#import "VHashtagStreamCollectionViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kMarqueeKey = @"marquee";
static NSString * const kStreamCollectionStoryboardId = @"StreamCollection";
static CGFloat const kTemplateCLineSpacing = 8.0f;
static CGFloat const kExtraPaddingForTemplateC = 10.0f;

NSString * const VStreamCollectionViewControllerStreamURLPathKey = @"streamUrlPath";
NSString * const VStreamCollectionViewControllerCreateSequenceIconKey = @"createSequenceIcon";

@interface VStreamCollectionViewController () <VMarqueeDelegate, VSequenceActionsDelegate, VUploadProgressViewControllerDelegate, VWorkspaceFlowControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSCache *preloadImageCache;
@property (strong, nonatomic) VMarqueeController *marquee;

@property (strong, nonatomic) VUploadProgressViewController *uploadProgressViewController;
@property (strong, nonatomic) NSLayoutConstraint *uploadProgressViewYconstraint;

@property (strong, nonatomic) VSequenceActionController *sequenceActionController;

@property (nonatomic, assign) BOOL hasRefreshed;
@property (nonatomic, assign) BOOL canAddContent;

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
    
    NSString *urlPathKey = [dependencyManager stringForKey:VStreamCollectionViewControllerStreamURLPathKey];
    VStream *stream = [VStream streamForPath:urlPathKey inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    
    VStreamCollectionViewController *streamCollectionVC = [self streamViewControllerForStream:stream];
    streamCollectionVC.dependencyManager = dependencyManager;
    streamCollectionVC.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:stream];
    streamCollectionVC.streamDataSource.delegate = streamCollectionVC;
    
    if ( [[dependencyManager numberForKey:kMarqueeKey] boolValue] )
    {
        streamCollectionVC.shouldDisplayMarquee = YES;
    }
    
    if ( [[dependencyManager numberForKey:kCanAddContentKey] boolValue] )
    {
        [streamCollectionVC addCreateSequenceButton];
        [streamCollectionVC addUploadProgressView];
    }
    
    NSNumber *cellVisibilityRatio = [dependencyManager numberForKey:@"experiments.stream_atf_view_threshold"];
    if ( cellVisibilityRatio != nil )
    {
        streamCollectionVC.trackingMinRequiredCellVisibilityRatio = cellVisibilityRatio.floatValue;
    }
    
    return streamCollectionVC;
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
    
    [self.collectionView registerNib:[VMarqueeCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VStreamCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VStreamCollectionCellPoll nibForCell]
          forCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VStreamCollectionCellWebContent nibForCell]
          forCellWithReuseIdentifier:[VStreamCollectionCellWebContent suggestedReuseIdentifier]];
    
    self.collectionView.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.streamDataSource.count)
    {
        [self refresh:self.refreshControl];
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

- (void)addCreateSequenceButton
{
    UIImage *image = [self.dependencyManager templateValueOfType:[UIImage class] forKey:VStreamCollectionViewControllerCreateSequenceIconKey];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(createSequenceAction:)];
    barButton.accessibilityIdentifier = VAutomationIdentifierAddPost;
    self.navigationItem.rightBarButtonItem = barButton;
}

- (IBAction)createSequenceAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost];
    
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [self showContentTypeSelection];
}

- (void)showContentTypeSelection
{
    VAlertController *alertControler = [VAlertController actionSheetWithTitle:nil message:nil];
    [alertControler addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString(@"CancelButton", @"Cancel button") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateCancelSelected];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Video Post", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create an Image Post", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateImage];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a GIF", @"Create a gif action button.")
                                                    handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateGIFPostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo
                                                            initialImageEditState:VImageToolControllerInitialImageEditStateText
                                                         andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateGIF];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Poll", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
                                   VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                   [self.navigationController pushViewController:createViewController animated:YES];
                               }]];
    [alertControler presentInViewController:self animated:YES completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
                           initialImageEditState:(VImageToolControllerInitialImageEditState)initialImageEdit
                        andInitialVideoEditState:(VVideoToolControllerInitialVideoEditState)initialVideoEdit
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCreatePost forSessionParameterWithKey:VTrackingKeyContext];
    
    VDependencyManager *dependencyManager = [(id)self dependencyManager];
    
    VWorkspaceFlowController *workspaceFlowController = [dependencyManager templateValueOfType:[VWorkspaceFlowController class]
                                                                                        forKey:VDependencyManagerWorkspaceFlowKey
                                                                         withAddedDependencies:@{VWorkspaceFlowControllerInitialCaptureStateKey:@(initialCaptureState),
                                                                                                 VImageToolControllerInitialImageEditStateKey:@(initialImageEdit),
                                                                                                 VVideoToolControllerInitalVideoEditStateKey:@(initialVideoEdit)}];
    workspaceFlowController.videoEnabled = YES;
    workspaceFlowController.delegate = self;
    
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
{
    [self presentCreateFlowWithInitialCaptureState:initialCaptureState
                             initialImageEditState:VImageToolControllerInitialImageEditStateText
                          andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateVideo];
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
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:user];
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
    
    VSequence *sequence = (VSequence *)[self.streamDataSource itemAtIndexPath:indexPath];
    if ([(VSequence *)[self.currentStream.streamItems objectAtIndex:indexPath.row] isPoll]
        &&[[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return [VStreamCollectionCellPoll actualSizeWithCollectionViewBounds:self.collectionView.bounds sequence:sequence];
    }
    else if ([(VSequence *)[self.currentStream.streamItems objectAtIndex:indexPath.row] isPoll])
    {
        return [VStreamCollectionCellPoll desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
    }
    else if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return [VStreamCollectionCell actualSizeWithCollectionViewBounds:self.collectionView.bounds sequence:sequence];
    }
    return [VStreamCollectionCell desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kTemplateCLineSpacing : 0;
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
    VStreamCollectionCell *cell;
    
    if ([sequence isPoll])
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCellPoll suggestedReuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    else if ([sequence isPreviewWebContent])
    {
        NSString *identifier = [VStreamCollectionCellWebContent suggestedReuseIdentifier];
        VStreamCollectionCellWebContent *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                               forIndexPath:indexPath];
        cell.sequence = sequence;
        return cell;
    }
    else
    {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[VStreamCollectionCell suggestedReuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    cell.delegate = self.actionDelegate ?: self;
    cell.sequence = sequence;
    
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

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view
{
#warning Hacktastic
    [self.sequenceActionController showRemixOnViewController:self
                                                withSequence:sequence
                                        andDependencyManager:[VRootViewController rootViewController].dependencyManager];
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
    const BOOL userHasRepostedSequence = [[VObjectManager sharedManager].mainUser.repostedSequences containsObject:sequence];
    return userHasRepostedSequence;
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

- (void)didEnterBackground:(NSNotification *)notification
{
    [self.streamTrackingHelper resetCellVisibilityTracking];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insetsFromSuper = UIEdgeInsetsZero;
    
    if ( [super respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] )
    {
        insetsFromSuper = [super collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    
    if ( [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] && !self.streamDataSource.hasHeaderCell )
    {
        insetsFromSuper.top += kExtraPaddingForTemplateC;
        return insetsFromSuper;
    }
    else
    {
        return insetsFromSuper;
    }
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

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
