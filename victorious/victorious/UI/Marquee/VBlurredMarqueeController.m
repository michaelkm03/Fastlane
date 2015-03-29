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
static const CGFloat kAnimationDuration = 5.0f;

@interface VBlurredMarqueeController () <UIScrollViewDelegate>

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
    if (currentPage == (NSInteger)self.streamDataSource.count)
    {
        currentPage = 0;
    }
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
#warning NEED TO FIND A WAY AROUND THIS
         [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
     }
                     completion:nil];
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
