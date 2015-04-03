//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryViewController.h"

// Data Source
#import "VStreamCollectionViewDataSource.h"

// ViewControllers
#import "VStreamCollectionViewController.h"
#import "VNewContentViewController.h"
#import "VScaffoldViewController.h"

// Views
#import "MBProgressHUD.h"
#import "VDirectoryItemCell.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"

#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VObjectManager.h"
#import "VSettingManager.h"
#import "VDirectoryCellDecorator.h"
#import "NSString+VParseHelp.h"
#import <FBKVOController.h>

#import "VMarqueeCollectionCell.h"
#import "VMarqueeController.h"
#import "VUserProfileViewController.h"

static NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";
static NSString * const kStreamURLKey = @"streamURL";

static CGFloat const kDirectoryInset = 10.0f;

@interface VDirectoryViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate, VMarqueeSelectionDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VDirectoryCellDecorator *cellDecorator;
@property (nonatomic, strong) VMarqueeController *marqueeController;

@end

@implementation VDirectoryViewController

#pragma mark - Initializers

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager
{
    VDirectoryViewController *streamDirectory = [[VDirectoryViewController alloc] initWithNibName:nil
                                                                                           bundle:nil];
    streamDirectory.currentStream = stream;
    streamDirectory.title = stream.name;
    streamDirectory.dependencyManager = dependencyManager;
    
    return streamDirectory;
}

- (void)setCurrentStream:(VStream *)currentStream
{
    [super setCurrentStream:currentStream];
    [self addKVOToMarqueeItemsOfStream:currentStream];
}

- (void)addKVOToMarqueeItemsOfStream:(VStream *)stream
{
    [self.KVOController observe:stream
                        keyPath:@"marqueeItems"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(marqueeItemsUpdated)];
}

- (void)marqueeItemsUpdated
{
    self.streamDataSource.hasHeaderCell = self.currentStream.marqueeItems.count > 0;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(VBaseCollectionViewCell *baseCollectionViewCell, NSUInteger idx, BOOL *stop)
     {
         if ( [baseCollectionViewCell isKindOfClass:[VMarqueeCollectionCell class]] )
         {
             ((VMarqueeCollectionCell *)baseCollectionViewCell).dependencyManager = dependencyManager;
         }
     }];
}

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    VStream *stream = [VStream streamForPath:[[dependencyManager stringForKey:kStreamURLKey] v_pathComponent] inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    return [self streamDirectoryForStream:stream dependencyManager:dependencyManager];
}

#pragma mark - UIView overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.cellDecorator = [[VDirectoryCellDecorator alloc] init];
    
    //Register cells
    [self.collectionView registerNib:[VDirectoryItemCell nibForCell]
          forCellWithReuseIdentifier:[VDirectoryItemCell suggestedReuseIdentifier]];
    
    [self.collectionView registerNib:[VMarqueeCollectionCell nibForCell]
          forCellWithReuseIdentifier:[VMarqueeCollectionCell suggestedReuseIdentifier]];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.streamDataSource;
    self.collectionView.delegate = self;
    
    [self refresh:self.refreshControl];
}

- (void)marquee:(VMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image
{
    NSDictionary *params = @{ VTrackingKeyName : streamItem.name ?: @"",
                              VTrackingKeyRemoteId : streamItem.remoteId ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectItemFromMarquee parameters:params];
    
    [self navigateToDisplayStreamItem:streamItem];
}

- (void)marquee:(VMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path
{
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Layout may have changed between awaking from nib and being added to the container of the SoS
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if ( self.streamDataSource.hasHeaderCell )
    {
        [self.marqueeController enableTimer];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.streamDataSource.hasHeaderCell && indexPath.section == 0 )
    {
        //Return size for the marqueeCell
        return [VMarqueeCollectionCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    width = width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing;
    width = floorf(width * 0.5f);
    
    BOOL isStreamOfStreamsRow = [[self.streamDataSource itemAtIndexPath:indexPath] isKindOfClass:[VStream class]];
    
    if (((indexPath.row % 2) == 1) && !isStreamOfStreamsRow)
    {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        isStreamOfStreamsRow = [[self.streamDataSource itemAtIndexPath:previousIndexPath] isKindOfClass:[VStream class]];
    }
    
    CGFloat height = isStreamOfStreamsRow ? [VDirectoryItemCell desiredStreamOfStreamsHeightForWidth:width] : [VDirectoryItemCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem = [self.streamDataSource itemAtIndexPath:indexPath];
    [self navigateToDisplayStreamItem:streamItem];
}

- (void)navigateToDisplayStreamItem:(VStreamItem *)streamItem
{
    if ( streamItem.isContent )
    {
        VSequence *sequence = (VSequence *)streamItem;
        [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:sequence
                                                                           commentId:nil
                                                                    placeHolderImage:nil];
    }
    else if ( streamItem.isSingleStream )
    {
        VStreamCollectionViewController *viewController = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)streamItem];
        viewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ( streamItem.isStreamOfStreams )
    {
        VDirectoryViewController *viewController = [VDirectoryViewController streamDirectoryForStream:(VStream *)streamItem
                                                                                    dependencyManager:self.dependencyManager];
        viewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    if ( self.streamDataSource.hasHeaderCell )
    {
        if ( section == 0 )
        {
            //Return edge insets for marquee cell (which only need to account for the nav bar)
            return UIEdgeInsetsMake(self.topInset,
                                    0,
                                    0,
                                    0);
        }
        else
        {
            //Return edge insets for the directory cells (note, don't need to apply the topInset since the marquee is accounting for it)
            return UIEdgeInsetsMake(kDirectoryInset,
                                    kDirectoryInset,
                                    0,
                                    kDirectoryInset);
        }
    }
    
    //Return edge insets for directory cells with top inset (to account for nav bar)
    return UIEdgeInsetsMake(self.topInset + kDirectoryInset,
                            kDirectoryInset,
                            0,
                            kDirectoryInset);
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    
    if ( dataSource.hasHeaderCell && indexPath.section == 0 )
    {
        NSString *identifier = [VMarqueeCollectionCell suggestedReuseIdentifier];
        VMarqueeCollectionCell *marqueeCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                             forIndexPath:indexPath];
        marqueeCell.marquee = self.marqueeController;
        [marqueeCell restartAutoScroll];
        return marqueeCell;
    }
    
    NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
    VDirectoryItemCell *directoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                          forIndexPath:indexPath];
    [self.cellDecorator populateCell:directoryCell withStreamItem:item];
    [self.cellDecorator applyStyleToCell:directoryCell withDependencyManager:self.dependencyManager];
    return directoryCell;
}

- (VMarqueeController *)marqueeController
{
    if ( _marqueeController == nil )
    {
        _marqueeController = [[VMarqueeController alloc] initWithStream:self.streamDataSource.stream];
        
        _marqueeController.hideMarqueePosterImage = YES;
        _marqueeController.dependencyManager = self.dependencyManager;
        _marqueeController.selectionDelegate = self;
    }
    return _marqueeController;
}

@end