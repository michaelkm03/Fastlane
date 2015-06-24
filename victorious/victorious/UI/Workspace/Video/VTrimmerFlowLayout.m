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


@implementation VTrimmerFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // Call super to get elements
    NSMutableArray* answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    NSLog(@"size initial answer: %lu", (unsigned long)answer.count);
    
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
    
    UICollectionViewLayoutAttributes *atr1 = [self layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
       UICollectionViewLayoutAttributes *atr2 = [self layoutAttributesForSupplementaryViewOfKind:TimemarkViewKind atIndexPath:[NSIndexPath indexPathForItem:500 inSection:0]];
    atr2.center = CGPointMake(atr2.center.x + 80, atr2.center.y);
    
    [answer addObject:atr1];
    [answer addObject:atr2];
    return answer;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //create a new layout attributes to represent this reusable view
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if(attrs)
    {
        if(kind == HashmarkViewKind)
        {
            //position this reusable view relative to the cells frame
            CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.frame), 70);
            attrs.frame = frame;
            attrs.zIndex = 3000;
        }
        if(kind == TimemarkViewKind)
        {
            //position this reusable view relative to the cells frame
            CGRect frame = CGRectMake(0, 0, 50, 50);
            attrs.frame = frame;
            attrs.zIndex = 3001;
        }
        
    }
    return attrs;
}

@end
