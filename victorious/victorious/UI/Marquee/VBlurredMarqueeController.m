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
#import "VCrossFadingLabel.h"
#import "VCrossFadingImageView.h"
#import "VTimerManager.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "UIImage+ImageCreation.h"
#import "VDependencyManager.h"
#import "UIImageView+Blurring.h"
#import <SDWebImage/SDWebImageManager.h>

#import "VDependencyManager+VBackgroundContainer.h"

static const CGFloat kVisibilityDuration = 5.0f;
static const CGFloat kOffsetOvershoot = 20.0f;

@interface VBlurredMarqueeController ()

@property (nonatomic, assign) CGPoint overshootTarget;
@property (nonatomic, assign) CGPoint offsetTarget;
@property (nonatomic, assign) BOOL shouldAnimateToTarget;
@property (nonatomic, assign) BOOL showedInitialDisplayAnimation;
@property (nonatomic, assign) BOOL firstImageLoaded;
@property (nonatomic, assign) BOOL backgroundCellIsVisible;
@property (nonatomic, strong) NSMutableDictionary *loadedImages;

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

- (void)animateToVisible
{
    self.backgroundCellIsVisible = YES;
    if ( self.collectionView.hidden )
    {
        self.collectionView.hidden = NO;
    }
    [self attemptToPerformInitialDisplayAnimation];
}

- (void)selectNextTab
{
    CGFloat pageWidth = CGRectGetWidth(self.collectionView.bounds);
    NSUInteger currentPage = ( self.collectionView.contentOffset.x / pageWidth ) + 1;
    CGFloat overshootAmount = kOffsetOvershoot;
    if (currentPage == self.stream.marqueeItems.count)
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

- (void)marqueeItemsUpdated
{
    [super marqueeItemsUpdated];
    [self refreshCellSubviews];
}

- (void)refreshCellSubviews
{
    if ( self.stream.marqueeItems.count == 0 || self.crossfadingBlurredImageView == nil || self.crossfadingLabel == nil )
    {
        return;
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    NSMutableArray *previewImages = [[NSMutableArray alloc] init];
    NSMutableArray *contentNames = [[NSMutableArray alloc] init];
    
    NSInteger marqueeItemsCount = self.stream.marqueeItems.count;
    if ( self.crossfadingBlurredImageView.imageViewCount != marqueeItemsCount )
    {
        [self.crossfadingBlurredImageView setupWithNumberOfImageViews:marqueeItemsCount];
    }
    
    self.loadedImages = [[NSMutableDictionary alloc] init];
    self.firstImageLoaded = NO;
    
    for ( VStreamItem *streamItem in self.stream.marqueeItems )
    {
        id previewImageURL = [NSNull null];
        NSArray *previewImagePaths = streamItem.previewImagePaths;
        if ( previewImagePaths.count > 0 )
        {
            NSURL *imageURL = [NSURL URLWithString:[previewImagePaths firstObject]];
            if ( ![imageURL.absoluteString isEqualToString:@""] )
            {
                previewImageURL = imageURL;
            }
        }
        
        [self loadImageAndUpdateSubviewsForURL:previewImageURL atIndex:[self.stream.marqueeItems indexOfObject:streamItem]];
        [previewImages addObject:previewImageURL];
        [contentNames addObject:streamItem.name];
    }
    
    [self.crossfadingLabel setupWithStrings:contentNames andTextAttributes:[self labelTextAttributes]];
}

- (void)loadImageAndUpdateSubviewsForURL:(NSURL *)imageURL atIndex:(NSUInteger)index
{
    __weak VBlurredMarqueeController *weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                                                          options:SDWebImageRetryFailed
                                                         progress:nil
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         __strong VBlurredMarqueeController *strongSelf = weakSelf;
         if ( strongSelf == nil )
         {
             return;
         }
         
         BOOL backgroundShouldAnimate = !self.showedInitialDisplayAnimation && index == 0; //Animate if we're doing the initial display animation
         
         /*
          No need to animate the streamItemCell if the image failed to load, image loaded from cache, or we're doing the
            initial display animation (where the image starts offscreen)
          */
         BOOL streamItemCellShouldAnimate = image != nil && cacheType == SDImageCacheTypeNone && self.showedInitialDisplayAnimation;

         //Populate visible subviews with the newly loaded image
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
         NSUInteger cellIndex = [[strongSelf.collectionView indexPathsForVisibleItems] indexOfObject:indexPath];
         if ( cellIndex != NSNotFound )
         {
             //The streamItemCell we need to update is already on screen, update it with animation (if it's a new image)
             VBlurredMarqueeStreamItemCell *streamItemCell = (VBlurredMarqueeStreamItemCell *)strongSelf.collectionView.visibleCells[cellIndex];
             [streamItemCell updateToImage:image animated:streamItemCellShouldAnimate];
             backgroundShouldAnimate = YES; //Animate if we're the we're also animating the streamItemCell in front of it
         }
         
         [strongSelf.crossfadingBlurredImageView updateBlurredImageViewForImage:image fromURL:imageURL withTintColor:[strongSelf tintColorForCrossFadingBlurredImageView] atIndex:index animated:backgroundShouldAnimate];
         if ( image != nil )
         {
             strongSelf.loadedImages[indexPath] = image;
         }
         
         if ( !strongSelf.showedInitialDisplayAnimation && index == 0 )
         {
             self.firstImageLoaded = YES;
             [self attemptToPerformInitialDisplayAnimation];
         }
     }];
}

- (void)attemptToPerformInitialDisplayAnimation
{
    if ( !self.showedInitialDisplayAnimation && self.firstImageLoaded && self.backgroundCellIsVisible )
    {
        self.showedInitialDisplayAnimation = YES;
        
        //The first image has loaded and we haven't yet performed the
        self.crossfadingLabel.alpha = 0.0f;
        
        [self.collectionView layoutIfNeeded];
        
        CGPoint startOffset = CGPointMake( - CGRectGetWidth(self.collectionView.bounds), 0.0f );
        [self.collectionView setContentOffset:startOffset animated:NO];
        [self selectNextTab];
    }
}

- (BOOL)stringIsValidForURL:(NSString *)stringForURL
{
    return stringForURL != nil && ![stringForURL isEqualToString:@""];
}

- (NSDictionary *)labelTextAttributes
{
    if ( self.dependencyManager == nil )
    {
        return nil;
    }
    
    return @{
             NSFontAttributeName : [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey],
             NSForegroundColorAttributeName : [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]
             };
}


- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    self.crossfadingLabel.textAttributes = [self labelTextAttributes];
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
            self.crossfadingLabel.opaqueOutsideArrayRange = YES;
        }
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    CGPoint point = scrollView.contentOffset;
    CGFloat newOffset = point.x / CGRectGetWidth(self.collectionView.bounds);
    self.crossfadingBlurredImageView.offset = newOffset;
    self.crossfadingLabel.offset = newOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.shouldAnimateToTarget = NO;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VBlurredMarqueeCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    VBlurredMarqueeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]
                                                                                        forIndexPath:indexPath];
    cell.dependencyManager = self.dependencyManager;
    cell.marquee = self;
    self.collectionView.hidden = !self.showedInitialDisplayAnimation;
    CGSize desiredSize = [VBlurredMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
    cell.bounds = CGRectMake(0, 0, desiredSize.width, desiredSize.height);
        
    [self enableTimer];
    [cell layoutIfNeeded];
    if ( !self.showedInitialDisplayAnimation )
    {
        [self refreshCellSubviews];
    }
    return cell;
}

- (UIColor *)tintColorForCrossFadingBlurredImageView
{
    return [[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] colorWithAlphaComponent:0.4f];
}

- (UIImage *)loadedImageAtIndex:(NSUInteger)index
{
    if ( index >= self.loadedImages.count )
    {
        return nil;
    }
    return self.loadedImages[[NSIndexPath indexPathForRow:index inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    VBlurredMarqueeStreamItemCell *streamItemCell = (VBlurredMarqueeStreamItemCell *)cell;
    [streamItemCell updateToImage:[self loadedImageAtIndex:indexPath.row] animated:NO]; //No need to animate as this will be set while cell if off-screen
}

@end
