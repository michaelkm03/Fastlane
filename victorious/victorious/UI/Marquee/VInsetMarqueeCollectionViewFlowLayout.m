//
//  VInsetMarqueeCollectionViewFlowLayout.m
//  victorious
//
//  Created by Sharif Ahmed on 6/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetMarqueeCollectionViewFlowLayout.h"

static CGFloat const kPerspectiveTransform = -1.0/500.0;
static CGFloat const kMaxRotation = 2 * M_PI_4 / 3;
static CGFloat const kMaxZoom = 60;

@implementation VInsetMarqueeCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    CGFloat newOffset = self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds);
    for ( UICollectionViewLayoutAttributes *attributes in layoutAttributes )
    {
        CGFloat difference = newOffset - attributes.indexPath.row;
        CGFloat clampedRotationMultiplier = MIN(1.0f, MAX(difference, -1.0f));
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = kPerspectiveTransform;
        transform = CATransform3DRotate(transform, kMaxRotation * clampedRotationMultiplier, 0, 1, 0);
        transform = CATransform3DTranslate(transform, 0, 0, kMaxZoom * -fabs(clampedRotationMultiplier));

        attributes.transform3D = transform;
    }
    return layoutAttributes;
}

@end
