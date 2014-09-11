//
//  VCollapsingFlowLayout.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCollapsingFlowLayout.h"

typedef NS_ENUM(NSInteger, VContentViewState)
{
    VContentViewStateFullSize,
    VContentViewStateShrinking,
    VContentViewStateFloating
};

@interface VCollapsingFlowLayout ()

@property (nonatomic, assign) CGFloat catchPoint;
@property (nonatomic, assign) CGSize sizeForContentView;
@property (nonatomic, assign) CGSize sizeForRealTimeComentsView;

@end

static const CGFloat kVContentViewFloatingZIndex = 1000.0f;
static const CGFloat kVContentViewFloatingYTranslation = 120.0f;
static const CGFloat kVContentViewFloatingXTranslation = -90.0f;
static const CGFloat kVContentViewFloatingScalingFactor = 0.21f;

@implementation VCollapsingFlowLayout

- (id)init
{
    self = [super init];
    if (self)
    {
        self.sizeForContentView = CGSizeZero;
        self.sizeForRealTimeComentsView = CGSizeZero;
        self.catchPoint = 0.0f;
    }
    return self;
}

#pragma mark - UICollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    [self updateInternalStateWithInitalLayoutAttributes:attributes];
    
    __block BOOL hasLayoutAttributesForContentView = NO;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        if (self.collectionView.contentOffset.y < self.catchPoint)
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForContentViewState:VContentViewStateFullSize
                              withInitialLayoutAttributes:layoutAttributes];
                hasLayoutAttributesForContentView = YES;
            }
            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
            {
                layoutAttributes.frame = CGRectMake(CGRectGetMinX(layoutAttributes.frame),
                                                    self.collectionView.contentOffset.y + self.sizeForContentView.height,
                                                    CGRectGetWidth(self.collectionView.frame),
                                                    CGRectGetHeight(layoutAttributes.frame));
            }
        }
        else
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForContentViewState:VContentViewStateShrinking
                              withInitialLayoutAttributes:layoutAttributes];
                hasLayoutAttributesForContentView = YES;
            }
            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
            {
                {
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(layoutAttributes.frame),
                                                        self.collectionView.contentOffset.y + self.sizeForContentView.height,
                                                        CGRectGetWidth(self.collectionView.frame),
                                                        CGRectGetHeight(layoutAttributes.frame));
                }
            }
        }
    }];
    
    if (self.collectionView.contentOffset.y > self.catchPoint)
    {
        
        UICollectionViewLayoutAttributes *dropDownHeaderLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                                          withIndexPath:[self contentViewIndexPath]];
        CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
        CGFloat percentCompleted = (deltaCatchPointToTop / CGRectGetWidth(self.collectionView.bounds));
        dropDownHeaderLayoutAttributes.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                                          self.collectionView.contentOffset.y,
                                                          CGRectGetWidth(self.collectionView.frame),
                                                          // Swap these implementations for header resizing
//                                                          fmaxf(self.catchPoint, (1 - percentCompleted) * (1 + CGRectGetHeight(layoutAttributesForContentView.frame)))
                                                          110.0f);
        dropDownHeaderLayoutAttributes.zIndex = kVContentViewFloatingZIndex;
        [attributes addObject:dropDownHeaderLayoutAttributes];
    }
    
    if (!hasLayoutAttributesForContentView)
    {
        [attributes addObject:[self layoutAttributesForContentViewState:VContentViewStateFloating
                                            withInitialLayoutAttributes:nil]];
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
    {
        return [self layoutAttributesForContentViewState:VContentViewStateFloating
                             withInitialLayoutAttributes:nil];
    }
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

#pragma mark - Convenience

- (void)updateInternalStateWithInitalLayoutAttributes:(NSArray *)initialLayoutAttributes
{
    if (CGSizeEqualToSize(self.sizeForContentView,CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForContentView = [initialLayoutAttributes firstObject];
        self.sizeForContentView = layoutAttributesForContentView.size;
    }
    
    if (CGSizeEqualToSize(self.sizeForRealTimeComentsView, CGSizeZero))
    {
        UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [initialLayoutAttributes objectAtIndex:1];
        self.sizeForRealTimeComentsView = layoutAttributesForRealTimeComments.size;
        self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    }
}

- (VContentViewState)currentContentViewState
{
    if (self.collectionView.contentOffset.y < self.catchPoint)
    {
        return VContentViewStateFullSize;
    }
    else
    {
        return VContentViewStateShrinking;
    }
}

- (NSIndexPath *)contentViewIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath *)realTimeCommentsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForContentViewState:(VContentViewState)contentViewState
                                              withInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes;
    if (!initialLayoutAttributes)
    {
        NSIndexPath *contentViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:contentViewIndexPath];
        layoutAttributes.center = CGPointMake(self.sizeForContentView.width/2, self.sizeForContentView.width/2);
        layoutAttributes.size = self.sizeForContentView;
    }
    
    switch (contentViewState) {
        case VContentViewStateFullSize:
            layoutAttributes.frame = CGRectMake(0,
                                                self.collectionView.contentOffset.y,
                                                self.sizeForContentView.width,
                                                self.sizeForContentView.height);
            break;
        case VContentViewStateShrinking:
        case VContentViewStateFloating:
        {
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / (320 - 110));
            
            layoutAttributes.zIndex = kVContentViewFloatingZIndex;
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetWidth(self.collectionView.bounds));

            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fminf(fmaxf((1.0f + kVContentViewFloatingScalingFactor) - percentCompleted, kVContentViewFloatingScalingFactor), 1.0f),
                                                                          fminf(fmaxf((1.0f + kVContentViewFloatingScalingFactor) - percentCompleted, kVContentViewFloatingScalingFactor), 1.0f));
            
            CGFloat xTranslation = fminf(kVContentViewFloatingYTranslation, kVContentViewFloatingYTranslation * percentCompleted);
            CGFloat yTranslation = fmaxf(kVContentViewFloatingXTranslation, kVContentViewFloatingXTranslation * percentCompleted);
            
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xTranslation,
                                                                                      yTranslation);
            CGAffineTransform combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform);
            
            layoutAttributes.transform = combinedTransform;
        }
            break;
    }
    return layoutAttributes;
}

@end
