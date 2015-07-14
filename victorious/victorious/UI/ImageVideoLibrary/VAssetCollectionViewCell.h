//
//  VAssetCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@import Photos;

/**
 *  VAssetCollectionViewCell displays a PHAsset in a collectionViewCell.
 */
@interface VAssetCollectionViewCell : VBaseCollectionViewCell

/**
 *  The PHAsset that this cell will fetch image data for.
 */
@property (nonatomic, strong) PHAsset *asset;

/**
 *  The image manager that this cell will use to fetch it's assets. 
 */
@property (nonatomic, strong) PHImageManager *imageManager;

@end
