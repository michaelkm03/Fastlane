//
//  VCollectionsDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCollectionsDirectoryCellFactory.h"
#import "VCollectionsDirectoryCell.h"
#import "VDirectoryCollectionViewController.h"
#import "VDependencyManager.h"
#import "VShowcaseDirectoryCellFactory.h"
#import "NSString+VParseHelp.h"
#import "VDependencyManager+VObjectManager.h"
#import "VObjectManager.h"
#import "VStream+Fetcher.h"

static const CGFloat kPlaylistCellHeight = 140.0f;
static const CGFloat kStatusBarHeight = 20.0f;

/**
 Divides the delay applied to animations on first load of collection view:
 at 1: all cells animate at the same time
 below 1: cells animate from bottom to top
 above 1: cells animate from top to bottom
 */
static const CGFloat kAnimationPropogationDivisor = 3.5f;

@interface VCollectionsDirectoryCellFactory ()

@property (nonatomic, assign) BOOL shouldAnimateCells;

@end

@implementation VCollectionsDirectoryCellFactory

@synthesize dependencyManager;

- (instancetype)initWithDependencyManager:(VDependencyManager *)localDependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        dependencyManager = localDependencyManager;
        _shouldAnimateCells = YES;
    }
    return self;
}

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds andStreamItem:(VStreamItem *)streamItem
{
    return [VCollectionsDirectoryCell desiredSizeWithCollectionViewBounds:bounds];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VCollectionsDirectoryCell nibForCell] forCellWithReuseIdentifier:[VCollectionsDirectoryCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    NSString *identifier = [VCollectionsDirectoryCell suggestedReuseIdentifier];
    VCollectionsDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = streamItem;
    cell.dependencyManager = self.dependencyManager;
    CGFloat interLineSpace = self.minimumLineSpacing;
    
    //Need to add statusBarHeight here since it will be added into the yOrigin by the collectionView
    CGFloat yOrigin = indexPath.row * (kPlaylistCellHeight + interLineSpace) + kStatusBarHeight;
    [self updateParallaxYOffsetOfCell:cell inCollectionView:collectionView withYOrigin:yOrigin];
    return cell;
}

- (CGFloat)minimumInterItemSpacing
{
    return 0.0f;
}

- (CGFloat)minimumLineSpacing
{
    return 1.0f;
}

- (UIEdgeInsets)sectionEdgeInsets
{
    return UIEdgeInsetsZero;
}

- (void)prepareCell:(UICollectionViewCell *)cell forDisplayInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    if ( self.shouldAnimateCells )
    {
        CGFloat collectionViewHeight = CGRectGetHeight(collectionView.bounds);
        CGFloat percentageDownscreen = CGRectGetMinY(cell.frame) / collectionViewHeight;
        [(VCollectionsDirectoryCell *)cell animate:NO toVisible:NO afterDelay:0.0f];
        [(VCollectionsDirectoryCell *)cell animate:YES toVisible:YES afterDelay:percentageDownscreen / kAnimationPropogationDivisor];
        if ( CGRectGetMaxY(cell.frame) > collectionViewHeight || indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1 )
        {
            self.shouldAnimateCells = NO;
        }
    }
}

- (void)collectionViewDidScroll:(UICollectionView *)collectionView
{
    [self updateParallaxOffsetOfVisibleCellsOfCollectionView:collectionView];
}

- (void)updateParallaxOffsetOfVisibleCellsOfCollectionView:(UICollectionView *)collectionView
{
    for ( UICollectionViewCell *cell in collectionView.visibleCells )
    {
        if ( [cell isKindOfClass:[VCollectionsDirectoryCell class]] )
        {
            [self updateParallaxYOffsetOfCell:(VCollectionsDirectoryCell *)cell inCollectionView:collectionView withYOrigin:CGRectGetMinY(cell.frame)];
        }
    }
}

- (void)updateParallaxYOffsetOfCell:(VCollectionsDirectoryCell *)playlistCell inCollectionView:(UICollectionView *)collectionView withYOrigin:(CGFloat)yOrigin
{
    //Determine and set the parallaxYOffset for the provided cell.
    
    CGFloat cellHeight = CGRectGetHeight(playlistCell.bounds);
    CGFloat contentOffset = collectionView.contentOffset.y;
    
    //Represents entire range where the ENTIRE cell is visible. Must remove "topInset" (the status bar height) from the collectionViewBounds height because it isn't otherwise accounted for and the status bar appears in front of the visible cells
    CGFloat yRange = CGRectGetHeight(collectionView.bounds) - kStatusBarHeight + cellHeight;
    
    //Protects against the possibility of yRange being zero (in case our cell height is changed to the height of the whole screen for some reason)
    yRange = fmax( yRange, 1.0f );
    
    //This will provide a value in the range [-1, 0] such that the cell is just touching the status bar at -1 and just touching the bottom of the collection view bounds at 0
    CGFloat unnormalizedYOffset = ( contentOffset - ( yOrigin - kStatusBarHeight ) - cellHeight ) / yRange;
    
    //We need to pass in values in the range [-1, 1] for the parallaxYOffset to have proper image displaying. Noramlize the value we yOffset value we have by multiplying by 2 and adding 1.
    playlistCell.parallaxYOffset = ( unnormalizedYOffset * 2 ) + 1;
}

@end
