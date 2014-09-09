//
//  VCollapsingFlowLayout.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCollapsingFlowLayout.h"

typedef NS_ENUM(NSInteger, kVContentViewState)
{
    kVContentViewStateFullSize,
    kVContentViewStateShrinking,
    kVContentViewStateFloating
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
    
    UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [attributes objectAtIndex:1];
    
    self.catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    
    NSLog(@"current content offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        if (self.collectionView.contentOffset.y < self.catchPoint)
        {
            if ([layoutAttributes.indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
            {
                [self layoutAttributesForConetntViewState:kVContentViewStateFullSize
                              withInitialLayoutAttributes:layoutAttributes];
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
                [self layoutAttributesForConetntViewState:kVContentViewStateShrinking
                              withInitialLayoutAttributes:layoutAttributes];
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
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self contentViewIndexPath]] == NSOrderedSame)
    {
        return [self layoutAttributesForConetntViewState:kVContentViewStateFloating
                             withInitialLayoutAttributes:nil];
    }
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

#pragma mark - Convenience

- (NSIndexPath *)contentViewIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSIndexPath *)realTimeCommentsIndexPath
{
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForConetntViewState:(kVContentViewState)contentViewState
                                              withInitialLayoutAttributes:(UICollectionViewLayoutAttributes *)initialLayoutAttributes
{
    UICollectionViewLayoutAttributes *layoutAttributes = initialLayoutAttributes;
    if (!initialLayoutAttributes)
    {
        NSIndexPath *contentViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:contentViewIndexPath];
        layoutAttributes.center = CGPointMake(160.0f, 160.0f);
    }
    
    switch (contentViewState) {
        case kVContentViewStateFullSize:
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, 320, 320);
            break;
        case kVContentViewStateShrinking:
        case kVContentViewStateFloating:
        {
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - self.catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / 320.0f);
            
            layoutAttributes.zIndex = 1000;
            layoutAttributes.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds) + fminf((percentCompleted* 100.0f), 100.0f), layoutAttributes.center.y + self.collectionView.contentOffset.y - fminf((percentCompleted * 160.0f), 160.0f));
            layoutAttributes.transform = CGAffineTransformMakeScale(fmaxf(1.0f - percentCompleted, 0.35f), fmaxf(1.0f - percentCompleted, 0.35f));
        }
            break;
    }
    return layoutAttributes;
}

@end
