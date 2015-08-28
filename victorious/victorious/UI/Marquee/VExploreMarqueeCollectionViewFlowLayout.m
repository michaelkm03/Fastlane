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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
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
        transform = CATransform3DTranslate(transform, maxHorizontalOffset * clampedTransformMultiplier * clampedTransformMultiplier * sign, 0, maxZoom * -fabs(clampedTransformMultiplier));
        
        attributes.transform3D = transform;
    }
    return layoutAttributes;
}

@end
