//
//  VStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//


#import "NSArray+VMap.h"
#import "NSString+VParseHelp.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "UIViewController+VAccessoryScreens.h"
#import "UIViewController+VLayoutInsets.h"
#import "VAbstractMarqueeCollectionViewCell.h"
#import "VAbstractMarqueeController.h"
#import "VAlertController.h"
#import "VAuthorizedAction.h"
#import "VCoachmarkDisplayer.h"
#import "VCoachmarkManager.h"
#import "VCollectionViewStreamFocusHelper.h"
#import "VConstants.h"
#import "VContentViewFactory.h"
#import "VCreatePollViewController.h"
#import "VCreationFlowPresenter.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VCoachmarkManager.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VDependencyManager+VTracking.h"
#import "VDependencyManager+VUserProfile.h"
#import "VDirectoryCollectionViewController.h"
#import "VFocusable.h"
#import "VFullscreenMarqueeSelectionDelegate.h"
#import "VHashtag.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VMultipleContainerViewController.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VNoContentView.h"
#import "VNode+Fetcher.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionController.h"
#import "VSleekStreamCellFactory.h"
#import "VStream+Fetcher.h"
#import "VStreamCellFactory.h"
#import "VStreamCellTracking.h"
#import "VStreamCollectionViewController.h"
#import "VStreamCollectionViewDataSource.h"
#import "VStreamCollectionViewParallaxFlowLayout.h"
#import "VStreamContentCellFactoryDelegate.h"
#import "VTabScaffoldViewController.h"
#import "VTracking.h"
#import "VURLMacroReplacement.h"
#import "VUploadManager.h"
#import "VUploadProgressViewController.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "victorious-Swift.h"

@import KVOController;
@import SDWebImage;

const CGFloat VStreamCollectionViewControllerCreateButtonHeight = 44.0f;

static NSString * const kCanAddContentKey = @"canAddContent";
static NSString * const kHasHeaderParallaxKey = @"hasHeaderParallax";
static NSString * const kStreamCollectionStoryboardId = @"StreamCollection";
static NSString * const kStreamATFThresholdKey = @"streamAtfViewThreshold";

NSString * const VStreamCollectionViewControllerStreamURLKey = @"streamURL";
NSString * const VStreamCollectionViewControllerCellComponentKey = @"streamCell";
NSString * const VStreamCollectionViewControllerMarqueeComponentKey = @"marqueeCell";

static NSString * const kMemeStreamKey = @"memeStream";
static NSString * const kGifStreamKey = @"gifStream";
static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";
static NSString * const kMarqueeDestinationDirectory = @"destinationDirectory";
static NSString * const kStreamCollectionKey = @"destinationStream";

@interface VStreamCollectionViewController () <VSequenceActionsDelegate, VUploadProgressViewControllerDelegate, UICollectionViewDelegateFlowLayout, VHashtagSelectionResponder, VCoachmarkDisplayer, VStreamContentCellFactoryDelegate, AutoplayTracking>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) id<VStreamCellFactory> streamCellFactory;
@property (nonatomic, strong) VAbstractMarqueeController *marqueeCellController;

@property (strong, nonatomic) VUploadProgressViewController *uploadProgressViewController;
@property (strong, nonatomic) NSLayoutConstraint *uploadProgressViewYconstraint;

@property (readwrite, nonatomic) VSequenceActionController *sequenceActionController;

@property (nonatomic, assign) BOOL hasRefreshed;

@property (nonatomic, strong) VCreationFlowPresenter *creationFlowPresenter;

@property (nonatomic, strong) VCollectionViewStreamFocusHelper *focusHelper;
@property (nonatomic, strong) ContentViewPresenter *contentViewPresenter;

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
    self.contentViewPresenter = [[ContentViewPresenter alloc] init];
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
    
    if ( [self.streamCellFactory isKindOfClass:[VStreamContentCellFactory class]] )
    {
        VStreamContentCellFactory *factory = (VStreamContentCellFactory *)self.streamCellFactory;
        factory.delegate = self;
    }

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
    
    self.focusHelper = [[VCollectionViewStreamFocusHelper alloc] initWithCollectionView:self.collectionView];
    
    // Setup custom flow layout for parallax
    BOOL hasParallax = [[self.dependencyManager numberForKey:kHasHeaderParallaxKey] boolValue];
    if (hasParallax)
    {
        VStreamCollectionViewParallaxFlowLayout *flowLayout = [[VStreamCollectionViewParallaxFlowLayout alloc] init];
        self.collectionView.collectionViewLayout = flowLayout;
    }
    
    [self.KVOController observe:self.streamDataSource
                        keyPath:NSStringFromSelector(@selector(visibleStreamItems))
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
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self updateNavigationItems];
    
    [self.dependencyManager trackViewWillAppear:self withParameters:nil templateClass:self.viewTrackingClassOverride];

    if ( self.streamDataSource.count != 0 )
    {
        /*
         We already have marquee content so we need to restart the timer to make sure the marquee continues
         to rotate in case it's timer has been invalidated by the presentation of another viewController
         */
        [self.marqueeCellController enableTimer];
    }
    
    if ( [self.streamCellFactory isKindOfClass:[VSleekStreamCellFactory class]] )
    {
        [(VSleekStreamCellFactory *)self.streamCellFactory updateVisibleCellsInCollectionView:self.collectionView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addBadgingToNavigationItems];
    
    [self.collectionView flashScrollIndicators];
    [self updateCellVisibilityTracking];
    
    // Start any video cells that are on screen
    [self.focusHelper updateFocus];
    [self.marqueeCellController updateFocus];
    
    //Because a stream can be presented without refreshing, we need to refresh the user post icon here
    [self updateNavigationItems];

    [[self.dependencyManager coachmarkManager] displayCoachmarkViewInViewController:self];
    
    [self updateNavigationBarScrollOffset];
    
    // Clear reference to the selected cell after returning to this view from content view.
    // Must be done on `viewDidAppear:` to play well with autoplay focus.
    self.focusHelper.selectedCell = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[self.dependencyManager coachmarkManager] hideCoachmarkViewInViewController:self animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop any video cells
    [self.focusHelper endFocusOnAllCells];
    [self.marqueeCellController endFocusOnAllCells];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    NSString *streamName = currentStream.name;
    self.navigationItem.title = streamName;
    if ( self.streamDataSource == nil )
    {
        self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:currentStream];
        self.streamDataSource.delegate = self;
    }
    else
    {
        self.streamDataSource.stream = currentStream;
    }
    [super setCurrentStream:currentStream];
}

- (void)marqueeController:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
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
    BOOL hasMarqueeShelfAtTop = NO;
    NSArray *streamItems = self.streamDataSource.visibleStreamItems;
    if ( streamItems.count > 0 )
    {
        VStreamItem *streamItem = [streamItems firstObject];
        hasMarqueeShelfAtTop = [streamItem.itemType isEqualToString:VStreamItemTypeShelf] && [streamItem.itemSubType isEqualToString:VStreamItemSubTypeMarquee];
    }
    
    if (self.streamDataSource.hasHeaderCell || hasMarqueeShelfAtTop)
    {
        CGSize marqueeSize = [self.marqueeCellController desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
        CGFloat offset = marqueeSize.height;
        if ( hasMarqueeShelfAtTop )
        {
            offset += [self.streamCellFactory minimumLineSpacing];
        }
        self.navigationControllerScrollDelegate.catchOffset = offset;
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
    
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)addBadgingToNavigationItems
{
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
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
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.creationFlowPresenter = [[VCreationFlowPresenter alloc] initWithDependencymanager:strongSelf.dependencyManager];
         strongSelf.creationFlowPresenter.showsCreationSheetFromTop = YES;
         [strongSelf.creationFlowPresenter presentOnViewController:strongSelf];
     }];
}

#pragma mark - VMarqueeDataDelegate

- (void)marqueeController:(VAbstractMarqueeController *)marquee didSelectItem:(VStreamItem *)streamItem withPreviewImage:(UIImage *)image fromCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)path
{
    UICollectionViewCell *cell = [marquee.collectionView cellForItemAtIndexPath:path];
    
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:streamItem
                                                                          stream:marquee.stream
                                                                       fromShelf:YES];
        event.indexPath = path;
        event.collectionView = collectionView;
        
        NSDictionary *extraTrackingInfo;
        if ([cell conformsToProtocol:@protocol(AutoplayTracking)])
        {
            extraTrackingInfo = [(id<AutoplayTracking>)cell additionalInfo];
        }
        
        [self showContentViewForCellEvent:event trackingInfo:extraTrackingInfo withPreviewImage:image];
    }
    else if ( [streamItem isKindOfClass:[VStream class]] )
    {
        VStream *stream = (VStream *)streamItem;
        [self navigateToStream:stream atStreamItem:nil];
    }
}

- (void)navigateToStream:(VStream *)stream atStreamItem:(VStreamItem *)streamItem
{
    BOOL isShelf = [stream isShelf];
    if ( [stream isSingleStream] || isShelf )
    {
        VStreamCollectionViewController *streamCollection = nil;
        NSMutableDictionary *baseConfiguration = [[NSMutableDictionary alloc] initWithDictionary:@{ kSequenceIDKey: stream.remoteId, VDependencyManagerTitleKey: stream.name, VDependencyManagerAccessoryScreensKey : @[] }];
        
        if ( isShelf )
        {
            [baseConfiguration addEntriesFromDictionary:@{ VStreamCollectionViewControllerStreamURLKey : stream.apiPath }];
            VDependencyManager *dependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:baseConfiguration];
            if ( [stream isKindOfClass:[HashtagShelf class]] )
            {
                HashtagShelf *hashtagShelf = (HashtagShelf *)stream;
                streamCollection = [dependencyManager hashtagStreamWithHashtag:hashtagShelf.hashtagTitle];
            }
            else
            {
                streamCollection = [VStreamCollectionViewController newWithDependencyManager:dependencyManager];
            }
        }
        else
        {
            VDependencyManager *dependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:baseConfiguration];
            streamCollection = [VStreamCollectionViewController newWithDependencyManager:dependencyManager];
        }
        
        streamCollection.currentStream = stream;
        streamCollection.targetStreamItem = streamItem;
        [self.navigationController pushViewController:streamCollection animated:YES];
    }
    else if ( [stream isStreamOfStreams] )
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
        directory.currentStream = stream;
        
        //Update the directory title to match the streamItem
        directory.title = stream.name;
        
        directory.targetStreamItem = streamItem;
        
        [self.navigationController pushViewController:directory animated:YES];
    }
}

- (void)marqueeController:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
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
    VStreamItem *streamItem = (VStreamItem *)[self.streamDataSource itemAtIndexPath:indexPath];
    
    StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:streamItem
                                                                      stream:self.currentStream
                                                                   fromShelf:NO];
    event.collectionView = collectionView;
    event.indexPath = indexPath;
    
    NSDictionary *extraTrackingInfo;
    if ([cell conformsToProtocol:@protocol(AutoplayTracking)])
    {
        extraTrackingInfo = [(id<AutoplayTracking>)cell additionalInfo];
    }
    
    self.focusHelper.selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [self showContentViewForCellEvent:event trackingInfo:extraTrackingInfo withPreviewImage:nil];
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
    [self.focusHelper endFocusOnCell:cell];
}

#pragma mark - Activity indivator footer

- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section
{
    return [super shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:section];
}

#pragma mark - VStreamCollectionDataDelegate

- (void)dataSource:(VStreamCollectionViewDataSource *)dataSource hasNewStreamItems:(NSArray *)streamItems
{
    if ([self.streamCellFactory respondsToSelector:@selector(registerCellsWithCollectionView:withStreamItems:)])
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView withStreamItems:streamItems];
    }
    [self updateCellVisibilityTracking];
}

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return [self.marqueeCellController marqueeCellForCollectionView:self.collectionView
                                                            atIndexPath:indexPath];
    }
    
    VSequence *sequence = (VSequence *)[self.streamDataSource.visibleStreamItems objectAtIndex:indexPath.row];
    UICollectionViewCell *cell;
    if ([self.streamCellFactory respondsToSelector:@selector(collectionView:cellForStreamItem:atIndexPath:inStream:)])
    {
        cell = [self.streamCellFactory collectionView:self.collectionView
                                    cellForStreamItem:sequence
                                          atIndexPath:indexPath
                                             inStream:self.currentStream];
    }
    else
    {
        cell = [self.streamCellFactory collectionView:self.collectionView
                                    cellForStreamItem:sequence
                                          atIndexPath:indexPath];
    }
    
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
    [self.sequenceActionController showCommentsFromViewController:self sequence:sequenceObject withSelectedComment:nil];
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

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLike];
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    
    __weak typeof(self) welf = self;
    [authorization performFromViewController:self context:VAuthorizationContextDefault
                                          completion:^(BOOL authorized)
     {
         __strong typeof(self) strongSelf = welf;
         if ( authorized )
         {
             CGRect likeButtonFrame = [view convertRect:view.bounds toView:strongSelf.view];
             [[strongSelf.dependencyManager coachmarkManager] triggerSpecificCoachmarkWithIdentifier:VLikeButtonCoachmarkIdentifier inViewController:strongSelf atLocation:likeButtonFrame];
             
             [[VObjectManager sharedManager] toggleLikeWithSequence:sequence
                                                       successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
              {
                  completion( YES );
                  
              } failBlock:^(NSOperation *operation, NSError *error)
              {
                  completion( NO );
              }];
         }
         else
         {
             completion( NO );
         }
     }];
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

- (void)willShowLikersForSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController showLikersFromViewController:self sequence:sequence];
}

#pragma mark - Actions

- (void)setBackgroundImageWithURL:(NSURL *)url
{    
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
    
    [newBackgroundView applyTintAndBlurToImageWithURL:url
                                        withTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    
    self.collectionView.backgroundView = newBackgroundView;
}

- (void)showContentViewForCellEvent:(StreamCellContext *)event trackingInfo:(NSDictionary *)trackingInfo withPreviewImage:(UIImage *)previewImage
{
    NSParameterAssert(event.streamItem != nil);
    NSParameterAssert(self.currentStream != nil);
    
    [self.streamTrackingHelper onStreamCellSelectedWithCellEvent:event additionalInfo:trackingInfo];
    
    if ( [event.streamItem isKindOfClass:[VSequence class]] )
    {
        ContentViewContext *context = [[ContentViewContext alloc] init];
        
        NSString *streamID = [event.stream hasShelfID] && event.fromShelf ? event.stream.shelfId : event.stream.streamId;
        
        UICollectionView *collectionView = event.collectionView;
        NSIndexPath *indexPath = event.indexPath;
        if ( collectionView != nil && indexPath != nil )
        {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if ( [cell conformsToProtocol:@protocol(VContentPreviewViewProvider)] )
            {
                context.contentPreviewProvider = (id<VContentPreviewViewProvider>)cell;
            }
        }
        
        context.sequence = (VSequence *)event.streamItem;
        context.placeholderImage = previewImage;
        context.streamId = streamID;
        context.viewController = self;
        context.originDependencyManager = self.dependencyManager;
        [self.contentViewPresenter presentContentViewWithContext:context];
    }
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
        [self.navigationController setNavigationBarHidden:NO];
        
        UIViewController *topVC = self.navigationController.topViewController;
        if ([topVC isKindOfClass:[VMultipleContainerViewController class]])
        {
            [self.v_navigationController updateSupplementaryHeaderViewForViewController:topVC];
        }
    }
    self.uploadProgressViewController.view.hidden = hidden;
    self.navigationBarShouldAutoHide = hidden;
}

#pragma mark - Notifications

- (void)dataSourceDidChange
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.hasRefreshed = YES;
        [self updateNoContentViewAnimated:YES];
        
        [self updateCellVisibilityTracking];
        [self.marqueeCellController updateFocus];
        [self.focusHelper updateFocus];
    });
}

- (void)updateNoContentViewAnimated:(BOOL)animated
{
    if (!self.noContentView)
    {
        return;
    }
    
    void (^noContentUpdates)(void);
    
    if ( self.streamDataSource.visibleStreamItems.count == 0 && !self.streamDataSource.hasHeaderCell )
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
    
    if (self.uploadProgressViewController.view.hidden != uploadsShouldBeHidden)
    {
        [self setUploadsHidden:uploadsShouldBeHidden];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    [self updateCellVisibilityTracking];
    
    [self.focusHelper updateFocus];
}

#pragma mark - Cell visibility

- (void)updateCellVisibilityTracking
{
    const CGRect streamVisibleRect = self.collectionView.bounds;
    
    NSArray *visibleCells = self.collectionView.visibleCells;
    
    for (UICollectionViewCell *cell in visibleCells)
    {
        if ( ![VNoContentCollectionViewCellFactory isNoContentCell:cell] )
        {
            // Calculate visible ratio for the whole cell
            const CGRect intersection = CGRectIntersection( streamVisibleRect, cell.frame );
            const CGFloat visibleRatio = CGRectGetHeight( intersection ) / CGRectGetHeight( cell.frame );
            [self collectionViewCell:cell didUpdateCellVisibility:visibleRatio];
        }
    }
    
    // Fire right away to catch any events while scrolling stream
    [self.marqueeCellController updateCellVisibilityTracking];
}

- (void)collectionViewCell:(UICollectionViewCell *)cell didUpdateCellVisibility:(CGFloat)visibiltyRatio
{
    if ( visibiltyRatio >= self.trackingMinRequiredCellVisibilityRatio )
    {
        if ([cell conformsToProtocol:@protocol(VStreamCellTracking)])
        {
            VSequence *sequenceToTrack = [(id<VStreamCellTracking>)cell sequenceToTrack];
            StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:sequenceToTrack
                                                                              stream:self.currentStream
                                                                           fromShelf:NO];
            [self.streamTrackingHelper onStreamCellDidBecomeVisibleWithCellEvent:event];
        }
        else if ( [cell conformsToProtocol:@protocol(TrackableShelf)] )
        {
            [(id <TrackableShelf>)cell trackVisibleSequences];
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
    
    // Don't show hamburger menu if we are presented
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemMenu] && (self.presentingViewController != nil))
    {
        return NO;
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

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    [self.v_navigationController setNavigationBarHidden:NO];
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Autoplay Tracking

- (void)trackAutoplayEvent:(AutoplayTrackingEvent *__nonnull)event
{
    [self.streamTrackingHelper trackAutoplayEvent:event];
}

- (NSDictionary *__nonnull)additionalInfo
{
    return @{};
}

@end

#pragma mark -

@implementation VDependencyManager (VStreamCollectionViewController)

- (VStreamCollectionViewController *)memeStreamForSequence:(VSequence *)sequence
{
    NSString *sequenceID = sequence.remoteId;
    VStreamCollectionViewController *memeStream = [self templateValueOfType:[VStreamCollectionViewController class]
                                                                     forKey:kMemeStreamKey
                                                      withAddedDependencies:@{ kSequenceIDKey: sequenceID }];
    
    memeStream.navigationItem.title = memeStream.currentStream.name;
    
    VNoContentView *noMemeView = [VNoContentView noContentViewWithFrame:memeStream.view.bounds];
    if ( [noMemeView respondsToSelector:@selector(setDependencyManager:)] )
    {
        noMemeView.dependencyManager = self;
    }
    noMemeView.title = NSLocalizedString(@"NoMemersTitle", @"");
    noMemeView.message = NSLocalizedString(@"NoMemersMessage", @"");
    noMemeView.icon = [UIImage imageNamed:@"noMemeIcon"];
    memeStream.noContentView = noMemeView;
    
    return memeStream;
}

- (VStreamCollectionViewController *)gifStreamForSequence:(VSequence *)sequence
{
    NSString *sequenceID = sequence.remoteId;
    VStreamCollectionViewController *gifStream = [self templateValueOfType:[VStreamCollectionViewController class]
                                                                    forKey:kGifStreamKey
                                                     withAddedDependencies:@{ kSequenceIDKey: sequenceID }];
    
    gifStream.navigationItem.title = gifStream.currentStream.name;
    
    VNoContentView *noGifView = [VNoContentView noContentViewWithFrame:gifStream.view.bounds];
    if ( [noGifView respondsToSelector:@selector(setDependencyManager:)] )
    {
        noGifView.dependencyManager = self;
    }
    noGifView.title = NSLocalizedString(@"NoGiffersTitle", @"");
    noGifView.message = NSLocalizedString(@"NoGiffersMessage", @"");
    noGifView.icon = [UIImage imageNamed:@"noGifIcon"];
    gifStream.noContentView = noGifView;
    
    return gifStream;
}

@end
