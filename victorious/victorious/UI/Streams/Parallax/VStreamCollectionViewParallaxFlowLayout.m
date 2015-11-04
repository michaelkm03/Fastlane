//
//  VStreamCollectionViewFlowLayout.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewParallaxFlowLayout.h"
#import "VParallaxScrolling.h"

@interface VStreamCollectionViewParallaxFlowLayout ()

@end

@implementation VStreamCollectionViewParallaxFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *superAttributes = [super layoutAttributesForElementsInRect:rect];
    NSArray *attributes = [[NSArray alloc] initWithArray:superAttributes copyItems:YES];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes)
    {
        if ( layoutAttributes.indexPath.row != 0 )
        {
            continue;
        }
        
        UICollectionReusableView *cell = [self.collectionView cellForItemAtIndexPath:layoutAttributes.indexPath];
        
        if ([cell conformsToProtocol:@protocol(VParallaxScrolling)])
        {
            CGFloat parallaxRatio = [(id<VParallaxScrolling>)cell parallaxRatio];
            
            CGRect headerFrame = layoutAttributes.frame;
            
            layoutAttributes.zIndex = -1000.0f;
            
            CGPoint contentOffset = self.collectionView.contentOffset;
            if (contentOffset.y > 0)
            {
                // Offset the frame of the header to create parallax effect
                headerFrame.origin.y += contentOffset.y * parallaxRatio;
            }
            
            layoutAttributes.frame = headerFrame;
        }
    }
    
    return attributes;
}

@end
