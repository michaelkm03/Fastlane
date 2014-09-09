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
    
    UICollectionViewLayoutAttributes *layoutAttributesForRealTimeComments = [defaultAttributes objectAtIndex:1];
    
    CGFloat catchPoint = CGRectGetHeight(layoutAttributesForRealTimeComments.frame);
    
    [defaultAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop)
    {
        if (self.collectionView.contentOffset.y < catchPoint)
        {
            if (idx == 0)
            {
                layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y, 320, 320);
            }
            else if (idx == 1)
            {
                layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y + 320, 320, 110);
            }
        }
        else
        {
            CGFloat deltaCatchPointToTop = self.collectionView.contentOffset.y - catchPoint;
            CGFloat percentCompleted = (deltaCatchPointToTop / 320.0f);
            NSLog(@"%f", percentCompleted);
            if (idx == 0)
            {
                layoutAttributes.zIndex = 1000;
                layoutAttributes.center = CGPointMake(layoutAttributes.center.x + fminf((percentCompleted* 100.0f), 100.0f), layoutAttributes.center.y + self.collectionView.contentOffset.y - fminf((percentCompleted * 160.0f), 160.0f));
                layoutAttributes.transform = CGAffineTransformMakeScale(fmaxf(1.0f - percentCompleted, 0.35f), fmaxf(1.0f - percentCompleted, 0.35f));
            }
            else if (idx == 1)
            {
                layoutAttributes.frame = CGRectMake(0, self.collectionView.contentOffset.y + 320.0f, 320, 110);
            }
            else
            {
                
            }
        }
    }];
    
    return defaultAttributes;
}


@end
