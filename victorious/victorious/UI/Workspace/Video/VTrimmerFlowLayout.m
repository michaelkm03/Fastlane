//
//  VTrimmerFlowLayout.m
//  victorious
//
//  Created by Steven F Petteruti on 6/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrimmerFlowLayout.h"

NSString *const HashmarkViewKind = @"HashmarkKind";
NSString *const TimemarkViewKind = @"TimemarkKind";

const static NSUInteger kNumberOfHashes = 30;
const static NSUInteger kNumberOfTimeLabels = 10;

const static CGFloat kSpacingOfHashes = 33.333f;
const static CGFloat kSpacingOfTimeLables = 100.0f;

const static CGFloat kHashmarkOffsetY = -15.0f;
const static CGFloat kTimemarkOffsetY = -49.0f;


@implementation VTrimmerFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Call super to get elements
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSUInteger index = (self.collectionView.contentOffset.x/kSpacingOfHashes);
    for (NSUInteger i = 0; i < kNumberOfHashes; i++)
    {
        UICollectionViewLayoutAttributes *hashtribute = [self layoutAttributesForSupplementaryViewOfKind:HashmarkViewKind atIndexPath:[NSIndexPath indexPathForItem:index+i inSection:0]];
        [answer addObject:hashtribute];
    }
    index =  (int) (self.collectionView.contentOffset.x/kSpacingOfTimeLables);
    for (NSUInteger i = 0; i < kNumberOfTimeLabels; i++)
    {
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:[NSIndexPath indexPathForItem:i + index inSection:0]];
        [answer addObject:attribute];
    }
  
    return answer;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //create a new layout attributes to represent this reusable view
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if (attrs)
    {
        CGRect frame = CGRectZero;
        if (kind == HashmarkViewKind)
        {
            //position this reusable view relative to the cells frame
            frame = CGRectMake(indexPath.item*(kSpacingOfHashes) + 25, kHashmarkOffsetY, 50, 50);
            attrs.zIndex = 3000;
        }
        else if (kind == TimemarkViewKind)
        {
            //position this reusable view relative to the cells frame
            frame = CGRectMake(indexPath.item*(kSpacingOfTimeLables), kTimemarkOffsetY, 50, 50);
            attrs.zIndex = 3001;
        }
    
        CGRect visibleRect;
        visibleRect.origin = CGPointMake(0.0f, self.collectionView.contentOffset.y);
        visibleRect.size = CGSizeMake(self.collectionViewContentSize.width - 5.0f, self.collectionViewContentSize.height);
        
        if (!CGRectIntersectsRect(visibleRect, frame))
        {
            frame = CGRectZero;
        }
        attrs.frame = frame;
    }
    return attrs;
}

@end
