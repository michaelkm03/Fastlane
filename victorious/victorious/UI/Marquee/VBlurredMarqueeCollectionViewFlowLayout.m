//
//  VBlurredCollectionViewFlowLayout.m
//  victorious
//
//  Created by Sharif Ahmed on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeCollectionViewFlowLayout.h"

static const CGFloat kRotationDivisor = 10.0f;
static const CGFloat kScaleDivisor = 6.0f;

@implementation VBlurredMarqueeCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    CGFloat newOffset = self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds);
    for ( UICollectionViewLayoutAttributes *attributes in layoutAttributes )
    {
        NSIndexPath *indexPath = attributes.indexPath;
        CGFloat relativeOffset = newOffset - indexPath.row;
        CGFloat contentRotation = ( relativeOffset ) / kRotationDivisor;
        CGFloat contentScale = 1 - ( fabs( relativeOffset ) / kScaleDivisor );
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale( contentScale, contentScale );
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation( - M_PI * contentRotation );
        CGAffineTransform transform = CGAffineTransformConcat( scaleTransform, rotationTransform );
        attributes.transform = transform;
    }
    return layoutAttributes;
}

@end
