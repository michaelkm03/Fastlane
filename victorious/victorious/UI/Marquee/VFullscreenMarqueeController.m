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

#import "VShowcaseCollectionViewController.h"
#import "VFullscreenMarqueeTabIndicatorView.h"

#import "VThemeManager.h"
#import "VTimerManager.h"

@interface VFullscreenMarqueeController () <VFullscreenMarqueeCellDelegate>

@property (nonatomic, weak) IBOutlet UIView *tabContainerView;

@end

@implementation VFullscreenMarqueeController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if ( self != nil )
    {
        _hideMarqueePosterImage = YES;
    }
    return self;
}

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
    
    streamItemCell.hideMarqueePosterImage = self.hideMarqueePosterImage;
    streamItemCell.delegate = self;
    
    return streamItemCell;
}

- (void)setHideMarqueePosterImage:(BOOL)hideMarqueePosterImage
{
    _hideMarqueePosterImage = hideMarqueePosterImage;
    for (VFullscreenMarqueeStreamItemCell *marqueeCell in self.collectionView.visibleCells)
    {
        marqueeCell.hideMarqueePosterImage = hideMarqueePosterImage;
    }
}

#pragma mark - VMarqueeCellDelegate

- (void)cell:(VFullscreenMarqueeStreamItemCell *)cell selectedUser:(VUser *)user
{
    if ( [self.selectionDelegate conformsToProtocol:@protocol(VFullscreenMarqueeSelectionDelegate)] )
    {
        [(id <VFullscreenMarqueeSelectionDelegate>)self.selectionDelegate marquee:self selectedUser:user atIndexPath:[self.collectionView indexPathForCell:cell]];
        [self.autoScrollTimerManager invalidate];
    }
}

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
    cell.hideMarqueePosterImage = self.hideMarqueePosterImage;
    
    [self enableTimer];
    return cell;
}

@end
