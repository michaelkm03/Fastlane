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
#import "VCollectionViewStreamFocusHelper.h"
#import "VConstants.h"
#import "VContentViewFactory.h"
#import "VCreatePollViewController.h"
#import "VCreationFlowPresenter.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+NavigationBar.h"
#import "VDependencyManager+VTracking.h"
#import "VDirectoryCollectionViewController.h"
#import "VFocusable.h"
#import "VFullscreenMarqueeSelectionDelegate.h"
#import "VHashtagSelectionResponder.h"
#import "VHashtagStreamCollectionViewController.h"
#import "VMultipleContainerViewController.h"
#import "VNavigationController.h"
#import "VNewContentViewController.h"
#import "VNoContentCollectionViewCellFactory.h"
#import "VNoContentView.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VSequenceActionControllerDelegate.h"
#import "VSleekStreamCellFactory.h"
#import "VStreamItem+Fetcher.h"
#import "VStreamCellFactory.h"
#import "VStreamCellTracking.h"
#import "VStreamCollectionViewController.h"
#import "VStreamCollectionViewDataSource.h"
#import "VStreamCollectionViewParallaxFlowLayout.h"
#import "VStreamContentCellFactoryDelegate.h"
#import "VUploadManager.h"
#import "VUploadProgressViewController.h"
#import "VUserProfileViewController.h"
#import "VSleekStreamCollectionCell.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "victorious-Swift.h"

@import VictoriousIOSSDK;
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

static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";
static NSString * const kMarqueeDestinationDirectory = @"destinationDirectory";
static NSString * const kStreamCollectionKey = @"destinationStream";

@interface VStreamCollectionViewController () <VSequenceActionsDelegate, VUploadProgressViewControllerDelegate, UICollectionViewDelegateFlowLayout, VHashtagSelectionResponder, VStreamContentCellFactoryDelegate, VideoTracking, VContentPreviewViewProvider, VAccessoryNavigationSource, VSequenceActionControllerDelegate, VUploadManagerHost>

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, strong) id<VStreamCellFactory> streamCellFactory;
@property (nonatomic, strong) VAbstractMarqueeController *marqueeCellController;

@property (strong, nonatomic) NSLayoutConstraint *uploadProgressViewYconstraint;

@property (readwrite, nonatomic) VSequenceActionController *sequenceActionController;

@property (nonatomic, assign) BOOL hasRefreshed;

@property (nonatomic, strong) VCreationFlowPresenter *creationFlowPresenter;

@property (nonatomic, strong) ContentViewPresenter *contentViewPresenter;
@property (nonatomic, strong) UICollectionViewCell <VContentPreviewViewProvider> *cellPresentingContentView;

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
        VSDKURLMacroReplacement *urlMacroReplacement = [[VSDKURLMacroReplacement alloc] init];
        url = [urlMacroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kSequenceIDMacro: sequenceID }
                                                                   inURLString:url];
    }
    NSString *apiPath = [url v_pathComponent];
    NSDictionary *query = @{ @"apiPath" : apiPath };
    
    __block VStream *stream = nil;
    id<PersistentStoreType>  persistentStore = [PersistentStoreSelector defaultPersistentStore];
    [persistentStore.mainContext performBlockAndWait:^void {
        stream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream v_entityName] queryDictionary:query];
        stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
        [persistentStore.mainContext save:nil];
    }];
    
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
    self.sequenceActionController = [[VSequenceActionController alloc] initWithDependencyManager:self.dependencyManager.contentViewDependencyManager originViewController:self delegate:self];
    
    self.streamCellFactory = [self.dependencyManager templateValueConformingToProtocol:@protocol(VStreamCellFactory) forKey:VStreamCollectionViewControllerCellComponentKey];
    
    if ( [self.streamCellFactory isKindOfClass:[VStreamContentCellFactory class]] )
    {
        VStreamContentCellFactory *factory = (VStreamContentCellFactory *)self.streamCellFactory;
        factory.delegate = self;
    }

    if ([self.streamCellFactory respondsToSelector:@selector(registerCellsWithCollectionView:withStreamItems:)])
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView
                                                withStreamItems:self.streamDataSource.stream.streamItems];
    }
    else
    {
        [self.streamCellFactory registerCellsWithCollectionView:self.collectionView];
    }
    
    self.collectionView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.suppressShelves = self.suppressShelves;
    self.collectionView.dataSource = self.streamDataSource;
    
    self.marqueeCellController = [self.dependencyManager templateValueOfType:[VAbstractMarqueeController class] forKey:VStreamCollectionViewControllerMarqueeComponentKey];
    self.marqueeCellController.dataDelegate = self;
    self.marqueeCellController.selectionDelegate = self;
    [self.marqueeCellController registerCollectionViewCellWithCollectionView:self.collectionView];
    
    self.focusHelper = [[VCollectionViewStreamFocusHelper alloc] initWithCollectionView:self.collectionView];
    
    // Setup custom flow layout for parallax
    BOOL hasParallax = [[self.dependencyManager numberForKey:kHasHeaderParallaxKey] boolValue];
    if (hasParallax)
    {
        VStreamCollectionViewParallaxFlowLayout *flowLayout = [[VStreamCollectionViewParallaxFlowLayout alloc] init];
        self.collectionView.collectionViewLayout = flowLayout;
    }
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self updateNavigationItems];
    
    if ( self.streamDataSource.count != 0 )
    {
        // We already have marquee content so we need to restart the timer to make sure the marquee continues
        // to rotate in case it's timer has been invalidated by the presentation of another viewController
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

    
    [self updateNavigationBarScrollOffset];
    
    // Clear reference to the selected cell after returning to this view from content view.
    // Must be done on `viewDidAppear:` to play well with autoplay focus.
    self.focusHelper.selectedCell = nil;
    
    [self addUploadProgressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop any video cells, including marquee cell, which handles stopping its own video cells
    [self.focusHelper endFocusOnAllCells];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - VUploadManagerHost

- (void)addUploadManagerToViewController:(UIViewController *)viewController topInset:(CGFloat)topInset
{
    [VUploadManagerHelper addUploadManagerToViewController:viewController topInset:topInset];
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
    self.streamDataSource.stream = currentStream;
    [super setCurrentStream:currentStream];
}

- (void)marqueeController:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
{
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
    
    if ([self hasMarqueeShelfAtTop])
    {
        // Set the size of the marquee on our navigation scroll delegate so it wont hide until we scroll past the marquee
        CGSize marqueeSize = [self.marqueeCellController desiredSizeWithCollectionViewBounds:self.collectionView.bounds];
        CGFloat offset = marqueeSize.height;
        offset += [self.streamCellFactory minimumLineSpacing];
        self.navigationControllerScrollDelegate.catchOffset = offset;
    }
    else
    {
        self.navigationControllerScrollDelegate.catchOffset = 0;
    }
}

- (BOOL)hasMarqueeShelfAtTop
{
    NSOrderedSet *streamItems = self.streamDataSource.visibleItems;
    if ( streamItems.count > 0 )
    {
        VStreamItem *streamItem = [streamItems firstObject];
        return [streamItem.itemType isEqualToString:VStreamItemTypeShelf] && [streamItem.itemSubType isEqualToString:VStreamItemSubTypeMarquee];
    }
    return false;
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
    if (isDefault)
    {
        [self viewWillAppear:YES];
    }
}

- (void)createNewPost
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreatePost];
    self.creationFlowPresenter = [[VCreationFlowPresenter alloc] initWithDependencyManager:self.dependencyManager];
    self.creationFlowPresenter.showsCreationSheetFromTop = YES;
    [self.creationFlowPresenter presentOnViewController:self];
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
                                                                          stream:marquee.shelf
                                                                       fromShelf:YES];
        event.indexPath = path;
        event.collectionView = collectionView;
        
        NSDictionary *extraTrackingInfo;
        if ([cell conformsToProtocol:@protocol(VideoTracking)])
        {
            extraTrackingInfo = [(id<VideoTracking>)cell additionalInfo];
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
        NSMutableDictionary *baseConfiguration = [[NSMutableDictionary alloc] initWithDictionary:@{ kSequenceIDKey: stream.remoteId ?: @"",
                                                                                                    VDependencyManagerTitleKey: stream.name,
                                                                                                    VDependencyManagerAccessoryScreensKey : @[],
                                                                                                    @"titleImage": [NSNull null]}];
        
        if ( isShelf )
        {
            if ( [stream isKindOfClass:[HashtagShelf class]] )
            {
                HashtagShelf *hashtagShelf = (HashtagShelf *)stream;
                streamCollection = [self.dependencyManager hashtagStreamWithHashtag:hashtagShelf.hashtagTitle];
            }
            else
            {
                streamCollection = [VStreamCollectionViewController newWithDependencyManager:self.dependencyManager];
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:NSLocalizedString(@"GenericFailMessage", nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            
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
    UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerFor:user];
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
    if ([cell conformsToProtocol:@protocol(VideoTracking)])
    {
        extraTrackingInfo = [(id<VideoTracking>)cell additionalInfo];
    }
    
    self.focusHelper.selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [self showContentViewForCellEvent:event trackingInfo:extraTrackingInfo withPreviewImage:nil];
}

- (void)prepareForScreenshot
{
    for ( UICollectionViewCell *cell in self.collectionView.visibleCells )
    {
        if ( [cell isKindOfClass:[VSleekStreamCollectionCell class]] )
        {
            [(VSleekStreamCollectionCell *)cell makeVideoContentHidden:YES];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = [self.streamDataSource itemAtIndexPath:indexPath];
    return [self.streamCellFactory sizeWithCollectionViewBounds:collectionView.bounds ofCellForStreamItem:streamItem];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.streamCellFactory minimumLineSpacing];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.focusHelper endFocusOnCell:cell];
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
    VSequence *sequence = (VSequence *)[self.streamDataSource.visibleItems objectAtIndex:indexPath.row];
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

    VBaseCollectionViewCell *baseCollectionViewCell = ((VBaseCollectionViewCell *)cell);
    if (baseCollectionViewCell != nil && [baseCollectionViewCell respondsToSelector:@selector(setSourceScreenName:)])
    {
        baseCollectionViewCell.sourceScreenName = self.sourceScreenName;
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

#pragma mark - VSequenceActionControllerDelegate

- (void)sequenceActionControllerDidDeleteSequence:(VSequence *)sequence
{
    [self.streamDataSource.paginatedDataSource removeDeletedItems];
}

- (void)sequenceActionControllerDidFlagSequence:(VSequence *)sequence
{
    [self.streamDataSource.paginatedDataSource removeDeletedItems];
}

- (void)sequenceActionControllerDidBlockUser:(VUser *)user
{
    [self.streamDataSource.paginatedDataSource removeDeletedItems];
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(UIView *)commentView
{
    [self.sequenceActionController showCommentsWithSequence:sequenceObject];
}

- (void)selectedUser:(VUser *)user onSequence:(VSequence *)sequence fromView:(UIView *)userSelectionView
{
    [self.sequenceActionController showProfileWithRemoteId:user.remoteId.integerValue];
}

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRemix];
    
    [self.sequenceActionController showRemixWithSequence:sequence];
}

- (void)willSelectMoreForSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion
{
    [self.sequenceActionController showMoreWithSequence:sequence
                                                       streamId:self.currentStream.remoteId
                                                     completion:^
     {
         if (completion)
         {
             completion(YES);
         }
     }];
}

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion
{
    [self.sequenceActionController likeSequence:sequence
                         triggeringView:view
                             completion:^void(BOOL success)
     {
         if ( completion != nil )
         {
             completion( success );
         }
     }];
}

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController shareSequence:sequence
                                        streamID:self.streamDataSource.stream.remoteId
                                      completion:nil];
}

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self willRepostSequence:sequence fromView:view completion:nil];
}

- (BOOL)canRepostSequence:(VSequence *)sequence
{
    if ( sequence.permissions.canRepost && [VCurrentUser user] != nil )
    {
        return YES;
    }
    return NO;
}

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion
{
    [self.sequenceActionController repostSequence:sequence completion:completion];
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
    [self.sequenceActionController showRepostersWithSequence:sequence];
}

- (void)willShowLikersForSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController showLikersWithSequence:sequence];
}

#pragma mark - Actions

- (void)showContentViewForCellEvent:(StreamCellContext *)event trackingInfo:(NSDictionary *)trackingInfo withPreviewImage:(UIImage *)previewImage
{
    NSParameterAssert(event.streamItem != nil);
    NSParameterAssert(self.currentStream != nil);
    
    // If a user is able to exercise super-human speed and tap a deleted sequence before the
    // this view controller's super class can remove it by calling `removeDeletedItems` from
    // `viewWillAppear:`, return early to prevent the inevitable crash later on.
    if ( event.streamItem.hasBeenDeleted )
    {
        return;
    }
    
    [self.streamTrackingHelper onStreamCellSelectedWithCellEvent:event additionalInfo:trackingInfo];
    
    if ( [event.streamItem isKindOfClass:[VSequence class]] )
    {
        ContentViewContext *context = [[ContentViewContext alloc] init];
        
        NSString *streamID = event.stream.shelfId.length > 0 && event.fromShelf ? event.stream.shelfId : event.stream.remoteId;
        
        UICollectionView *collectionView = event.collectionView;
        NSIndexPath *indexPath = event.indexPath;
        if ( collectionView != nil && indexPath != nil )
        {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            if ( [cell conformsToProtocol:@protocol(VContentPreviewViewProvider)] )
            {
                self.cellPresentingContentView = (UICollectionViewCell <VContentPreviewViewProvider> *)cell;
                context.contentPreviewProvider = self;
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

#pragma mark - VContentPreviewViewProvider

//This conformance to the VContentPreviewViewProvider is a stop gap for 3.4
//until we can figure out a better way to take / give preview views to stream cells
- (void)setHasRelinquishedPreviewView:(BOOL)hasRelinquishedPreviewView
{
    self.cellPresentingContentView.hasRelinquishedPreviewView = hasRelinquishedPreviewView;
}

- (BOOL)hasRelinquishedPreviewView
{
    return self.cellPresentingContentView.hasRelinquishedPreviewView;
}

- (UIView *)getPreviewView
{
    return [self.cellPresentingContentView getPreviewView];
}

- (UIView *)getContainerView
{
    return [self.cellPresentingContentView getContainerView];
}

- (void)restorePreviewView:(VSequencePreviewView *)previewView
{
    VStreamItem *streamItem = previewView.streamItem;
    NSIndexPath *indexPath = [self.streamDataSource indexPathForItem:streamItem];
    if ( indexPath.row != NSNotFound && indexPath == self.lastSelectedIndexPath )
    {
        //Returning content to a stream cell
        [self restorePreviewView:previewView toCellAtIndexPath:indexPath inCollectionView:self.collectionView];
        
        //Update the cell that presented the content view if it didn't just have it's preview view returned to it
        BOOL cellPresentingContentViewNeedsUpdate = ![self.cellPresentingContentView isEqual:[self.collectionView cellForItemAtIndexPath:indexPath]];
        [self resetCellPresentingContentViewInCollectionView:self.collectionView withRefresh:cellPresentingContentViewNeedsUpdate];
    }
    else
    {
        BOOL foundMarqueeCell = NO;
        
        for ( UICollectionViewCell *cell in self.collectionView.visibleCells )
        {
            //See if we're returning content to a marquee cell
            if ( [cell isKindOfClass:[VAbstractMarqueeCollectionViewCell class]] )
            {
                UICollectionView *marqueeCollectionView = [(VAbstractMarqueeCollectionViewCell *)cell marqueeCollectionView];
                VAbstractMarqueeStreamItemCell *marqueeStreamItemCell = [self marqueeStreamItemCellRepresentingStreamItem:streamItem inMarqueeCollectionViewCell:(VAbstractMarqueeCollectionViewCell *)cell];
                if ( marqueeStreamItemCell == nil && [marqueeCollectionView indexPathForCell:self.cellPresentingContentView] != nil )
                {
                    //We've deleted an item from this marquee
                    marqueeStreamItemCell = (VAbstractMarqueeStreamItemCell *)self.cellPresentingContentView;
                }
                
                if ( marqueeStreamItemCell != nil )
                {
                    //Returning to a marquee cell
                    [marqueeStreamItemCell restorePreviewView:previewView];
                    [self resetCellPresentingContentViewInCollectionView:marqueeCollectionView withRefresh:![self.cellPresentingContentView isEqual:marqueeStreamItemCell]];
                    foundMarqueeCell = YES;
                    break;
                }
            }
        }
        
        if ( !foundMarqueeCell )
        {
            //We have flagged a piece of content in a stream cell, force the
            //presenting cell to refresh to get the right content
            [self resetCellPresentingContentViewInCollectionView:self.collectionView withRefresh:YES];
        }
    }
    
    for ( UICollectionViewCell *cell in self.collectionView.visibleCells )
    {
        if ( [cell isKindOfClass:[VSleekStreamCollectionCell class]] )
        {
            [(VSleekStreamCollectionCell *)cell makeVideoContentHidden:NO];
        }
    }
}

- (void)restorePreviewView:(VSequencePreviewView *)previewView toCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSAssert(cell != nil, @"Callers of restorePreviewView:toCellAtIndexPath:inCollectionView: should never provide a cell from outside the provided collection view");
    if ( cell == nil || ![cell conformsToProtocol:@protocol(VContentPreviewViewProvider)] )
    {
        return;
    }
    
    [(UICollectionViewCell <VContentPreviewViewProvider> *)cell restorePreviewView:previewView];
}

- (VAbstractMarqueeStreamItemCell *)marqueeStreamItemCellRepresentingStreamItem:(VStreamItem *)streamItem inMarqueeCollectionViewCell:(VAbstractMarqueeCollectionViewCell *)marqueeCell
{
    UICollectionView *marqueeCollectionView = [marqueeCell marqueeCollectionView];
    NSInteger marqueeItemRow = [[[marqueeCell marquee] marqueeItems] indexOfObject:streamItem];
    if ( marqueeItemRow != NSNotFound )
    {
        NSIndexPath *marqueeItemIndexPath = [NSIndexPath indexPathForItem:marqueeItemRow inSection:0];
        return (VAbstractMarqueeStreamItemCell *)[marqueeCollectionView cellForItemAtIndexPath:marqueeItemIndexPath];
    }
    return nil;
}

- (void)resetCellPresentingContentViewInCollectionView:(UICollectionView *)collectionView withRefresh:(BOOL)refresh
{
    self.cellPresentingContentView.hasRelinquishedPreviewView = NO;
    if ( refresh )
    {
        NSIndexPath *oldIndexPath = [collectionView indexPathForCell:self.cellPresentingContentView];
        if ( oldIndexPath != nil )
        {
            [collectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
        }
    }
    self.cellPresentingContentView = nil;
}

#pragma mark - Upload Progress View

- (void)addUploadProgressView
{
    [self addUploadManagerToViewController:self topInset:self.topInset];
    if (self.uploadProgressViewController.numberOfUploads > 0)
    {
        [self setUploadsHidden:NO];
    }
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insetsFromSuper = UIEdgeInsetsZero;
    
    if ( [super respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] )
    {
        insetsFromSuper = [super collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    
    if ([self hasMarqueeShelfAtTop] && section == 0)
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
    
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemLegalInfo] && [AgeGate isAnonymousUser] )
    {
        [self showLegalInfoOptions];
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
    
    if ([menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemLegalInfo])
    {
        return [AgeGate isAnonymousUser];
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

- (void)trackAutoplayEvent:(VideoTrackingEvent *__nonnull)event
{
    [self.streamTrackingHelper trackAutoplayEvent:event];
}

- (NSDictionary *__nonnull)additionalInfo
{
    return @{};
}

@end
