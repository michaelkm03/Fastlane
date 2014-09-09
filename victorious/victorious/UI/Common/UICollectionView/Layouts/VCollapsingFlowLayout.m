//
//  VCollapsingFlowLayout.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCollapsingFlowLayout.h"

@implementation VCollapsingFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
#warning Optimize this to only invalidate layout when we are collapsing
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *defaultAttributes = [super layoutAttributesForElementsInRect:rect];

//    NSMutableArray *modifiedAttributes = [NSMutableArray new];
    
    CGFloat catchPoint = 320.0f;
    CGFloat collapsePoint = 430.0f;
    
    [defaultAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        
        if (idx == 0)
        {
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, 320, 320);
        }
        else if (idx == 1)
        {
            layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y + 320, 320, 110);
        }
        
    }];
    
    return defaultAttributes;
}


@end
