//
//  VSuggestedPeopleCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeopleCell.h"

@implementation VSuggestedPeopleCell

- (void)setCollectionView:(UICollectionView *)collectionView
{
    if ( self.collectionView == nil )
    {
        _collectionView = collectionView;
        [self addSubview:_collectionView];
        _collectionView.frame = self.bounds;
    }
}

+ (NSInteger)cellHeight
{
    return 190.0f;
}

@end
