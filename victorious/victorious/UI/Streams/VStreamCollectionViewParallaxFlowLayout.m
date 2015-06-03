//
//  VStreamCollectionViewFlowLayout.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewParallaxFlowLayout.h"
#import "VParallaxScrolling.h"

static const CGFloat kHeaderFadeoutBuffer = 20.0f;

@interface VStreamCollectionViewParallaxFlowLayout ()

@end

@implementation VStreamCollectionViewParallaxFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes)
    {
        UICollectionReusableView *cell = [self.collectionView cellForItemAtIndexPath:layoutAttributes.indexPath];
        
        if ([cell conformsToProtocol:@protocol(VParallaxScrolling)])
        {
            CGFloat parallaxRatio = [(id<VParallaxScrolling>)cell parallaxRatio];
            
            CGRect headerFrame = layoutAttributes.frame;
            
            CGPoint contentOffset = self.collectionView.contentOffset;
            if (contentOffset.y > 0)
            {
                // Offset the frame of the header to create parallax effect
                headerFrame.origin.y += contentOffset.y * parallaxRatio;
                
                // Adjust alpha to create smooth fade out of header if its still visible behind cells
                if (contentOffset.y > headerFrame.size.height - kHeaderFadeoutBuffer)
                {
                    CGFloat newAlpha = 1 - (contentOffset.y - headerFrame.size.height) / (headerFrame.size.height - kHeaderFadeoutBuffer);
                    layoutAttributes.alpha = newAlpha;
                }
            }
            
            layoutAttributes.frame = headerFrame;
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

@end
