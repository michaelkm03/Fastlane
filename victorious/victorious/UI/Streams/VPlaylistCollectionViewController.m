//
//  VPlaylistCollectionViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPlaylistCollectionViewController.h"
#import "VDirectoryPlaylistCell.h"

#import "VStreamItem+Fetcher.h"
#import "VStream+Fetcher.h"

#import "VDependencyManager+VScaffoldViewController.h"
#import "VScaffoldViewController.h"

#import "VDirectoryViewController.h"
#import "VStreamCollectionViewController.h"

static const CGFloat kPlaylistCellHeight = 140.0f;

@interface VPlaylistCollectionViewController ()

@end

@implementation VPlaylistCollectionViewController

- (NSString *)cellIdentifier
{
    return [VDirectoryPlaylistCell suggestedReuseIdentifier];
}

- (UINib *)cellNib
{
    return [VDirectoryPlaylistCell nibForCell];
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake( width, kPlaylistCellHeight );
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
        VDirectoryViewController *sos = [VDirectoryViewController streamDirectoryForStream:(VStream *)item dependencyManager:self.dependencyManager];
        sos.dependencyManager = self.dependencyManager;
        [self.navigationController pushViewController:sos animated:YES];
    }
    else if ([item isKindOfClass:[VSequence class]])
    {
        [[self.dependencyManager scaffoldViewController] showContentViewWithSequence:(VSequence *)item commentId:nil placeHolderImage:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateParallaxOffsetOfVisibleCells];
}

- (void)updateParallaxOffsetOfVisibleCells
{
    for ( VDirectoryPlaylistCell *playlistCell in self.collectionView.visibleCells )
    {
        [self updateParallaxYOffsetOfCell:playlistCell withMidY:CGRectGetMidY(playlistCell.frame)];
    }
}

- (void)updateParallaxYOffsetOfCell:(VDirectoryPlaylistCell *)playlistCell withMidY:(CGFloat)midY
{
    //Determine and set the parallaxYOffset for the provided cell
    
    CGFloat topInset = 20.0f; // Only the height of the status bar
    CGFloat contentOffset = self.collectionView.contentOffset.y;
    CGFloat cellHeight = CGRectGetHeight(playlistCell.bounds);
    CGFloat yRange = CGRectGetHeight(self.collectionView.bounds) - topInset + cellHeight;
    CGFloat cellCenter = midY - topInset;
    playlistCell.parallaxYOffset = (contentOffset - cellCenter - ( cellHeight / 2 ) ) / (yRange / 2) + 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(self.topInset,
                            0.0f,
                            0.0f,
                            0.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VDirectoryPlaylistCell suggestedReuseIdentifier];
    VDirectoryPlaylistCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    cell.dependencyManager = self.dependencyManager;
    CGFloat interLineSpace = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:0];
    CGFloat midY = kPlaylistCellHeight / 2 + indexPath.row * (kPlaylistCellHeight + interLineSpace) + 20.0f;
    [self updateParallaxYOffsetOfCell:cell withMidY:midY];
    return cell;
}

@end
