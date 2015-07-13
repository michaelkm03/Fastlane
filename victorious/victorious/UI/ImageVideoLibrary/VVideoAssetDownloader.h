//
//  VVideoAssetDownloader.h
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

/**
 *  VVideoAssetDownloader downloads image assets and places them in the temporary directory.
 */
@interface VVideoAssetDownloader : NSObject

/**
 *  Designated initializer. Asset's media type must be of type PHMediaTypeVideo.
 */
- (instancetype)initWithImageAsset:(PHAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 *  Begins downlowing the video and places a copy in the temporary directory.
 */
- (void)downloadWithProgress:(void (^)(double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion;

@end
