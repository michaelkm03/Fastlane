//
//  VAssetGridViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMediaSource.h"
#import "VCaptureContainerViewController.h"

@class PHFetchResult;

/**
 *  A completion block the AssetGridViewController will call to provide the results of the user selecting an asset.
 *
 *  @param previewImage A preview image of the asset the user has selected. (may be low quality)
 *  @param capturedMediaURL An NSUrl pointing to selected asset. Will be on disk (not iCloud).
 */
typedef void (^VAssetSelectionHandler)(UIImage *previewImage, NSURL *capturedMediaURL);

@interface VAssetGridViewController : UICollectionViewController <VMediaSource, VCaptureContainedViewController>

+ (instancetype)assetGridViewController;

@property (nonatomic, strong) PHFetchResult *assetsToDisplay;

@end
