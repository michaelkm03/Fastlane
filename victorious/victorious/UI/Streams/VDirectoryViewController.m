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

static NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";
static NSString * const kStreamURLPathKey = @"streamURL";

static CGFloat const kDirectoryInset = 10.0f;

@interface VDirectoryViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VDirectoryCellDecorator *cellDecorator;
@property (nonatomic, strong) VDependencyManager *itemCellDependencyManager;

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

#pragma mark VHasManagedDependencies conforming initializer

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    VStream *stream = [VStream streamForPath:[[dependencyManager stringForKey:kStreamURLPathKey] v_pathComponent] inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    return [self streamDirectoryForStream:stream dependencyManager:dependencyManager];
}

#pragma mark - UIView overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *component = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"cell.directory.item"];
    self.itemCellDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:component];
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.cellDecorator = [[VDirectoryCellDecorator alloc] init];
    
    //Register cells
    [self.collectionView registerNib:[VDirectoryItemCell nibForCell]
          forCellWithReuseIdentifier:[VDirectoryItemCell suggestedReuseIdentifier]];
    
    self.streamDataSource = [[VStreamCollectionViewDataSource alloc] initWithStream:self.currentStream];
    self.streamDataSource.delegate = self;
    self.streamDataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.streamDataSource;
    self.collectionView.delegate = self;
    
    [self refresh:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Layout may have changed between awaking from nib and being added to the container of the SoS
    [self.collectionView.collectionViewLayout invalidateLayout];
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
    return UIEdgeInsetsMake(self.topInset + kDirectoryInset,
                            kDirectoryInset,
                            0,
                            kDirectoryInset);
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
    VDirectoryItemCell *direcotryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                          forIndexPath:indexPath];
    [self.cellDecorator populateCell:direcotryCell withStreamItem:item];
    [self.cellDecorator applyStyleToCell:direcotryCell withDependencyManager:self.itemCellDependencyManager];
    return direcotryCell;
}

@end