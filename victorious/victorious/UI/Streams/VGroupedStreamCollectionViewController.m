//
//  VGroupedStreamCollectionViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGroupedStreamCollectionViewController.h"

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
#import "NSString+VParseHelp.h"

static NSString * const kItemColor = @"itemColor";
static NSString * const kBackgroundColor = @"backgroundColor";

static CGFloat const kDirectoryInset = 5.0f;

@interface VGroupedStreamCollectionViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VStreamCollectionDataDelegate, VDirectoryGroupCellDelegate>

@end

@implementation VGroupedStreamCollectionViewController

- (NSString *)cellIdentifier
{
    return [VDirectoryGroupCell suggestedReuseIdentifier];
}

- (UINib *)cellNib
{
    return [VDirectoryGroupCell nibForCell];
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
        VGroupedStreamCollectionViewController *sos = [VGroupedStreamCollectionViewController streamDirectoryForStream:(VStream *)item dependencyManager:self.dependencyManager];
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
    cell.dependencyManager = self.dependencyManager;
    return cell;
}

#pragma mark - 

- (void)streamDirectoryGroupCell:(VDirectoryGroupCell *)groupCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Check to see if we've selected the the count of items in the cell's streamItem (which would mean we selected the "see more" cell)
    VStreamItem *streamItem;
    
    if ( [groupCell.indexPathForShowMore isEqual:indexPath] )
    {
        NSIndexPath *shelfIndexPath = [self.collectionView indexPathForCell:groupCell];
        streamItem = self.currentStream.streamItems[shelfIndexPath.row];
    }
    else
    {
        streamItem = groupCell.stream.streamItems[ indexPath.row ];
    }
    
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
        VGroupedStreamCollectionViewController *viewController = [VGroupedStreamCollectionViewController streamDirectoryForStream:(VStream *)streamItem
                                                                                                                dependencyManager:self.dependencyManager];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
