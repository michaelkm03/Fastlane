//
//  VStreamCollectionViewFlowLayout.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewFlowLayout.h"

@interface VStreamCollectionViewFlowLayout ()

@property (nonatomic, strong) VAbstractMarqueeController *marqueeController;
@property (nonatomic, strong) VStreamCollectionViewDataSource *collectionViewDataSource;

@end

@implementation VStreamCollectionViewFlowLayout

- (instancetype)initWithMarqueeController:(VAbstractMarqueeController *)marqueeController
                               dataSource:(VStreamCollectionViewDataSource *)dataSource
{
    self = [super init];
    if (self != nil)
    {
        _marqueeController = marqueeController;
        _collectionViewDataSource = dataSource;
        _marqueeParallaxRatio = 1.0f;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return self.collectionViewDataSource.hasHeaderCell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes)
    {
        if (self.collectionViewDataSource.hasHeaderCell && layoutAttributes.indexPath.section == 0)
        {
            CGRect headerFrame = layoutAttributes.frame;
            CGPoint contentOffset = self.collectionView.contentOffset;
            if (contentOffset.y > 0 && self.marqueeParallaxRatio < 1.0f)
            {
                headerFrame.origin.y += contentOffset.y * self.marqueeParallaxRatio;
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
