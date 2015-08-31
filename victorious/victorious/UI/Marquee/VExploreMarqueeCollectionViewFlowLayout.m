//
//  VExploreMarqueeCollectionViewFlowLayout.m
//  victorious
//
//  Created by Tian Lan on 8/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VExploreMarqueeCollectionViewFlowLayout.h"

static CGFloat const kPerspectiveTransform = -1.0f/500.0f;
static CGFloat const kMaxRotation = 2.0f * M_PI_4 / 3.0f;
static CGFloat const kMaxHorizontalOffsetDivisor = 2.2f;
static CGFloat const kMaxZoomDivisor = 30.0f;

@implementation VExploreMarqueeCollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/*
 Cover flow animation taken from inset marquee flow layout
 Only change made was to make screenWidth half of the width of collectionview
*/
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    // This is the only change made from inset marquee flow layout
    CGFloat screenWidth = CGRectGetWidth(self.collectionView.bounds) / 2;
    CGFloat newOffset = self.collectionView.contentOffset.x / screenWidth;
    CGFloat maxHorizontalOffset = screenWidth / kMaxHorizontalOffsetDivisor;
    CGFloat maxZoom = screenWidth / kMaxZoomDivisor;
    for ( UICollectionViewLayoutAttributes *attributes in layoutAttributes )
    {
        CGFloat difference = newOffset - attributes.indexPath.row;
        CGFloat clampedTransformMultiplier = MIN(1.0f, MAX(difference, -1.0f));
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = kPerspectiveTransform;
        transform = CATransform3DRotate(transform, kMaxRotation * clampedTransformMultiplier, 0, 1, 0);
        NSInteger sign = clampedTransformMultiplier < 0 ? -1 : 1;
        transform = CATransform3DTranslate(transform, maxHorizontalOffset * clampedTransformMultiplier * clampedTransformMultiplier * sign, 0, maxZoom * - fabs(clampedTransformMultiplier));
        
        attributes.transform3D = transform;
    }
    return layoutAttributes;
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
    
    return CGPointMake(candidateAttributes.center.x - halfWidth, offset.y);
    
}

@end
