//
//  VMarqueeController.m
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

#import "VGroupedStreamCollectionViewController.h"
#import "VFullscreenMarqueeTabIndicatorView.h"

#import "VThemeManager.h"
#import "VTimerManager.h"

@interface VFullscreenMarqueeController () <VFullscreenMarqueeCellDelegate>

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
    if ( currentPage < [[self streamDataSource] collectionView:self.collectionView numberOfItemsInSection:0] )
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

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    VFullscreenMarqueeStreamItemCell *cell = (VFullscreenMarqueeStreamItemCell *)[super dataSource:dataSource cellForIndexPath:indexPath];
    
    cell.hideMarqueePosterImage = self.hideMarqueePosterImage;
    cell.delegate = self;
    
    return cell;
}

//Let the container handle the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    VFullscreenMarqueeStreamItemCell *cell = (VFullscreenMarqueeStreamItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *previewImage = nil;
    if ( [cell isKindOfClass:[VFullscreenMarqueeStreamItemCell class]] )
    {
        previewImage = cell.previewImageView.image;
    }
    
    [self.delegate marquee:self selectedItem:item atIndexPath:indexPath previewImage:previewImage];
    [self.autoScrollTimerManager invalidate];
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
    [self.delegate marquee:self selectedUser:user atIndexPath:[self.collectionView indexPathForCell:cell]];
    [self.autoScrollTimerManager invalidate];
}

@end
