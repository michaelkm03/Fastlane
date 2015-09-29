//
//  VExploreMarqueeCollectionViewFlowLayout.m
//  victorious
//
//  Created by Tian Lan on 8/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VExploreMarqueeCollectionViewFlowLayout.h"
#import "victorious-Swift.h"

@implementation VExploreMarqueeCollectionViewFlowLayout

- (CGFloat)getPageWidth
{
    return CGRectGetWidth(self.collectionView.bounds) / [[ExploreMarqueeController class] marqueeShelfAspectRatio];
}

/*
 Responsible for making the scroll view stop at each item
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)offset
                                 withScrollingVelocity:(CGPoint)velocity
{
    
    CGRect cvBounds = self.collectionView.bounds;
    CGFloat halfWidth = cvBounds.size.width * 0.5f;
    CGFloat proposedContentOffsetCenterX = offset.x + halfWidth;
    
    NSArray *attributesArray = [self layoutAttributesForElementsInRect:cvBounds];
    
    UICollectionViewLayoutAttributes *candidateAttributes;
    for (UICollectionViewLayoutAttributes *attributes in attributesArray)
    {
        if (attributes.representedElementCategory != UICollectionElementCategoryCell)
        {
            continue;
        }
        if ( !candidateAttributes )
        {
            candidateAttributes = attributes;
            continue;
        }
        if ( fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX) )
        {
            candidateAttributes = attributes;
        }
    }
    
    return CGPointMake(floor(candidateAttributes.center.x - halfWidth), offset.y);
}

@end
