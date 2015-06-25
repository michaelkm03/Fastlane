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

const static int kNumberOfHashes = 10;
const static int kNumberOfTimeLabels = 5;

const static CGFloat kSpacingOfHashes = 25.0f;
const static CGFloat kSpacingOfTimeLables = 25.0f;
const static CGFloat kMarginSpacing = 80.0f;


@implementation VTrimmerFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Call super to get elements
    NSMutableArray* answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSUInteger maxSectionIndex = 0;
    for (NSUInteger idx = 0; idx < [answer count]; ++idx)
    {
        UICollectionViewLayoutAttributes *layoutAttributes = answer[idx];
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell || layoutAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            // Keep track of the largest section index found in the rect (maxSectionIndex)
            NSUInteger sectionIndex = (NSUInteger)layoutAttributes.indexPath.section;
            if (sectionIndex > maxSectionIndex) {
                maxSectionIndex = sectionIndex;
            }
        }
        /*
        
        if ([layoutAttributes.representedElementKind isEqualToString:HashmarkViewKind])
        {
            // Remove layout of header done by our super, as we will do it right later
            [answer removeObjectAtIndex:idx];
            idx--;
        }
        if ([layoutAttributes.representedElementKind isEqualToString:TimemarkViewKind])
        {
            // Remove layout of header done by our super, as we will do it right later
            [answer removeObjectAtIndex:idx];
            idx--;
        }
         */
    }
    /*
    // Re-add all section headers for sections >= maxSectionIndex
    for (NSUInteger idx = 0; idx <= maxSectionIndex; ++idx)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *hashmarkAttribute = [self layoutAttributesForSupplementaryViewOfKind:HashmarkViewKind atIndexPath:indexPath];
        if (hashmarkAttribute)
        {
            [answer addObject:hashmarkAttribute];
        }
        
        UICollectionViewLayoutAttributes *timemarkAttribute = [self layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:indexPath];
        if (timemarkAttribute&&(idx <= maxSectionIndex))
        {
            [answer addObject:timemarkAttribute];
            [answer addObject:timemarkAttribute];
            [answer addObject:timemarkAttribute];

        }
    }
    NSLog(@"size initial answer: %lu", (unsigned long)answer.count);
*/
    for (int i = 0; i < kNumberOfHashes; i++)
    {
        UICollectionViewLayoutAttributes *hashtribute = [self layoutAttributesForSupplementaryViewOfKind:HashmarkViewKind atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [answer addObject:hashtribute];
    }
    for (int i = 0; i < kNumberOfTimeLabels; i++)
    {
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
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
            frame = CGRectMake(indexPath.item*(50+kSpacingOfHashes), -10, 50, 50);
            attrs.zIndex = 3000;
        }
        else if (kind == TimemarkViewKind)
        {
            //position this reusable view relative to the cells frame
            frame = CGRectMake(indexPath.item*(50+kSpacingOfTimeLables), -0, 50, 50);
            attrs.zIndex = 3001;
        }
        if (CGRectGetMaxX(frame) < (self.collectionView.contentOffset.x - kMarginSpacing))
        {
            // asset is too far to the left... shift it to the right
            NSLog(@"something went too far to the left... popping it right");
            frame = CGRectMake(self.collectionView.contentOffset.x, 0, 50, 50);
        }
        if (CGRectGetMinX(frame) > (self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.frame) + kMarginSpacing))
        {
            // asset is too far to the right... move it to the left
            NSLog(@"something went too far to the right... popping it left");

            frame = CGRectMake(self.collectionView.contentOffset.x, 0, 50, 50);
        }
        /*
        if (CGRectGetMaxX(self.collectionView.frame) < CGRectGetMaxX(frame))
        {
            frame = CGRectZero;
        }*/
        attrs.frame = frame;
    }
    return attrs;
}

@end
