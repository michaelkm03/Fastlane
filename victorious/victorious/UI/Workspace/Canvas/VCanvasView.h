//
//  VCanvasView.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VPhotoFilter;

/**
 *  Posted whenever a new asset size becomes available.
 */
extern NSString * const VCanvasViewAssetSizeBecameAvailableNotification;

/*
 VCanvasView is a representation of the current state of the workspace while editing an image. VCanvasView is optimized for performance and may scale sourceImage down to provide fast render times.
 */
@interface VCanvasView : UIView

/**
 *  Same as calling "setSourceURL:someURL withPreloadedImage:nil".
 */
- (void)setSourceURL:(NSURL *)URL;

/**
 *  Will use preloadedImage if it exists. If not will pull from URL.
 */
- (void)setSourceURL:(NSURL *)URL
  withPreloadedImage:(UIImage *)preloadedImage;

@property (nonatomic, readonly) UIImage *asset; ///< The asset loaded in the imageView via setSourceURL: .

@property (nonatomic, readonly) CGSize assetSize; ///< The size of the source asset.

@property (nonatomic, strong) VPhotoFilter *filter; ///< The Filter to use on the image.

@property (nonatomic, readonly) UIScrollView *canvasScrollView; ///< A zooming scrollview for providing crop functionality.

@property (nonatomic, assign) BOOL allowsZoom; ///< Defaults to true.

@end

/**
 *  Properties in this category are exposed for tracking purposes
 */
@interface VCanvasView (InteractionTracking)

/**
 *  User did pinch to crop.
 */
@property (nonatomic, readonly) BOOL didCropZoom;

/**
 *  User did crop with a pan.
 */
@property (nonatomic, readonly) BOOL didCropPan;

/**
 *  User did crop with a double-tap to zoom.
 */
@property (nonatomic, readonly) BOOL didZoomFromDoubleTap;

@end
