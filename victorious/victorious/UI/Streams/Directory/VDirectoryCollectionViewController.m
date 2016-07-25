//
//  VDirectoryCollectionViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionViewController.h"
#import "NSString+VParseHelp.h"
#import "VAbstractMarqueeController.h"
#import "VDirectoryCellFactory.h"
#import "VDirectoryCellUpdateableFactory.h"
#import "VStreamItem.h"
#import "VDependencyManager+NavigationBar.h"
#import "VStreamCollectionViewController.h"
#import "VDirectoryCollectionFlowLayout.h"
#import "VShowcaseDirectoryCell.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "victorious-Swift.h"

@import VictoriousIOSSDK;

static NSString * const kStreamURLKey = @"streamURL";
static NSString * const kMarqueeKey = @"marqueeCell";

static NSString * const kDestinationDirectoryKey = @"destinationDirectory";
static NSString * const kStreamCollectionKey = @"destinationStream";
static NSString * const kSequenceIDKey = @"sequenceID";
static NSString * const kSequenceNameKey = @"sequenceName";
static NSString * const kSequenceIDMacro = @"%%SEQUENCE_ID%%";

@interface VDirectoryCollectionViewController () <VMarqueeSelectionDelegate, VMarqueeDataDelegate, VDirectoryCollectionFlowLayoutDelegate, VStreamContentCellFactoryDelegate>

@property (nonatomic, strong) NSObject <VDirectoryCellFactory> *directoryCellFactory;

/**
 *  The marquee controller that will provide and manage marquee cells when a marquee is displayed
 */
@property (nonatomic, strong) VAbstractMarqueeController *marqueeController;

@property (nonatomic, strong) ContentViewPresenter *contentViewPresenter;

@end

@implementation VDirectoryCollectionViewController

#pragma mark - Initializers

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager andDirectoryCellFactory:(NSObject <VDirectoryCellFactory> *)directoryCellFactory
{
    //Check that we have all necessary components to show a directory
    if ( directoryCellFactory == nil || dependencyManager == nil)
    {
        /*
         Return nil if the directory cell factory dependency manager are missing as they're both
         integral to being setup properly.
         */
        return nil;
    }
    
    VAbstractMarqueeController *marqueeController = [dependencyManager templateValueOfType:[VAbstractMarqueeController class] forKey:kMarqueeKey];
    if ( marqueeController == nil )
    {
        return nil;
    }
    
    VDirectoryCollectionViewController *streamDirectory = [[[self class] alloc] initWithNibName:nil bundle:nil];
    streamDirectory.currentStream = stream;
    streamDirectory.title = stream.name;
    streamDirectory.dependencyManager = dependencyManager;
    streamDirectory.directoryCellFactory = directoryCellFactory;
    if ( [directoryCellFactory isKindOfClass:[VStreamContentCellFactory class]] )
    {
        VStreamContentCellFactory *streamItemFactory = (VStreamContentCellFactory *)directoryCellFactory;
        streamItemFactory.delegate = streamDirectory;
    }
    
    VDirectoryCollectionFlowLayout *flowLayout = streamDirectory.directoryCellFactory.collectionViewFlowLayout;
    flowLayout.delegate = streamDirectory;
    UICollectionViewFlowLayout *layout = flowLayout ?: [[UICollectionViewFlowLayout alloc] init];
    streamDirectory.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    streamDirectory.marqueeController = marqueeController;
    [streamDirectory.marqueeController registerCollectionViewCellWithCollectionView:streamDirectory.collectionView];
    streamDirectory.marqueeController.selectionDelegate = streamDirectory;
    streamDirectory.marqueeController.dataDelegate = streamDirectory;
    
    return streamDirectory;
}

#pragma mark - VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    
    NSString *url = [dependencyManager stringForKey:kStreamURLKey];
    NSString *sequenceID = [dependencyManager stringForKey:kSequenceIDKey];
    if ( sequenceID != nil )
    {
        VSDKURLMacroReplacement *urlMacroReplacement = [[VSDKURLMacroReplacement alloc] init];
        url = [urlMacroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kSequenceIDMacro: sequenceID }
                                                                   inURLString:url];
    }
    
    NSString *path = [url v_pathComponent];
    NSDictionary *query = @{ @"apiPath" : path };
    __block VStream *stream = nil;
    id<PersistentStoreType>  persistentStore = [PersistentStoreSelector defaultPersistentStore];
    [persistentStore.mainContext performBlockAndWait:^void {
        stream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream v_entityName] queryDictionary:query];
        stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
        [persistentStore.mainContext save:nil];
    }];
    
    NSObject <VDirectoryCellFactory> *cellFactory = [[VDirectoryContentCellFactory alloc] initWithDependencyManager:dependencyManager];
    VDirectoryCollectionViewController *directoryVC = [self streamDirectoryForStream:stream dependencyManager:dependencyManager andDirectoryCellFactory:cellFactory];
    
    return directoryVC;
}

#pragma mark - Shared setup

- (void)viewDidLoad
{
    self.contentViewPresenter = [[ContentViewPresenter alloc] init];
    
    [super viewDidLoad];
    
    [self updateHeaderCellVisibility];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    NSDictionary *views = @{ @"collectionView" : self.collectionView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    self.view.backgroundColor = [[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey] colorWithAlphaComponent:1.0f];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.directoryCellFactory registerCellsWithCollectionView:self.collectionView];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.collectionView.dataSource = self.streamDataSource;
    self.collectionView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    // Layout may have changed between awaking from nib and being added to the container of the SoS
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)updateHeaderCellVisibility
{
    self.streamDataSource.hasHeaderCell = self.marqueeController.marqueeItems.count > 0;
}

#pragma mark - VMarqueeControllerDataDelegate

- (void)marqueeController:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems
{
    [self updateHeaderCellVisibility];
}

#pragma mark - VMarqueeControllerSelectionDelegate

- (void)marqueeController:(VAbstractMarqueeController *)marquee didSelectItem:(VStreamItem *)streamItem withPreviewImage:(UIImage *)image fromCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:streamItem
                                                                      stream:self.currentStream
                                                                   fromShelf:YES];
    event.indexPath = indexPath;
    event.collectionView = collectionView;
    
    [self navigateToDisplayStreamItemWithEvent:event];
}

- (void)marqueeController:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
{
    UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerFor:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - misc marquee helpers

- (BOOL)isMarqueeSection:(NSUInteger)section
{
    return ( self.streamDataSource.hasHeaderCell && section == 0 );
}

- (CGSize)marqueeSizeWithCollectionViewBounds:(CGRect)collectionViewBounds
{
    return [self.marqueeController desiredSizeWithCollectionViewBounds:collectionViewBounds];
}

#pragma mark - VDirectoryCollectionFlowLayoutMarqueeDelegate

- (BOOL)hasMarqueeCell
{
    return self.streamDataSource.hasHeaderCell;
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)localCollectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self isMarqueeSection:indexPath.section] )
    {
        //Return size for the marqueeCell that is provided by our superclass
        return [self.marqueeController desiredSizeWithCollectionViewBounds:localCollectionView.bounds];
    }
    
    return [self.directoryCellFactory sizeWithCollectionViewBounds:localCollectionView.bounds ofCellForStreamItem:[self.streamDataSource.visibleItems objectAtIndex:indexPath.row]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if ( section == 0 )
    {
        edgeInsets = UIEdgeInsetsMake(self.topInset,
                                      0.0f,
                                      0.0f,
                                      0.0f);
    }
    
    if ( ![self isMarqueeSection:section] )
    {
        //We're dealing with a directory section, add the edge insets from the factory
        UIEdgeInsets factoryInsets = self.directoryCellFactory.sectionInsets;
        edgeInsets.top += factoryInsets.top;
        edgeInsets.right += factoryInsets.right;
        edgeInsets.bottom += factoryInsets.bottom;
        edgeInsets.left += factoryInsets.left;
    }
    
    return edgeInsets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = [self.streamDataSource itemAtIndexPath:indexPath];
    
    StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:streamItem
                                                                      stream:self.currentStream
                                                                   fromShelf:NO];
    
    [self navigateToDisplayStreamItemWithEvent:event];
}

- (void)navigateToDisplayStreamItemWithEvent:(StreamCellContext *)event
{
    VStreamItem *streamItem = event.streamItem;
    
    if ( streamItem.isSingleStream )
    {
        VStreamCollectionViewController *streamCollection = [self.dependencyManager templateValueOfType:[VStreamCollectionViewController class]
                                                                                                 forKey:kStreamCollectionKey
                                                                                  withAddedDependencies:@{ kSequenceIDKey: streamItem.remoteId, VDependencyManagerTitleKey: streamItem.name }];
        [self.navigationController pushViewController:streamCollection animated:YES];
    }
    else if ( streamItem.isContent )
    {
        [self.streamTrackingHelper onStreamCellSelectedWithCellEvent:event additionalInfo:nil];
        
        NSString *streamId = self.marqueeController.shelf.remoteId;
        ContentViewContext *context = [[ContentViewContext alloc] init];
        context.sequence = (VSequence *)streamItem;
        context.streamId = streamId;
        context.viewController = [self.dependencyManager scaffoldViewController].rootNavigationController;
        context.originDependencyManager = self.dependencyManager;
        UICollectionViewCell *cell = [event.collectionView cellForItemAtIndexPath:event.indexPath];
        if ( [cell conformsToProtocol:@protocol(VContentPreviewViewProvider)] )
        {
            context.contentPreviewProvider = (id<VContentPreviewViewProvider>)cell;
        }
        [self.contentViewPresenter presentContentViewWithContext:context];
    }
    else if ( [streamItem isKindOfClass:[VStream class]] )
    {
        VDirectoryCollectionViewController *destinationDirectory = [self.dependencyManager templateValueOfType:[VDirectoryCollectionViewController class]
                                                                                                                forKey:kDestinationDirectoryKey
                                                                                                 withAddedDependencies:@{ kSequenceIDKey: streamItem.remoteId, VDependencyManagerTitleKey: streamItem.name }];
        [self.navigationController pushViewController:destinationDirectory animated:YES];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.directoryCellFactory minimumInterItemSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.directoryCellFactory minimumLineSpacing];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if ( [self isMarqueeSection:indexPath.section] )
    {
        return (UICollectionViewCell *)[self.marqueeController marqueeCellForCollectionView:self.collectionView atIndexPath:indexPath];
    }
    
    return [self.directoryCellFactory collectionView:self.collectionView cellForStreamItem:[self.streamDataSource.visibleItems objectAtIndex:indexPath.row] atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)localCollectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ![self isMarqueeSection:indexPath.section] && [self.directoryCellFactory respondsToSelector:@selector(prepareCell:forDisplayInCollectionView:atIndexPath:)] )
    {
        //Allow directory cell factory to prepare cell for display
        [(id <VDirectoryCellUpdeatableFactory>)self.directoryCellFactory prepareCell:cell forDisplayInCollectionView:localCollectionView atIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( [super respondsToSelector:@selector(scrollViewDidScroll:)] )
    {
        [super scrollViewDidScroll:scrollView];
    }
    
    if ( [scrollView isKindOfClass:[UICollectionView class]] && [self.directoryCellFactory respondsToSelector:@selector(collectionViewDidScroll:)] )
    {
        [(id <VDirectoryCellUpdeatableFactory>)self.directoryCellFactory collectionViewDidScroll:(UICollectionView *)scrollView];
    }
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Paginated Data Source Delegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [self.collectionView reloadData];
}

@end
