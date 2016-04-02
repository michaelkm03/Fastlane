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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)textForMediaType:(PHAssetMediaType)mediaType
{
    switch (mediaType)
    {
        case PHAssetMediaTypeImage:
            return NSLocalizedString(@"No Photos", nil);
            
        case PHAssetMediaTypeVideo:
            return NSLocalizedString(@"No Videos", nil);
            
        case PHAssetMediaTypeUnknown:
            return NSLocalizedString(@"No Media", nil);
            
        default:
            return nil;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNoAssetsCell *noAssetCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VNoAssetsCell suggestedReuseIdentifier]
                                                                           forIndexPath:indexPath];
    noAssetCell.titleLabel.text = [self textForMediaType:self.mediaType];
    return noAssetCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat widthWithoutInsetAndPadding = fullWidth - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right - (2 * collectionViewLayout.minimumInteritemSpacing);
    return CGSizeMake(VFLOOR(widthWithoutInsetAndPadding), VFLOOR(widthWithoutInsetAndPadding));
}

@end
