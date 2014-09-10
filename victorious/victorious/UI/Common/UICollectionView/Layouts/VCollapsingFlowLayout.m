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
    
    UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    
//    NSLog(@"current content offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
    
    __block BOOL layoutAttributesForContentView = NO;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        if (self.collectionView.contentOffset.y < self.catchPoint)
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForConetntViewState:VContentViewStateFullSize
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
                [self layoutAttributesForConetntViewState:VContentViewStateShrinking
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
        [attributes addObject:[self layoutAttributesForConetntViewState:VContentViewStateFloating
                                            withInitialLayoutAttributes:nil]];
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
    {
        return [self layoutAttributesForConetntViewState:VContentViewStateFloating
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForConetntViewState:(VContentViewState)contentViewState
                                              withInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes;
    if (!initialLayoutAttributes)
    {
        NSIndexPath *contentViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:contentViewIndexPath];
        layoutAttributes.center = CGPointMake(160.0f, 160.0f);
        layoutAttributes.size = CGSizeMake(320.0f, 320.0f);
    }
    
    switch (contentViewState) {
        case VContentViewStateFullSize:
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, 320, 320);
            break;
        case VContentViewStateShrinking:
        case VContentViewStateFloating:
        {
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / 320.0f);
            
            layoutAttributes.zIndex = 1000;
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, 320.0f, 320.0f);

            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(fmaxf(1.0f - percentCompleted, 0.21f), fmaxf(1.0f - percentCompleted, 0.21f));
            CGFloat xTranslation = fminf(100.0f, 100.0f * percentCompleted);
            CGFloat yTranslation = fmaxf(-60.0f, -60.0f * percentCompleted);
            
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
