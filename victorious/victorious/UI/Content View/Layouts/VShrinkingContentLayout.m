//
//  VShrinkingContentLayout.m
//  victorious
//
//  Created by Michael Sena on 9/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VShrinkingContentLayout.h"

NSString *const VShrinkingContentLayoutContentBackgroundView = @"com.victorious.VShrinkingContentLayoutContentBackgroundView";
NSString *const VShrinkingContentLayoutAllCommentsHandle = @"com.victorious.VShrinkingContentLayoutContentBackgroundView";

static const NSInteger kContentLayoutZIndex = 9999;
static const NSInteger kContentBackgroundZIndex = kContentLayoutZIndex - 1;
static const NSInteger kAllCommentsZIndex = 6666;

@interface VShrinkingContentLayout ()

@property (nonatomic, assign) CGSize mediaContentSize;
@property (nonatomic, assign) CGSize histogramSize;
@property (nonatomic, assign) CGSize allCommentsHandleSize;
@property (nonatomic, assign) CGSize experienceEnhancerSize;

@end

@implementation VShrinkingContentLayout

#pragma mark - UICollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
    
    [self reloadMajorItemSizes];
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // We'll be adding attributes here
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    NSArray *inheritedAttributes = [super layoutAttributesForElementsInRect:rect];

    [inheritedAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
     {
         if (layoutAttributes.indexPath.section != VContentViewSectionAllComments)
         {
             return;
         }
         layoutAttributes.zIndex = kAllCommentsZIndex;
         [attributes addObject:layoutAttributes];
     }];
    [attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:VContentViewSectionContent]]];
    [attributes addObject:[self layoutAttributesForDecorationViewOfKind:VShrinkingContentLayoutContentBackgroundView
                                                            atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    
    
    if ([self.collectionView numberOfItemsInSection:VContentViewSectionHistogramOrQuestion] > 0)
    {
        UICollectionViewLayoutAttributes *histogramOrQuestionLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionHistogramOrQuestion]];
        histogramOrQuestionLayoutAttributes.zIndex = 0;
        [attributes addObject:histogramOrQuestionLayoutAttributes];
    }
    
    if ([self.collectionView numberOfItemsInSection:VContentViewSectionExperienceEnhancers] > 0)
    {
        UICollectionViewLayoutAttributes *experienceEnhancerLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:VContentViewSectionExperienceEnhancers]];
        experienceEnhancerLayoutAttributes.zIndex = 0;
        [attributes addObject:experienceEnhancerLayoutAttributes];
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributesForIndexPath = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    switch (indexPath.section)
    {
        case VContentViewSectionContent:
            layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                            self.collectionView.contentOffset.y,
                                                            self.mediaContentSize.width,
                                                            self.mediaContentSize.height);
            layoutAttributesForIndexPath.zIndex = kContentLayoutZIndex;
            
            if (self.collectionView.contentOffset.y > [self catchPoint].y)
            {
                CGFloat deltaCatchToLock = [self lockPoint].y - [self catchPoint].y;
                CGFloat percentToLockPoint = fminf(1.0f, (self.collectionView.contentOffset.y - [self catchPoint].y) / deltaCatchToLock);
                
                CGFloat sizeDelta = self.mediaContentSize.height - VShrinkingContentLayoutMinimumContentHeight;
                CGFloat transformScaleCoefficient = ((self.mediaContentSize.height - (sizeDelta * percentToLockPoint)) / self.mediaContentSize.height);
                
                CGRect rect = self.collectionView.bounds;
                rect.size.height = self.mediaContentSize.height * transformScaleCoefficient;
                layoutAttributesForIndexPath.frame = rect;
            }
            break;
        case VContentViewSectionHistogramOrQuestion:
            layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                            self.collectionView.contentOffset.y + self.mediaContentSize.height,
                                                            CGRectGetWidth(self.collectionView.bounds),
                                                            self.histogramSize.height);
            break;
        case VContentViewSectionExperienceEnhancers:
            layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                            self.collectionView.contentOffset.y + self.mediaContentSize.height + self.histogramSize.height,
                                                            CGRectGetWidth(self.collectionView.bounds),
                                                            self.experienceEnhancerSize.height);
            break;
        case VContentViewSectionAllComments:
            return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
    
    return layoutAttributesForIndexPath;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributesForSupplementaryView = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind
                                                                                                                                            withIndexPath:indexPath];
    switch (indexPath.section)
    {
        case VContentViewSectionContent:
        {
            UICollectionViewLayoutAttributes *contentAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
            layoutAttributesForSupplementaryView.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                                    self.collectionView.contentOffset.y,
                                                                    CGRectGetWidth(self.collectionView.bounds),
                                                                    CGRectGetHeight(contentAttributes.frame));
            layoutAttributesForSupplementaryView.zIndex = kContentBackgroundZIndex;
        }
            
            
            break;
        case VContentViewSectionHistogramOrQuestion:
            break;
        case VContentViewSectionExperienceEnhancers:
            break;
        case VContentViewSectionAllComments:
            break;
    }
    
    return [super layoutAttributesForSupplementaryViewOfKind:kind
                                                 atIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind
                                                                  atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:VShrinkingContentLayoutContentBackgroundView])
    {
        UICollectionViewLayoutAttributes *contentAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
        
        UICollectionViewLayoutAttributes *layoutAttributesForDecoration = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind
                                                                                                                                      withIndexPath:indexPath];
        layoutAttributesForDecoration.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                                self.collectionView.contentOffset.y,
                                                                CGRectGetWidth(self.collectionView.bounds),
                                                                CGRectGetHeight(contentAttributes.frame));
        layoutAttributesForDecoration.zIndex = kContentBackgroundZIndex;
        return layoutAttributesForDecoration;
    }
    return [super layoutAttributesForDecorationViewOfKind:elementKind
                                              atIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity
{
    CGPoint desiredContentOffset = proposedContentOffset;
    
    __block void (^delayedContentOffsetBlock)(void);
    
    // If we are fully scrolled we want to show the bottom.
    if ((self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.frame) - proposedContentOffset.y + self.collectionView.contentInset.bottom) == 0)
    {
        return proposedContentOffset;
    }
    
    if ((proposedContentOffset.y > 0) && (proposedContentOffset.y < [self catchPoint].y))
    {
        if (proposedContentOffset.y > ([self catchPoint].y * 0.45))
        {
            desiredContentOffset = [self catchPoint];
        }
        else
        {
            desiredContentOffset = CGPointZero;
        }
    }
    else if ((proposedContentOffset.y >= [self catchPoint].y) && (proposedContentOffset.y < [self lockPoint].y))
    {
        CGFloat catchToLockDelta = [self lockPoint].y - [self catchPoint].y;
        CGFloat offsetToCatchDelta = proposedContentOffset.y - [self catchPoint].y;
        CGFloat percentCloseToLock = offsetToCatchDelta / catchToLockDelta;
        if (percentCloseToLock < 0.5)
        {
            desiredContentOffset = [self catchPoint];
        }
        else
        {
            desiredContentOffset = [self lockPoint];
        }
    }
    
    if (((desiredContentOffset.y < proposedContentOffset.y) && (velocity.y > 0.0f)) ||
        ((desiredContentOffset.y > proposedContentOffset.y) && (velocity.y < 0.0f)))
    {
        delayedContentOffsetBlock = ^void(void)
        {
            [self.collectionView setContentOffset:desiredContentOffset
                                         animated:YES];
        };
        desiredContentOffset = proposedContentOffset;
    }

    if (delayedContentOffsetBlock)
    {
        // This is done to prevent cases where merely setting targetContentOffset lead to jumpy scrolling
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            delayedContentOffsetBlock();
        });
    }
    
    return desiredContentOffset;
}

#pragma mark - Convenience

- (void)reloadMajorItemSizes
{
    // Get sizes for major items
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    
    self.mediaContentSize = [layoutDelegate collectionView:self.collectionView
                                                    layout:self
                                    sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
    
    if ([self.collectionView numberOfItemsInSection:VContentViewSectionHistogramOrQuestion])
    {
        self.histogramSize = [layoutDelegate collectionView:self.collectionView
                                                     layout:self
                                     sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionHistogramOrQuestion]];
    }
    if ([self.collectionView numberOfItemsInSection:VContentViewSectionExperienceEnhancers])
    {
        self.experienceEnhancerSize = [layoutDelegate collectionView:self.collectionView
                                                              layout:self
                                              sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionExperienceEnhancers]];
    }
    if ([self.collectionView numberOfItemsInSection:VContentViewSectionAllComments])
    {
        self.allCommentsHandleSize = [layoutDelegate collectionView:self.collectionView
                                                             layout:self
                                    referenceSizeForHeaderInSection:VContentViewSectionAllComments];
    }
}

- (CGPoint)catchPoint
{
    UICollectionViewLayoutAttributes *handleLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                    atIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionAllComments]];
    
    return CGPointMake(CGRectGetMinX(self.collectionView.bounds), CGRectGetMinY(handleLayoutAttributes.frame) - self.mediaContentSize.height);
}

- (CGPoint)lockPoint
{
    CGPoint lockPoint = [self catchPoint];
    lockPoint.y = lockPoint.y + fabsf(VShrinkingContentLayoutMinimumContentHeight - self.mediaContentSize.height);
    
    return lockPoint;
}

@end
