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

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    __weak VBlurredMarqueeController *weakSelf = self;
    [super refreshWithSuccess:^
     {
         VBlurredMarqueeController *strongSelf = weakSelf;
         
         if ( strongSelf == nil )
         {
             return;
         }
         
         [strongSelf.collectionView.collectionViewLayout invalidateLayout];
         
         NSMutableArray *previewImages = [[NSMutableArray alloc] init];
         NSMutableArray *contentNames = [[NSMutableArray alloc] init];
         for ( VStreamItem *streamItem in strongSelf.stream.streamItems )
         {
             NSArray *previewImagePaths = streamItem.previewImagePaths;
             if ( previewImagePaths.count > 0 )
             {
                 [previewImages addObject:[NSURL URLWithString:[previewImagePaths firstObject]]];
             }
             [contentNames addObject:streamItem.name];
         }
         
         UIColor *linkColor = [strongSelf.dependencyManager colorForKey:VDependencyManagerLinkColorKey];

             [strongSelf.crossfadingBlurredImageView setCrossFadingImageWithURLs:[NSArray arrayWithArray:previewImages] tintColor:[linkColor colorWithAlphaComponent:0.4f] andPlaceholderImage:[UIImage resizeableImageWithColor:linkColor]];
             
             [strongSelf.crossfadingLabel setupWithStrings:contentNames andTextAttributes:[strongSelf labelTextAttributes]];
             
             strongSelf.crossfadingLabel.alpha = 0.0f;
             
             if ( !strongSelf.showedInitialDisplayAnimation )
             {
                 [strongSelf.collectionView layoutIfNeeded];
                 
                 strongSelf.showedInitialDisplayAnimation = YES;
                 CGPoint startOffset = CGPointMake( - CGRectGetWidth(strongSelf.collectionView.bounds), 0.0f );
                 [strongSelf.collectionView setContentOffset:startOffset animated:NO];
                 
                 strongSelf.collectionView.hidden = NO;
                 [strongSelf selectNextTab];
             }
         
         successBlock();
     }
                      failure:failureBlock];
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
