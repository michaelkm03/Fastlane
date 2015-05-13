//
//  VFullscreenMarqueeController.m
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeController.h"

#import "VStream+Fetcher.h"
#import "VSequence.h"

#import "VStreamCollectionViewDataSource.h"
#import "VFullscreenMarqueeStreamItemCell.h"
#import "VFullscreenMarqueeCollectionCell.h"
#import "VFullscreenMarqueeSelectionDelegate.h"

#import "VFullscreenMarqueeTabIndicatorView.h"

#import "VThemeManager.h"
#import "VTimerManager.h"

#import "VDependencyManager+VBackgroundContainer.h"

@interface VFullscreenMarqueeController ()

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@end

@implementation VFullscreenMarqueeController

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

- (NSTimeInterval)timerFireInterval
{
    return kVDetailVisibilityDuration + kVDetailHideDuration;
}

- (NSString *)cellSuggestedReuseIdentifier
{
    return [VFullscreenMarqueeStreamItemCell suggestedReuseIdentifier];
}

- (void)scrolledToPage:(NSInteger)currentPage
{
    [super scrolledToPage:currentPage];
    self.tabView.currentlySelectedTab = currentPage;
}

#pragma mark - CollectionViewDelegate

- (void)enableTimer
{
    [super enableTimer];
    NSInteger currentPage = self.currentPage;
    if ( currentPage < [self collectionView:self.collectionView numberOfItemsInSection:0] )
    {
        for ( VFullscreenMarqueeStreamItemCell *cell in self.collectionView.visibleCells )
        {
            if ( [self.collectionView indexPathForCell:cell].row == currentPage )
            {
                [cell setDetailsContainerVisible:YES animated:NO];
                [cell restartHideTimer];
                return;
            }
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VFullscreenMarqueeStreamItemCell *streamItemCell = (VFullscreenMarqueeStreamItemCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    [self.dependencyManager addLoadingBackgroundToBackgroundHost:streamItemCell];
    
    return streamItemCell;
}

#pragma mark - VMarqueeCellDelegate

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VFullscreenMarqueeCollectionCell nibForCell] forCellWithReuseIdentifier:[VFullscreenMarqueeCollectionCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    VFullscreenMarqueeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VFullscreenMarqueeCollectionCell suggestedReuseIdentifier]
                                                                                       forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.marquee = self;
    self.tabView.currentlySelectedTab = self.currentPage;
    CGSize desiredSize = [VFullscreenMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
    cell.bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
    
    [self enableTimer];
    return cell;
}

@end
