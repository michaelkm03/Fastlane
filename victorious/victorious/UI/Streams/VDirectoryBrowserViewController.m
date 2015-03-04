//
//  VDirectoryBrowserViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryBrowserViewController.h"

// Data Source
#import "VStreamCollectionViewDataSource.h"

// ViewControllers
#import "VStreamCollectionViewController.h"
#import "VNewContentViewController.h"
#import "VScaffoldViewController.h"

// Views
#import "MBProgressHUD.h"
#import "VDirectoryGroupCell.h"

//Data Models
#import "VStream+Fetcher.h"
#import "VSequence.h"

#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VObjectManager.h"
#import "VSettingManager.h"
#import "VStreamItem+Fetcher.h"
#import "UIColor+VBrightness.h"

static NSString * const kStreamURLPathKey = @"streamUrlPath";
static NSString * const kItemColor = @"itemColor";
static NSString * const kBackgroundColor = @"backgroundColor";

static CGFloat const kDirectoryInset = 5.0f;

@interface VDirectoryBrowserViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate, VDirectoryGroupCellDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VDirectoryBrowserViewController

#pragma mark - Initializers

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager
{
    VDirectoryBrowserViewController *streamDirectory = [[VDirectoryBrowserViewController alloc] initWithNibName:nil
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
    
    self.view.backgroundColor = [self.dependencyManager colorForKey:@"color.background"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    NSString *identifier = [VDirectoryGroupCell suggestedReuseIdentifier];
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
    
    VStreamItem *streamItem = [self.streamDataSource itemAtIndexPath:indexPath];
    
    CGFloat height = streamItem.isStreamOfStreams ? [VDirectoryGroupCell desiredStreamOfStreamsHeightForWidth:width] : [VDirectoryGroupCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake( width, height );
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    if ( item.isSingleStream )
    {
        VStreamCollectionViewController *streamCollection = [VStreamCollectionViewController streamViewControllerForStream:(VStream *)item];
        streamCollection.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:streamCollection animated:YES];
    }
    else if ([item isKindOfClass:[VStream class]])
    {
        VDirectoryBrowserViewController *sos = [VDirectoryBrowserViewController streamDirectoryForStream:(VStream *)item dependencyManager:self.dependencyManager];
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
    NSString *identifier = [VDirectoryGroupCell suggestedReuseIdentifier];
    VDirectoryGroupCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    cell.delegate = self;
    NSDictionary *component = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"cell.directory.group"];
    cell.dependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:component];
    return cell;
}

#pragma mark - 

- (void)streamDirectoryGroupCell:(VDirectoryGroupCell *)groupCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Check to see if we've selected the the count of items in the cell's streamItem (which would mean we selected the "see more" cell)
    if ( indexPath.row == (NSInteger)VDirectoryMaxItemsPerGroup )
    {
        //Push a new directory view controller to show all contents of the selected streamItem
        VStream *stream = [self.currentStream.streamItems objectAtIndex:[self.collectionView indexPathForCell:groupCell].row];
        VDirectoryBrowserViewController *directoryViewController = [VDirectoryBrowserViewController streamDirectoryForStream:stream dependencyManager:self.dependencyManager];
        directoryViewController.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:directoryViewController animated:YES];
    }
    else
    {
        VStreamItem *streamItem = groupCell.stream.streamItems[ indexPath.row ];
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
            VDirectoryBrowserViewController *viewController = [VDirectoryBrowserViewController streamDirectoryForStream:(VStream *)streamItem
                                                                                        dependencyManager:self.dependencyManager];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

@end
