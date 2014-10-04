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

static const CGFloat kContentLayoutZIndex = 9999.0f;
static const CGFloat kContentBackgroundZIndex = kContentLayoutZIndex - 1.0f;
static const CGFloat kAllCommentsZIndex = 6666.0f;

@interface VShrinkingContentLayout ()

@property (nonatomic, assign) CGSize cachedContentSize;

@property (nonatomic, assign) CGSize mediaContentSize;
@property (nonatomic, assign) CGSize histogramSize;
@property (nonatomic, assign) CGSize tickerSize;
@property (nonatomic, assign) CGSize allCommentsHandleSize;

@property (nonatomic, strong) NSMutableDictionary *cachedComentSizes;

@end

@implementation VShrinkingContentLayout

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _cachedComentSizes = [[NSMutableDictionary alloc] init];
}

#pragma mark - UICollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (![self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)])
    {
        return;
    }
    
    [self reloadMajorItemSizes];
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    
    if (context.invalidateDataSourceCounts)
    {
        self.cachedContentSize = CGSizeZero;
        [self.cachedComentSizes removeAllObjects];
    }
}

- (void)invalidateLayout
{
    [super invalidateLayout];
    [self reloadMajorItemSizes];
}


- (CGSize)collectionViewContentSize
{
    if (!CGSizeEqualToSize(self.cachedContentSize, CGSizeZero))
    {
        return self.cachedContentSize;
    }
    
    NSInteger numberOfComments = [self.collectionView numberOfItemsInSection:VContentViewSectionAllComments];
    CGFloat allCommentsHeight = 0.0f;
    for (NSInteger commentIndex = 0; commentIndex < numberOfComments; commentIndex++)
    {
        NSIndexPath *indexPathForCommentIndex = [NSIndexPath indexPathForRow:commentIndex
                                                                   inSection:VContentViewSectionAllComments];
        UICollectionViewLayoutAttributes *layoutAttributesForComentAtIndex = [self layoutAttributesForItemAtIndexPath:indexPathForCommentIndex];
        allCommentsHeight = allCommentsHeight + CGRectGetHeight(layoutAttributesForComentAtIndex.frame);
    }
    
    self.cachedContentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds) + self.contentInsets.bottom + allCommentsHeight);
    return self.cachedContentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // We'll be adding attributes here
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    UICollectionViewLayoutAttributes *contentLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
    [attributes addObject:contentLayoutAttributes];
    
    if (self.collectionView.contentOffset.y > [self catchPoint].y)
    {
        UICollectionViewLayoutAttributes *contentBackgroundAttributes = [self layoutAttributesForSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                                                                                                             atIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
        [attributes addObject:contentBackgroundAttributes];
    }
    
    UICollectionViewLayoutAttributes *histogramLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionHistogram]];
    [attributes addObject:histogramLayoutAttributes];
    
    UICollectionViewLayoutAttributes *tickerLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionTicker]];
    [attributes addObject:tickerLayoutAttributes];
    
    NSInteger numberOfComments = [self.collectionView numberOfItemsInSection:VContentViewSectionAllComments];
    if (numberOfComments > 0)
    {
        UICollectionViewLayoutAttributes *handleLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                                                                                                        atIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionAllComments]];
        handleLayoutAttributes.zIndex = kAllCommentsZIndex;
        [attributes addObject:handleLayoutAttributes];
        
        for (NSInteger commentIndex = 0; commentIndex < numberOfComments; commentIndex++)
        {
            UICollectionViewLayoutAttributes *commentLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:commentIndex
                                                                                                                                    inSection:VContentViewSectionAllComments]];
            if (CGRectGetMaxY(self.collectionView.bounds) < CGRectGetMinY(commentLayoutAttributes.frame))
            {
                break;
            }

            commentLayoutAttributes.zIndex = kAllCommentsZIndex;
            [attributes addObject:commentLayoutAttributes];
        }
    }
    
    return  [NSArray arrayWithArray:attributes];
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
                
                CGAffineTransform scaleTransform = CGAffineTransformMakeScale(transformScaleCoefficient, transformScaleCoefficient);
                
                CGFloat translationDelta = ((self.mediaContentSize.height * 0.5f) - (VShrinkingContentLayoutMinimumContentHeight * 0.5f));
                CGFloat translationCoefficient = -translationDelta * percentToLockPoint;
                
                CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0, translationCoefficient);
                
                layoutAttributesForIndexPath.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
            }
            
            break;
        case VContentViewSectionHistogram:
            layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                            self.collectionView.contentOffset.y + self.mediaContentSize.height,
                                                            CGRectGetWidth(self.collectionView.bounds),
                                                            self.histogramSize.height);
            break;
        case VContentViewSectionTicker:
            layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                            self.collectionView.contentOffset.y + self.mediaContentSize.height + self.histogramSize.height,
                                                            CGRectGetWidth(self.collectionView.bounds),
                                                            self.tickerSize.height);
            break;
        case VContentViewSectionAllComments:
        {
            if (indexPath.row == 0)
            {
                layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                                CGRectGetHeight(self.collectionView.bounds) - self.allCommentsHandleBottomInset + self.allCommentsHandleSize.height - self.collectionView.contentInset.bottom,
                                                                CGRectGetWidth(self.collectionView.bounds),
                                                                [self sizeForCommentIndexPath:indexPath].height);
            }
            else
            {
                NSIndexPath *indexPathForPreviousComment = [NSIndexPath indexPathForRow:indexPath.row-1
                                                                              inSection:indexPath.section];
                UICollectionViewLayoutAttributes *previousCommentLayoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPathForPreviousComment];
                
                layoutAttributesForIndexPath.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                                CGRectGetMaxY(previousCommentLayoutAttributes.frame),
                                                                CGRectGetWidth(self.collectionView.bounds),
                                                                [self sizeForCommentIndexPath:indexPath].height);
            }
        }
            break;
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
        case VContentViewSectionHistogram:
            break;
        case VContentViewSectionTicker:
            break;
        case VContentViewSectionAllComments:
            layoutAttributesForSupplementaryView.frame = CGRectMake(CGRectGetMinX(self.collectionView.bounds),
                                                                    CGRectGetHeight(self.collectionView.bounds) - self.allCommentsHandleBottomInset - self.collectionView.contentInset.bottom,
                                                                    CGRectGetWidth(self.collectionView.bounds),
                                                                    self.allCommentsHandleSize.height);
            break;
    }
    
    return layoutAttributesForSupplementaryView;
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

#pragma mark - Property Accessors

- (CGFloat)percentToShowBottomBar
{
    CGFloat catchToLockDelta = [self lockPoint].y - [self catchPoint].y;
    CGFloat offsetToCatchDelta = self.collectionView.contentOffset.y - [self catchPoint].y;
    return fmaxf(fminf(offsetToCatchDelta / catchToLockDelta, 1.0f), 0.0f);
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    self.cachedContentSize = CGSizeZero;
}

#pragma mark - Convenience

- (void)reloadMajorItemSizes
{
    // Get sizes for major items
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    
    self.mediaContentSize = [layoutDelegate collectionView:self.collectionView
                                                    layout:self
                                    sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionContent]];
    self.histogramSize = [layoutDelegate collectionView:self.collectionView
                                                 layout:self
                                 sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionHistogram]];
    self.tickerSize = [layoutDelegate collectionView:self.collectionView
                                              layout:self
                              sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:VContentViewSectionTicker]];
    self.allCommentsHandleSize = [layoutDelegate collectionView:self.collectionView
                                                         layout:self
                                referenceSizeForHeaderInSection:VContentViewSectionAllComments];
    
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
    lockPoint.y = lockPoint.y + VShrinkingContentLayoutMinimumContentHeight + self.histogramSize.height + self.tickerSize.height;
    return lockPoint;
}

- (CGSize)sizeForCommentIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForComment;
    if ([self.cachedComentSizes objectForKey:indexPath])
    {
        sizeForComment = [[self.cachedComentSizes objectForKey:indexPath] CGSizeValue];
    }
    else
    {
        id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        sizeForComment = [layoutDelegate collectionView:self.collectionView
                                                 layout:self
                                 sizeForItemAtIndexPath:indexPath];
        [self.cachedComentSizes setObject:[NSValue valueWithCGSize:sizeForComment]
                                   forKey:indexPath];
    }
    return sizeForComment;
}

@end
