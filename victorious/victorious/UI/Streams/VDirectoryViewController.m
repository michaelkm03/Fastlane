//
//  VDirectoryViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
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
#import "VStreamDirectoryGroupCell.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"

#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VObjectManager.h"
#import "VSettingManager.h"

static NSString * const kStreamURLPathKey = @"streamUrlPath";

static CGFloat const kDirectoryInset = 5.0f;

@interface VDirectoryViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate, VStreamDirectoryGroupCellDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

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
    VStream *stream = [VStream streamForPath:[dependencyManager stringForKey:kStreamURLPathKey] inContext:dependencyManager.objectManager.managedObjectStore.mainQueueManagedObjectContext];
    stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    return [self streamDirectoryForStream:stream dependencyManager:dependencyManager];
}

#pragma mark - UIView overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *identifier = NSStringFromClass([VStreamDirectoryGroupCell class]);
    UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
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
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    
    BOOL isStreamOfStreamsRow = [[self.streamDataSource itemAtIndexPath:indexPath] isKindOfClass:[VStream class]] && [(VStream *)[self.streamDataSource itemAtIndexPath:indexPath] isStreamOfStreams];
    
    CGFloat height = isStreamOfStreamsRow ? [VStreamDirectoryGroupCell desiredStreamOfStreamsHeightForWidth:width] : [VStreamDirectoryGroupCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[VStream class]] && [((VStream *)item) onlyContainsSequences])
    {
        VStreamCollectionViewController *streamCollection = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)item];
        streamCollection.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:streamCollection animated:YES];
    }
    else if ([item isKindOfClass:[VStream class]])
    {
        VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:(VStream *)item dependencyManager:self.dependencyManager];
        sos.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:sos animated:YES];
    }
    else if ([item isKindOfClass:[VSequence class]])
    {
        [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:(VSequence *)item commentId:nil placeHolderImage:nil];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.topInset + kStreamDirectoryGroupCellInset,
                            0,
                            kDirectoryInset,
                            0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    VStreamDirectoryGroupCell *cell;
    
    NSString *identifier = NSStringFromClass([VStreamDirectoryGroupCell class]);
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.streamItem = item;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - 

- (void)streamDirectoryGroupCell:(VStreamDirectoryGroupCell *)VStreamDirectoryGroupCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Check to see if we've selected the the count of items in the cell's streamItem (which would mean we selected the "see more" cell)
    if ( indexPath.row == 10 )
    {
        //Push a new directory view controller to show all contents of the selected streamItem
        VStream *stream = [self.currentStream.streamItems objectAtIndex:[self.collectionView indexPathForCell:VStreamDirectoryGroupCell].row];
        VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:stream dependencyManager:self.dependencyManager];
        sos.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:sos animated:YES];
    }
    else
    {
        //Check if we've selected a bit of content or another stream to present in a VDirectoryViewController
        VStreamItem *item = VStreamDirectoryGroupCell.streamItem;
        if ([item isKindOfClass:[VStream class]] && [((VStream *)item) onlyContainsSequences])
        {
            VStreamCollectionViewController *streamCollection = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)item];
            streamCollection.dependencyManager = self.dependencyManager;
            [self.navigationController pushViewController:streamCollection animated:YES];
        }
        else if ([item isKindOfClass:[VStream class]])
        {
            VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:(VStream *)item dependencyManager:self.dependencyManager];
            sos.dependencyManager = self.dependencyManager;
            [self.navigationController pushViewController:sos animated:YES];
        }
        else if ([item isKindOfClass:[VSequence class]])
        {
            [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:(VSequence *)item commentId:nil placeHolderImage:nil];
        }
    }
}

@end
