//
//  VCollectionViewStreamFocusHelper.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCollectionViewStreamFocusHelper.h"

@interface VCollectionViewStreamFocusHelper ()

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation VCollectionViewStreamFocusHelper

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        _collectionView = collectionView;
    }
    return self;
}

#pragma mark - Overrides

- (UIScrollView *)scrollView
{
    return self.collectionView;
}

- (NSArray *)visibleCells
{
    return self.collectionView.visibleCells;
}

@end
