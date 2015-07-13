//
//  VAssetCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class PHAsset;

@interface VAssetCollectionViewCell : VBaseCollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

- (void)refetchImage;

@end
