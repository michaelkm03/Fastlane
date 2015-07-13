//
//  VImageAssetDownlaoder.h
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

/**
 *  VImageAssetDownlaoder downloads images assets and placed them in the temporary directory.
 */
@interface VImageAssetDownlaoder : NSObject

/**
 *  Designated initializer. Asset's mediaType must be of type PHMediaTypeImage.
 */
- (instancetype)initWithImageAsset:(PHAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 *  Tells the downloader to begin downloading.
 */
- (void)downloadWithProgress:(void (^)(double progress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion;

@end
