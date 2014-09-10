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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [self layoutAttributesForItemAtIndexPath:[self realTimeCommentsIndexPath]];
    self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    
    __block BOOL layoutAttributesForContentView = NO;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        if (self.collectionView.contentOffset.y < self.catchPoint)
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForContentViewState:VContentViewStateFullSize
                              withInitialLayoutAttributes:layoutAttributes];
                layoutAttributesForContentView = YES;
            }
            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
            {
                layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y + 320, 320, 110);
            }
        }
        else
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForContentViewState:VContentViewStateShrinking
                              withInitialLayoutAttributes:layoutAttributes];
                layoutAttributesForContentView = YES;
            }
            else if ([layoutAttributes.indexPath compare:[self realTimeCommentsIndexPath]] == NSOrderedSame)
            {
                layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y + 320.0f, 320, 110);
            }
            else
            {
                
            }
        }
    }];
    
    if (!layoutAttributesForContentView)
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
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / CGRectGetWidth(self.collectionView.bounds));
            
            layoutAttributes.zIndex = kVContentViewFloatingZIndex;
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetWidth(self.collectionView.bounds));

            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fmaxf(1.0f - percentCompleted, kVContentViewFloatingScalingFactor), fmaxf(1.0f - percentCompleted, kVContentViewFloatingScalingFactor));
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
