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

static const CGFloat kVisibilityDuration = 5.0f;
static const CGFloat kOffsetOvershoot = 20.0f;

@interface VBlurredMarqueeController ()

@property (nonatomic, assign) CGPoint overshootTarget;
@property (nonatomic, assign) CGPoint offsetTarget;
@property (nonatomic, assign) BOOL shouldAnimateToTarget;
@property (nonatomic, assign) BOOL showedInitialDisplayAnimation;

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
    if ( self.collectionView.hidden )
    {
        self.collectionView.hidden = NO;
        [self selectNextTab];
    }
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
    NSMutableOrderedSet *validStreamItems = [[NSMutableOrderedSet alloc] initWithArray:[self.stream.marqueeItems array]];
    
    for ( VStreamItem *streamItem in self.stream.marqueeItems )
    {
        NSArray *previewImagePaths = streamItem.previewImagePaths;
        if ( previewImagePaths.count > 0 )
        {
            NSURL *previewImageURL = [NSURL URLWithString:[previewImagePaths firstObject]];
            if ( ![previewImageURL.absoluteString isEqualToString:@""] )
            {
                [previewImages addObject:previewImageURL];
                [contentNames addObject:streamItem.name];
                continue; //Continue to avoid removing the streamItem from the validStreamItems
            }
        }
        
        //If we reach this part of the loop, we don't have a valid previewImageURL, so this streamItem is invalid for display; remove it from the validStreamItems array
        [validStreamItems removeObject:streamItem];
    }
    if ( ![validStreamItems isEqualToOrderedSet:self.stream.marqueeItems] )
    {
        self.stream.marqueeItems = [validStreamItems copy];
    }
    
    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    [self.crossfadingBlurredImageView setupWithImageURLs:[NSArray arrayWithArray:previewImages] tintColor:[linkColor colorWithAlphaComponent:0.4f] andPlaceholderImage:[UIImage resizeableImageWithColor:linkColor]];
    
    [self.crossfadingLabel setupWithStrings:contentNames andTextAttributes:[self labelTextAttributes]];
    
    if ( !self.showedInitialDisplayAnimation )
    {
        self.crossfadingLabel.alpha = 0.0f;
        
        [self.collectionView layoutIfNeeded];
        
        self.showedInitialDisplayAnimation = YES;
        CGPoint startOffset = CGPointMake( - CGRectGetWidth(self.collectionView.bounds), 0.0f );
        [self.collectionView setContentOffset:startOffset animated:NO];
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
    [self refreshCellSubviews];
    return cell;
}

@end
