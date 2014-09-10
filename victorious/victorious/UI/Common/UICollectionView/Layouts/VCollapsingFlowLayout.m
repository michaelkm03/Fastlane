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

@end

@implementation VCollapsingFlowLayout

#pragma mark - UICollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

static const CGFloat kVContentViewLayoutContentZIndex = 999.0f;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [self layoutAttributesForItemAtIndexPath:[self realTimeCommentsIndexPath]];
    
    self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    
    UICollectionViewLayoutAttributes *layoutAttributesForContentView = [self layoutAttributesForContentViewState:VContentViewStateFullSize
                                                                                     withInitialLayoutAttributes:nil];
    
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
                                                    self.collectionView.contentOffset.y + CGRectGetHeight(layoutAttributesForContentView.frame),
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
                    UICollectionViewLayoutAttributes *layoutAttributesForContentView = [self layoutAttributesForContentViewState:VContentViewStateFullSize
                                                                                                     withInitialLayoutAttributes:nil];
                    
                    layoutAttributes.frame = CGRectMake(CGRectGetMinX(layoutAttributes.frame),
                                                        self.collectionView.contentOffset.y + CGRectGetHeight(layoutAttributesForContentView.frame),
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
                                                          fmaxf(self.catchPoint, (1 - percentCompleted) * (1 + CGRectGetHeight(layoutAttributesForContentView.frame))));
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]])
    {

    }
    return [super layoutAttributesForSupplementaryViewOfKind:kind
                                                 atIndexPath:indexPath];
}

#pragma mark - Convenience

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

static const CGFloat kVContentViewFloatingZIndex = 1000.0f;
static const CGFloat kVContentViewFloatingYTranslation = 120.0f;
static const CGFloat kVContentViewFloatingXTranslation = -90.0f;
static const CGFloat kVContentViewFloatingScalingFactor = 0.21f;

- (UICollectionViewLayoutAttributes *)layoutAttributesForContentViewState:(VContentViewState)contentViewState
                                              withInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes;
    if (!initialLayoutAttributes)
    {
        NSIndexPath *contentViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:contentViewIndexPath];
        layoutAttributes.center = CGPointMake(CGRectGetWidth(self.collectionView.bounds)/2, CGRectGetWidth(self.collectionView.bounds)/2);
        layoutAttributes.size = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetWidth(self.collectionView.bounds));
    }
    
    switch (contentViewState) {
        case VContentViewStateFullSize:
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetWidth(self.collectionView.bounds));
            break;
        case VContentViewStateShrinking:
        case VContentViewStateFloating:
        {
            NSLog(@"Content Offset%@", NSStringFromCGPoint(self.collectionView.contentOffset));
            
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / (320 - 110));
            
            NSLog(@"%f", percentCompleted);
            
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
