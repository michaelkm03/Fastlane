//
//  VNoAssetsDataSource.h
//  victorious
//
//  Created by Michael Sena on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

/**
 *  A simple CollectionView data source for displaying no results in the photo library.
 */
@interface VNoAssetsDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 *  The designated initializer for this class.
 */
- (instancetype)initWithMediaType:(PHAssetMediaType)mediaType NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  The media type this class was initialized with.
 */
@property (nonatomic, readonly) PHAssetMediaType mediaType;

@end
