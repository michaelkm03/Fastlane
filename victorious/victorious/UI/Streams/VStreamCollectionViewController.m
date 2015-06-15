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
#import "VStreamCellTracking.h"
#import "VAbstractMarqueeCollectionViewCell.h"
#import "VStreamCollectionViewParallaxFlowLayout.h"

//Controllers
#import "VAlertController.h"
#import "VCommentsContainerViewController.h"
#import "VCreatePollViewController.h"
#import "VUploadProgressViewController.h"
#import "VUserProfileViewController.h"
#import "VSequenceActionController.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"

// Workspace
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VTextWorkspaceFlowController.h"

//Views
#import "VNoContentView.h"
#import "VStreamCellFocus.h"

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
#import "VUploadManager.h"

//Categories
#import "NSArray+VMap.h"
#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIViewController+VLayoutInsets.h"

#import "VURLMacroReplacement.h"
#import "VWorkspacePresenter.h"
#import "VConstants.h"
#import "VTracking.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VAuthorizedAction.h"

#import "VFullscreenMarqueeSelectionDelegate.h"
#import "VAbstractMarqueeController.h"

#import <SDWebImage/SDWebImagePrefetcher.h>
#import <FBKVOController.h>

#import "VDirectoryCollectionViewController.h"
#import "VDependencyManager+VUserProfile.h"
#import "VHashtagSelectionResponder.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VCoachmarkManager.h"
#import "VCoachmarkDisplayer.h"
#import "VDependencyManager+VCoachmarkManager.h"

const CGFloat VStreamCollectionViewControllerCreateButtonHeight = 44.0f;

static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kHasHeaderParallaxKey = @"hasHeaderParallax";
static NSString * const kStreamCollectionStoryboardId = @"StreamCollection";
static NSString * const kStreamATFThresholdKey = @"streamAtfViewThreshold";

NSString * const VStreamCollectionViewControllerStreamURLKey = @"streamURL";
NSString * const VStreamCollectionViewControllerCellComponentKey = @"streamCell";
NSString * const VStreamCollectionViewControllerMarqueeComponentKey = @"marqueeCell";

static NSString * const kRemixStreamKey = @"remixStream";
static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";
static NSString * const kMarqueeDestinationDirectory = @"destinationDirectory";

@interface VStreamCollectionViewController () <VSequenceActionsDelegate, VMarqueeSelectionDelegate, VMarqueeDataDelegate, VSequenceActionsDelegate, VUploadProgressViewControllerDelegate, UICollectionViewDelegateFlowLayout, VHashtagSelectionResponder, VCoachmarkDisplayer>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) id<VStreamCellFactory> streamCellFactory;
@property (nonatomic, strong) VAbstractMarqueeController *marqueeCellController;

@property (strong, nonatomic) VUploadProgressViewController *uploadProgressViewController;
@property (strong, nonatomic) NSLayoutConstraint *uploadProgressViewYconstraint;

@property (strong, nonatomic) VSequenceActionController *sequenceActionController;

@property (nonatomic, assign) BOOL hasRefreshed;

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
    
    NSDictionary *streamContentAccessory = [dependencyManager templateValueOfType:[NSDictionary class] forKey:@"streamContentAccessory"];
    if ( streamContentAccessory != nil )
    {
        NSDictionary *accessoryScreens = @{ @"accessoryScreens" : @[ streamContentAccessory ] };
        VDependencyManager *childDependencyManager = [dependencyManager childDependencyManagerWithAddedConfiguration:accessoryScreens];
        dependencyManager = childDependencyManager;
    }
    
    NSString *url = [dependencyManager stringForKey:VStreamCollectionViewControllerStreamURLKey];

    NSString *sequenceID = [dependencyManager stringForKey:kSequenceIDKey];
    if ( sequenceID != nil )
    {
        VURLMacroReplacement *urlMacroReplacement = [[VURLMacroReplacement alloc] init];
        url = [urlMacroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kSequenceIDMacro: sequenceID }
                                                                   inURLString:url];
    }
    NSString *path = [url v_pathComponent];
    
    VStream *stream = [VStream streamForPath:path inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    
    VStreamCollectionViewController *streamCollectionVC = [self streamViewControllerForStream:stream];
    streamCollectionVC.dependencyManager = dependencyManager;
    streamCollectionVC.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:stream];
    streamCollectionVC.streamDataSource.delegate = streamCollectionVC;
    
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
    self.canShowMarquee = YES;
}

#pragma mark - View Heirarchy

- (void)dealloc
{
    self.streamDataSource.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasRefreshed = NO;
    self.sequenceActionController = [[VSequenceActionController alloc] init];
    self.sequenceActionController.dependencyManager = self.dependencyManager;
    
    self.streamCellFactory = [self.dependencyManager templateValueConformingToProtocol:@protocol(VStreamCellFactory) forKey:VStreamCollectionViewControllerCellComponentKey];

    if ([self.streamCellFactory respondsToSelector:@selector(registerCellsWithCollectionView:withStreamItems:)])
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView
                                                withStreamItems:[self.streamDataSource.stream.streamItems array]];
    }
    else
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView];
    }
    
    
    self.collectionView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    if ( self.streamDataSource == nil )
    {
        self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
        self.streamDataSource.delegate = self;
        self.streamDataSource.collectionView = self.collectionView;
        self.collectionView.dataSource = self.streamDataSource;
    }
    
    self.marqueeCellController = [self.dependencyManager templateValueOfType:[VAbstractMarqueeController class] forKey:VStreamCollectionViewControllerMarqueeComponentKey];
    self.marqueeCellController.stream = self.currentStream;
    self.marqueeCellController.dataDelegate = self;
    self.marqueeCellController.selectionDelegate = self;
    [self.marqueeCellController registerCollectionViewCellWithCollectionView:self.collectionView];
    self.streamDataSource.hasHeaderCell = self.currentStream.marqueeItems.count > 0;
    
    self.collectionView.dataSource = self.streamDataSource;
    self.streamDataSource.collectionView = self.collectionView;
    
    // Setup custom flow layout for parallax
    BOOL hasParallax = [[self.dependencyManager numberForKey:kHasHeaderParallaxKey] boolValue];
    if (hasParallax)
    {
        VStreamCollectionViewParallaxFlowLayout *flowLayout = [[VStreamCollectionViewParallaxFlowLayout alloc] init];
        self.collectionView.collectionViewLayout = flowLayout;
    }
    
    [self.KVOController observe:self.streamDataSource.stream
                        keyPath:NSStringFromSelector(@selector(streamItems))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(dataSourceDidChange)];
    [self.KVOController observe:self.streamDataSource
                        keyPath:NSStringFromSelector(@selector(hasHeaderCell))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(dataSourceDidChange)];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
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
        [self.marqueeCellController enableTimer];
    } 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView flashScrollIndicators];
    [self updateCellVisibilityTracking];
    [self updateCurrentlyPlayingMediaAsset];
    
    //Because a stream can be presented without refreshing, we need to refresh the user post icon here
    [self updateNavigationItems];

    [[self.dependencyManager coachmarkManager] displayCoachmarkViewInViewController:self];
    
    [self updateNavigationBarScrollOffset];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self.dependencyManager coachmarkManager] hideCoachmarkViewInViewController:self animated:animated];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Navigation

- (void)showHashtagStreamWithHashtag:(NSString *)hashtag
{
    // Prevent another stream view for the current tag from being pushed
    if ( self.currentStream.hashtag && self.currentStream.hashtag.length )
    {
        if ( [[self.currentStream.hashtag lowercaseString] isEqualToString:[hashtag lowercaseString]] )
        {
            return;
        }
    }
    
    // Instantiate and push to stack
    VHashtagStreamCollectionViewController *vc = [self.dependencyManager hashtagStreamWithHashtag:hashtag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Properties

- (void)setCurrentStream:(VStream *)currentStream
{
    self.title = NSLocalizedString(currentStream.name, @"");
    self.navigationItem.title = NSLocalizedString(currentStream.name, @"");
    [super setCurrentStream:currentStream];
}

- (void)marquee:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
{
    if ( self.canShowMarquee )
    {
        self.streamDataSource.hasHeaderCell = self.currentStream.marqueeItems.count > 0;
    }
    
    // Update scroll offset to account for marquee
    [self updateNavigationBarScrollOffset];
}

- (void)updateNavigationBarScrollOffset
{
    // Currently the navigation bar catch offset only changes if our header cell has parallax,
    // so return if it does not
    BOOL hasParallax = [[self.dependencyManager numberForKey:kHasHeaderParallaxKey] boolValue];
    if (!hasParallax)
    {
        return;
    }
    
    // Set the size of the marquee on our navigation scroll delegate so it wont hide until we scroll past the marquee
    if (self.streamDataSource.hasHeaderCell)
    {
        CGSize marqueeSize = [self.marqueeCellController desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
        self.navigationControllerScrollDelegate.catchOffset = marqueeSize.height;
    }
    else
    {
        self.navigationControllerScrollDelegate.catchOffset = 0;
    }
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

- (void)updateNavigationItems
{
    [super updateNavigationItems];
    
    [self addUploadProgressView];
    
    UINavigationItem *navigationItem = self.navigationItem;
    if ( self.multipleContainerChildDelegate != nil )
    {
        navigationItem = [self.multipleContainerChildDelegate parentNavigationItem];
    }
    [self.dependencyManager addAccessoryScreensToNavigationItem:navigationItem fromViewController:self];
}

- (void)multipleContainerDidSetSelected:(BOOL)isDefault
{
}

- (void)createNewPost
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost];
    
    __weak typeof(self) weakSelf = self;
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:VAuthorizationContextCreatePost completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         weakSelf.workspacePresenter = [VWorkspacePresenter workspacePresenterWithViewControllerToPresentOn:self dependencyManager:self.dependencyManager];
         [weakSelf.workspacePresenter present];
     }];
}

#pragma mark - VMarqueeDataDelegate

- (void)marquee:(VAbstractMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image
{
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        [self showContentViewForSequence:(VSequence *)streamItem inStreamWithID:marquee.stream.streamId withPreviewImage:image];
    }
    else if ( [streamItem isSingleStream] )
    {
        VStreamCollectionViewController *viewController = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)streamItem];
        viewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ( [streamItem isStreamOfStreams] )
    {
        VDirectoryCollectionViewController *directory = [self.dependencyManager templateValueOfType:[VDirectoryCollectionViewController class] forKey:kMarqueeDestinationDirectory];
        
        if ( directory == nil )
        {
            //We have no directory to show, just do nothing
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"GenericFailMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            return;
        }
        
        //Set the selected stream as the current stream in the directory
        directory.currentStream = (VStream *)streamItem;
        
        //Update the directory title to match the streamItem
        directory.title = streamItem.name;
        
        [self.navigationController pushViewController:directory animated:YES];
    }
}

- (void)marquee:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
{
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section != [self.streamDataSource sectionIndexForContent] )
    {
        return;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ( [VNoContentCollectionViewCellFactory isNoContentCell:cell] )
    {
        return;
    }
    
    self.lastSelectedIndexPath = indexPath;
    VSequence *sequence = (VSequence *)[self.streamDataSource itemAtIndexPath:indexPath];
    [self showContentViewForSequence:sequence inStreamWithID:self.currentStream.streamId withPreviewImage:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return [self.marqueeCellController desiredSizeWithCollectionViewBounds:collectionView.bounds];
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
    if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
    {
        [(id <VStreamCellFocus>)cell setHasFocus:NO];
    }
}

#pragma mark - Activity indivator footer

- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section
{
    return [super shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:section];
}

#pragma mark - VStreamCollectionDataDelegate

- (void)dataSource:(VStreamCollectionViewDataSource *)dataSource
 hasNewStreamItems:(NSArray *)streamItems
{
    if ([self.streamCellFactory respondsToSelector:@selector(registerCellsWithCollectionView:withStreamItems:)])
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView withStreamItems:streamItems];
    }
}

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return [self.marqueeCellController marqueeCellForCollectionView:self.collectionView
                                                            atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)[self.currentStream.streamItems objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = [self.streamCellFactory collectionView:self.collectionView
                                                      cellForStreamItem:sequence atIndexPath:indexPath];
    [self preloadSequencesAfterIndexPath:indexPath forDataSource:dataSource];
    
    return cell;
}

- (void)preloadSequencesAfterIndexPath:(NSIndexPath *)indexPath forDataSource:(VStreamCollectionViewDataSource *)dataSource
{
    if ([dataSource count] > (NSUInteger)indexPath.row + 2u)
    {
        NSIndexPath *preloadPath = [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section];
        VStreamItem *streamItem = [dataSource itemAtIndexPath:preloadPath];
        if ( [streamItem isKindOfClass:[VSequence class]] )
        {
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[(VSequence *)streamItem initialImageURLs]];
        }
    }
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(UIView *)commentView
{
    [self.sequenceActionController showCommentsFromViewController:self sequence:sequenceObject];
}

- (void)selectedUser:(VUser *)user onSequence:(VSequence *)sequence fromView:(UIView *)userSelectionView
{
    [self.sequenceActionController showProfile:user fromViewController:self];
}

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view videoEdit:(VDefaultVideoEdit)defaultEdit
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
    
    [self.sequenceActionController showRemixOnViewController:self
                                                withSequence:sequence
                                        andDependencyManager:self.dependencyManager
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

- (BOOL)canRepostSequence:(VSequence *)sequence
{
    if ( sequence.permissions.canRepost && ([VObjectManager sharedManager].mainUser != nil) )
    {
        return YES;
    }
    return NO;
}

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion
{
    [self.sequenceActionController repostActionFromViewController:self node:[sequence firstNode] completion:completion];
}

- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController flagSheetFromViewController:self sequence:sequence];
}

- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view
{
    // Error checking
    if ( hashtag == nil || !hashtag.length )
    {
        return;
    }
    [self showHashtagStreamWithHashtag:hashtag];
}

- (void)showRepostersForSequence:(VSequence *)sequence
{
    [self.sequenceActionController showRepostersFromViewController:self sequence:sequence];
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{    
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
    
    [newBackgroundView applyTintAndBlurToImageWithURL:url
                                        withTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.collectionView.backgroundView = newBackgroundView;
}

- (void)showContentViewForSequence:(VSequence *)sequence inStreamWithID:(NSString *)streamId withPreviewImage:(UIImage *)previewImage
{
    NSParameterAssert(sequence != nil);
    NSParameterAssert(self.currentStream != nil);
    [self.streamTrackingHelper onStreamCellSelectedWithStream:self.currentStream sequence:sequence];
    
    [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:sequence streamID:streamId commentId:nil placeHolderImage:previewImage];
}

#pragma mark - Upload Progress View

- (void)addUploadProgressView
{
    if ( self.uploadProgressViewController == nil )
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
    }
    
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

- (void)dataSourceDidChange
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
    
    if ( self.streamDataSource.stream.streamItems.count == 0 && !self.streamDataSource.hasHeaderCell )
    {
        if ( ![self.collectionView.backgroundView isEqual:self.noContentView] )
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
            UIImage *newImage = [UIImage resizeableImageWithColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]];
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
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop)
     {
         if ( [VNoContentCollectionViewCellFactory isNoContentCell:cell] )
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
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop)
     {
         if ( [VNoContentCollectionViewCellFactory isNoContentCell:cell] )
         {
             return;
         }
         
         id <VStreamCellFocus>focusCell;
         if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
         {
             focusCell = (id <VStreamCellFocus>)cell;
         }
         
         // Calculate visible ratio for just the media content of the cell
         const CGRect contentFrameInCell = [focusCell contentArea];
         
         if ( CGRectGetHeight( contentFrameInCell ) > 0.0 )
         {
             const CGRect contentIntersection = CGRectIntersection( streamVisibleRect, cell.frame );
             const float mediaContentVisibleRatio = CGRectGetHeight( contentIntersection ) / CGRectGetHeight( contentFrameInCell );
             if ( mediaContentVisibleRatio >= 0.8f )
             {
                 if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
                 {
                     [(id <VStreamCellFocus>)cell setHasFocus:YES];
                 }
                 didPlayVideo = YES;
             }
             else
             {
                 if ( [cell conformsToProtocol:@protocol(VStreamCellFocus)] )
                 {
                     [(id <VStreamCellFocus>)cell setHasFocus:NO];
                 }
             }
         }
     }];
}

- (void)collectionViewCell:(UICollectionViewCell *)cell didUpdateCellVisibility:(CGFloat)visibiltyRatio
{
    if ( visibiltyRatio >= self.trackingMinRequiredCellVisibilityRatio )
    {
        if ([cell conformsToProtocol:@protocol(VStreamCellTracking)])
        {
            VSequence *sequenceToTrack = [(id<VStreamCellTracking>)cell sequenceToTrack];
            [self.streamTrackingHelper onStreamCellDidBecomeVisibleWithStream:self.currentStream
                                                                     sequence:sequenceToTrack];
        }
    }
}

#pragma mark - VHashtagSelectionResponder

- (void)hashtagSelected:(NSString *)text
{
    [self showHashtagStreamWithHashtag:text];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemCreatePost] )
    {
        [self createNewPost];
        return NO;
    }
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemCreatePost] )
    {
        BOOL userPostAllowed = [self isUserPostAllowedInStream:self.currentStream
                                         withDependencyManager:self.dependencyManager];
        return userPostAllowed;
    }
    return YES;
}

- (BOOL)menuItem:(VNavigationMenuItem *)menuItem requiresAuthorizationWithContext:(VAuthorizationContext *)context
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemCreatePost] )
    {
        *context = VAuthorizationContextCreatePost;
        return YES;
    }
    return NO;
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

- (BOOL)selectorIsVisible
{
    return !self.navigationController.navigationBarHidden;
}

@end

#pragma mark -

@implementation VDependencyManager (VStreamCollectionViewController)

- (VStreamCollectionViewController *)remixStreamForSequence:(VSequence *)sequence
{
    NSString *sequenceID = sequence.remoteId;
    VStreamCollectionViewController *remixStream = [self templateValueOfType:[VStreamCollectionViewController class]
                                                                      forKey:kRemixStreamKey
                                                       withAddedDependencies:@{ kSequenceIDKey: sequenceID }];
    
    remixStream.navigationItem.title = NSLocalizedString(@"Remixes", nil);
    remixStream.currentStream.name = NSLocalizedString(@"Remixes", nil);
    
    VNoContentView *noRemixView = [VNoContentView noContentViewWithFrame:remixStream.view.bounds];
    if ( [noRemixView respondsToSelector:@selector(setDependencyManager:)] )
    {
        noRemixView.dependencyManager = self;
    }
    noRemixView.title = NSLocalizedString(@"NoRemixersTitle", @"");
    noRemixView.message = NSLocalizedString(@"NoRemixersMessage", @"");
    noRemixView.icon = [UIImage imageNamed:@"noRemixIcon"];
    remixStream.noContentView = noRemixView;
    
    return remixStream;
}

@end
