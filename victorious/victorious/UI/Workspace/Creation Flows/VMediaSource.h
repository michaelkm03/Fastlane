//
//  VMediaSource.h
//  victorious
//
//  Created by Michael Sena on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A completion block the AssetGridViewController will call to provide the results of the user selecting an asset.
 *
 *  @param previewImage A preview image of the asset the user has selected. (may be low quality)
 *  @param capturedMediaURL An NSUrl pointing to selected asset. Will be on disk (not iCloud).
 */
typedef void (^VMediaSelectionHandler)(UIImage *previewImage, NSURL *capturedMediaURL);

@protocol VMediaSource <NSObject>

@property (nonatomic, copy) VMediaSelectionHandler handler;

@end
