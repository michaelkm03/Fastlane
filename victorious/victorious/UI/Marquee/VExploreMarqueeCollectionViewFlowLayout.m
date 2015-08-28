//
//  VExploreMarqueeCollectionViewFlowLayout.m
//  victorious
//
//  Created by Tian Lan on 8/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VExploreMarqueeCollectionViewFlowLayout.h"
#define ZOOM_FACTOR .25

@implementation VExploreMarqueeCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    float collectionViewHalfFrame = self.collectionView.frame.size.width/2.0;
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes)
    {
        if (CGRectIntersectsRect(layoutAttributes.frame, rect))
        {
            CGFloat distance = CGRectGetMidX(visibleRect) - layoutAttributes.center.x;
            CGFloat normalizedDistance = distance / collectionViewHalfFrame;
            
            if (ABS(distance) < collectionViewHalfFrame)
            {
                CGFloat zoom = 1 + ZOOM_FACTOR*(1- ABS(normalizedDistance));
                CATransform3D rotationTransform = CATransform3DIdentity;
                rotationTransform = CATransform3DMakeRotation(normalizedDistance * M_PI_2 *0.8, 0.0f, 1.0f, 0.0f);
                CATransform3D zoomTransform = CATransform3DMakeScale(zoom, zoom, 1.0);
                layoutAttributes.transform3D = CATransform3DConcat(zoomTransform, rotationTransform);
                layoutAttributes.zIndex = ABS(normalizedDistance) * 10.0f;
                CGFloat alpha = (1  - ABS(normalizedDistance)) + 0.1;
                if (alpha > 1.0f)
                {
                    alpha = 1.0f;
                }
                layoutAttributes.alpha = alpha;
            }
            else
            {
                layoutAttributes.alpha = 0.0f;
            }
        }
    }
    
    return attributes;
}

@end
