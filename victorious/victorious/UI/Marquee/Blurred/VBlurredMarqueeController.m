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
#import "VCrossFadingMarqueeLabel.h"
#import "VCrossFadingImageView.h"
#import "VTimerManager.h"
#import "VStreamItem+Fetcher.h"
#import "UIImage+ImageCreation.h"
#import "VDependencyManager.h"
#import "UIImageView+Blurring.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import "VStreamItemPreviewView.h"
#import "UIView+VViewRendering.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VStream.h"

static const CGFloat kVisibilityDuration = 5.0f;
static const CGFloat kOffsetOvershoot = 20.0f;

@interface VBlurredMarqueeController ()

@property (nonatomic, assign) CGPoint overshootTarget;
@property (nonatomic, assign) CGPoint offsetTarget;
@property (nonatomic, assign) BOOL shouldAnimateToTarget;
@property (nonatomic, assign) BOOL showedInitialDisplayAnimation;
@property (nonatomic, assign) BOOL firstImageLoaded;
@property (nonatomic, assign) BOOL backgroundCellIsVisible;
@property (nonatomic, strong) NSMutableArray *loadingPreviewViews;

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

- (void)animateToVisible
{
    self.backgroundCellIsVisible = YES;
    [self attemptToPerformInitialDisplayAnimation];
}

- (void)selectNextTab
{
    if ( self.marqueeItems.count == 1 && CGPointEqualToPoint(CGPointZero, self.collectionView.contentOffset) )
    {
        //We've locked the scrolling and are already scrolled to
        //an appropriate spot, don't animate more.
        return;
    }
    
    NSUInteger currentPage = ( self.collectionView.contentOffset.x / self.pageWidth ) + 1;
    CGFloat overshootAmount = kOffsetOvershoot;
    if (currentPage == self.marqueeItems.count)
    {
        currentPage = 0;
        overshootAmount = - overshootAmount;
    }
    
    CGPoint point = CGPointMake(self.pageWidth * currentPage + overshootAmount, self.collectionView.contentOffset.y);
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
    if ( self.marqueeItems.count == 0 || self.crossfadingBlurredImageView == nil || self.crossfadingLabel == nil )
    {
        return;
    }
    
    if ( self.loadingPreviewViews == nil )
    {
        self.loadingPreviewViews = [[NSMutableArray alloc] init];
    }
    
    NSArray *marqueeItems = self.marqueeItems;
    NSInteger marqueeItemsCount = marqueeItems.count;
    if ( self.crossfadingBlurredImageView.imageViewCount != marqueeItemsCount )
    {
        [self.crossfadingBlurredImageView setupWithNumberOfImageViews:marqueeItemsCount];
    }
    
    self.firstImageLoaded = NO;
    
    for ( VStreamItem *streamItem in marqueeItems )
    {
        [self loadContentForStreamItem:streamItem andUpdateSubviewsAtIndex:[marqueeItems indexOfObject:streamItem]];
    }
    
    [self.crossfadingLabel setupWithMarqueeItems:marqueeItems fromStreamWithApiPath:self.currentStream.apiPath];
    self.crossfadingLabel.hidden = !self.showedInitialDisplayAnimation;
    
    //Set the content offset to a safe value
    CGFloat maxOffset = (marqueeItemsCount - 1) * CGRectGetWidth(self.collectionView.bounds);
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.x = MIN(maxOffset, contentOffset.x);
    self.collectionView.contentOffset = contentOffset;
    
    //Update the label and background image for the new content offset
    [self updateFadingViews];
}

- (void)loadContentForStreamItem:(VStreamItem *)streamItem andUpdateSubviewsAtIndex:(NSUInteger)index
{
    VStreamItemPreviewView *previewView = [VStreamItemPreviewView streamItemPreviewViewWithStreamItem:streamItem];
    
    __weak VBlurredMarqueeController *weakSelf = self;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    previewView.displayReadyBlock = ^(VStreamItemPreviewView *loadedPreviewView)
    {
        __strong VBlurredMarqueeController *strongSelf = weakSelf;
        if ( strongSelf == nil )
        {
            return;
        }
        
        loadedPreviewView.displayReadyBlock = nil;
        
        BOOL backgroundShouldAnimate = !strongSelf.showedInitialDisplayAnimation && index == 0; //Animate if we're doing the initial display animation
        
        //Populate visible subviews with the newly loaded image
        NSUInteger cellIndex = [[strongSelf.collectionView indexPathsForVisibleItems] indexOfObject:indexPath];
        loadedPreviewView.frame = [VBlurredMarqueeStreamItemCell frameForPreviewViewInCellWithBounds:strongSelf.collectionView.bounds];
        if ( cellIndex != NSNotFound )
        {
            //The streamItemCell we need to update is already on screen, update it with animation (if it's a new image)
            VBlurredMarqueeStreamItemCell *streamItemCell = (VBlurredMarqueeStreamItemCell *)strongSelf.collectionView.visibleCells[cellIndex];
            [streamItemCell updateToPreviewView:loadedPreviewView];
            backgroundShouldAnimate = YES; //Animate if we're the we're also animating the streamItemCell in front of it
        }
        
        [strongSelf renderPreviewView:loadedPreviewView atIndex:indexPath.row animated:backgroundShouldAnimate];
        [strongSelf.loadingPreviewViews removeObject:loadedPreviewView];
    };
    
    [self.loadingPreviewViews addObject:previewView];
    [previewView setDependencyManager:self.dependencyManager];
    [previewView updateToStreamItem:streamItem];
}

- (void)attemptToPerformInitialDisplayAnimation
{
    if ( !self.showedInitialDisplayAnimation && self.firstImageLoaded && self.backgroundCellIsVisible )
    {
        self.crossfadingLabel.clampsOffset = NO;
        self.showedInitialDisplayAnimation = YES;
                
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ( self.collectionView.hidden )
            {
                self.collectionView.hidden = NO;
            }
            
            self.crossfadingLabel.hidden = NO;
            [self.collectionView layoutIfNeeded];
            CGPoint startOffset = CGPointMake( - CGRectGetWidth(self.collectionView.bounds), 0.0f );
            [self.collectionView setContentOffset:startOffset animated:NO];
            [self selectNextTab];
        });
    }
}

- (BOOL)stringIsValidForURL:(NSString *)stringForURL
{
    return stringForURL != nil && ![stringForURL isEqualToString:@""];
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
            self.crossfadingLabel.clampsOffset = YES;
        }
    }
    
    [self updateFadingViews];
}

- (void)updateFadingViews
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    CGPoint point = self.collectionView.contentOffset;
    CGFloat newOffset = point.x / CGRectGetWidth(self.collectionView.bounds);
    self.crossfadingBlurredImageView.offset = newOffset;
    self.crossfadingLabel.offset = newOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.shouldAnimateToTarget = NO;
}

- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[[VBlurredMarqueeCollectionViewCell class] nibForCell] forCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    VBlurredMarqueeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VBlurredMarqueeCollectionViewCell suggestedReuseIdentifier]
                                                                                        forIndexPath:indexPath];
    if ( cell.marquee != self )
    {
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
    }
    
    return cell;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    [super setCollectionView:collectionView];
    collectionView.alwaysBounceHorizontal = YES;
}

- (void)setCrossfadingLabel:(VCrossFadingMarqueeLabel *)crossfadingLabel
{
    _crossfadingLabel = crossfadingLabel;
    crossfadingLabel.dependencyManager = self.dependencyManager;
}

- (UIColor *)tintColorForCrossFadingBlurredImageView
{
    return [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
}

- (void)renderPreviewView:(VStreamItemPreviewView *)previewView atIndex:(NSUInteger)index animated:(BOOL)animated
{
    [previewView layoutIfNeeded];
    [previewView v_renderViewWithCompletion:^(UIImage *image)
    {
        void (^animations)() = nil;
        if ( !self.showedInitialDisplayAnimation && index == 0 )
        {
            self.firstImageLoaded = YES;
            animations = ^void
            {
                [self attemptToPerformInitialDisplayAnimation];
            };
        }
        [self.crossfadingBlurredImageView updateBlurredImageViewForImage:image fromPreviewView:previewView withTintColor:[self tintColorForCrossFadingBlurredImageView] atIndex:index animated:animated withConcurrentAnimations:animations];
    }];
}

+ (Class)marqueeStreamItemCellClass
{
    return [VBlurredMarqueeStreamItemCell class];
}

@end
