//
//  VAssetCollectionGridDataSource.h
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

@class VAssetCollectionGridDataSource;

@protocol VAssetCollectionGridDataSourceDelegate <NSObject>

/**
 *  User has selected a particular asset.
 */
- (void)assetCollectionDataSource:(VAssetCollectionGridDataSource *)dataSource
                    selectedAsset:(PHAsset *)asset;

@end

@interface VAssetCollectionGridDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithMediaType:(PHAssetMediaType)mediaType;

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, assign, readonly) PHAssetMediaType mediaType;

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, weak) id<VAssetCollectionGridDataSourceDelegate> delegate;

// Defaults to 3
@property (nonatomic, assign) NSUInteger itemsPerRow;

- (void)updateCachedAssets;

@end
