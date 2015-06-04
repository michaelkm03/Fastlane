//
//  VInsetMarqueeController.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInsetMarqueeController.h"
#import "VInsetMarqueeCollectionViewCell.h"
#import "VInsetMarqueeStreamItemCell.h"

@implementation VInsetMarqueeController

- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VInsetMarqueeCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VInsetMarqueeCollectionViewCell suggestedReuseIdentifier]];
}

- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    VInsetMarqueeCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VInsetMarqueeCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
    collectionViewCell.marquee = self;
    collectionViewCell.dependencyManager = self.dependencyManager;
    [self enableTimer];
    return collectionViewCell;
}

- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VInsetMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

- (void)setupStreamItemCell:(VAbstractMarqueeStreamItemCell *)streamItemCell withDependencyManager:(VDependencyManager *)dependencyManager andStreamItem:(VStreamItem *)streamItem
{
    streamItemCell.dependencyManager = dependencyManager;
    streamItemCell.streamItem = streamItem;
}

+ (Class)marqueeStreamItemCellClass
{
    return [VInsetMarqueeStreamItemCell class];
}

@end
