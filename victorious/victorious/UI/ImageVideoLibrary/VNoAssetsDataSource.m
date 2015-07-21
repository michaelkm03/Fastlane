//
//  VNoAssetsDataSource.m
//  victorious
//
//  Created by Michael Sena on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNoAssetsDataSource.h"
#import "VNoAssetsCell.h"

@implementation VNoAssetsDataSource

- (instancetype)initWithMediaType:(PHAssetMediaType)mediaType
{
    self = [super init];
    if (self != nil)
    {
        _mediaType = mediaType;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNoAssetsCell *noAssetCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VNoAssetsCell suggestedReuseIdentifier]
                                                                           forIndexPath:indexPath];
    noAssetCell.titleLabel.text = (self.mediaType == PHAssetMediaTypeImage) ? @"No Photos" : @"No Videos";
    return noAssetCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat widthWithoutInsetAndPadding = fullWidth - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right - (2 * collectionViewLayout.minimumInteritemSpacing);
    return CGSizeMake(VFLOOR(widthWithoutInsetAndPadding), VFLOOR(widthWithoutInsetAndPadding));
}

@end
