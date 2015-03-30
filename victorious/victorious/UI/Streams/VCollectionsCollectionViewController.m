//
//  VPlaylistCollectionViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCollectionsCollectionViewController.h"
#import "VDirectoryCollectionsCell.h"

#import "VStreamItem+Fetcher.h"
#import "VStream+Fetcher.h"

#import "VDependencyManager+VScaffoldViewController.h"
#import "VScaffoldViewController.h"

#import "VDirectoryViewController.h"
#import "VStreamCollectionViewController.h"

static const CGFloat kPlaylistCellHeight = 140.0f;

static const CGFloat kStatusBarHeight = 20.0f;

/**
 Divides the delay applied to animations on first load of collection view:
 at 1: all cells animate at the same time
 below 1: cells animate from bottom to top
 above 1: cells animate from top to bottom
 */
static const CGFloat kAnimationPropogationDivisor = 3.5f;

@interface VCollectionsCollectionViewController ()

@property (nonatomic, assign) BOOL shouldAnimateCells;

@end

@implementation VCollectionsCollectionViewController

- (NSString *)cellIdentifier
{
    return [VDirectoryCollectionsCell suggestedReuseIdentifier];
}

- (UINib *)cellNib
{
    return [VDirectoryCollectionsCell nibForCell];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldAnimateCells = YES;
}

#pragma mark - CollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VDirectoryCollectionsCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
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
    NSString *identifier = [VDirectoryCollectionsCell suggestedReuseIdentifier];
    VDirectoryCollectionsCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = [self.currentStream.streamItems objectAtIndex:indexPath.row];
    cell.dependencyManager = self.dependencyManager;
    CGFloat interLineSpace = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:0];
    
    //Need to add statusBarHeight here since it will be added into the yOrigin by the collectionView
    CGFloat yOrigin = indexPath.row * (kPlaylistCellHeight + interLineSpace) + kStatusBarHeight;
    [self updateParallaxYOffsetOfCell:cell withYOrigin:yOrigin];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.shouldAnimateCells )
    {
        CGFloat collectionViewHeight = CGRectGetHeight(collectionView.bounds);
        CGFloat percentageDownscreen = CGRectGetMinY(cell.frame) / collectionViewHeight;
        [(VDirectoryCollectionsCell *)cell animate:NO toVisible:NO afterDelay:0.0f];
        [(VDirectoryCollectionsCell *)cell animate:YES toVisible:YES afterDelay:percentageDownscreen / kAnimationPropogationDivisor];
        if ( CGRectGetMaxY(cell.frame) > collectionViewHeight )
        {
            self.shouldAnimateCells = NO;
        }
    }
}

#pragma mark - Parallax updating

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateParallaxOffsetOfVisibleCells];
}

- (void)updateParallaxOffsetOfVisibleCells
{
    for ( VDirectoryCollectionsCell *playlistCell in self.collectionView.visibleCells )
    {
        [self updateParallaxYOffsetOfCell:playlistCell withYOrigin:CGRectGetMinY(playlistCell.frame)];
    }
}

- (void)updateParallaxYOffsetOfCell:(VDirectoryCollectionsCell *)playlistCell withYOrigin:(CGFloat)yOrigin
{
    //Determine and set the parallaxYOffset for the provided cell.
    
    CGFloat cellHeight = CGRectGetHeight(playlistCell.bounds);
    CGFloat contentOffset = self.collectionView.contentOffset.y;
    
    //Represents entire range where the ENTIRE cell is visible. Must remove "topInset" (the status bar height) from the collectionViewBounds height because it isn't otherwise accounted for and the status bar appears in front of the visible cells
    CGFloat yRange = CGRectGetHeight(self.collectionView.bounds) - kStatusBarHeight + cellHeight;
    
    //This will provide a value in the range [-1, 0] such that the cell is just touching the status bar at -1 and just touching the bottom of the collection view bounds at 0
    CGFloat unnormalizedYOffset = ( contentOffset - ( yOrigin - kStatusBarHeight ) - cellHeight ) / yRange;
    
    //We need to pass in values in the range [-1, 1] for the parallaxYOffset to have proper image displaying. Noramlize the value we yOffset value we have by multiplying by 2 and adding 1.
    playlistCell.parallaxYOffset = ( unnormalizedYOffset * 2 ) + 1;
}

@end
