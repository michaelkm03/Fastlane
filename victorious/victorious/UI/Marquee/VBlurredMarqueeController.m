//
//  VBlurredMarqueeController.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeController.h"
#import "VBlurredMarqueeCollectionViewCell.h"
#import "VBlurredMarqueeStreamItemCell.h"
#import "VMarqueeControllerDelegate.h"
#import "VTimerManager.h"

static const CGFloat kVisibilityDuration = 5.0f;
static const CGFloat kOffsetOvershoot = 20.0f;

@interface VBlurredMarqueeController ()

@property (nonatomic, assign) CGPoint overshootTarget;
@property (nonatomic, assign) CGPoint offsetTarget;
@property (nonatomic, assign) BOOL shouldAnimateToTarget;

@end

@implementation VBlurredMarqueeController

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VBlurredMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

- (NSTimeInterval)timerFireInterval
{
    return kVisibilityDuration;
}

- (NSString *)cellSuggestedReuseIdentifier
{
    return [VBlurredMarqueeStreamItemCell suggestedReuseIdentifier];
}

- (void)selectNextTab
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    currentPage ++;
    CGFloat overshootAmount = kOffsetOvershoot;
    if (currentPage == (NSInteger)self.streamDataSource.count)
    {
        currentPage = 0;
        overshootAmount = - overshootAmount;
    }
    
    CGPoint point = CGPointMake(pageWidth * currentPage + overshootAmount, self.collectionView.contentOffset.y);
    self.overshootTarget = point;
    point.x -= overshootAmount;
    self.offsetTarget = point;
    self.shouldAnimateToTarget = YES;
    [self.collectionView setContentOffset:self.overshootTarget animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if ( self.shouldAnimateToTarget )
    {
        if ( CGPointEqualToPoint(scrollView.contentOffset, self.overshootTarget) )
        {
            [self.collectionView setContentOffset:self.offsetTarget animated:YES];
            self.shouldAnimateToTarget = NO;
        }
    }
}

//Let the container handle the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.streamDataSource itemAtIndexPath:indexPath];
    VBlurredMarqueeStreamItemCell *cell = (VBlurredMarqueeStreamItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *previewImage = nil;
    if ( [cell isKindOfClass:[VBlurredMarqueeStreamItemCell class]] )
    {
        previewImage = cell.previewImageView.image;
    }
    
    [self.delegate marquee:self selectedItem:item atIndexPath:indexPath previewImage:previewImage];
    [self.autoScrollTimerManager invalidate];
}

@end
