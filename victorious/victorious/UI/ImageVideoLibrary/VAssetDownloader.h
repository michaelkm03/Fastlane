//
//  VAssetDownloader.h
//  victorious
//
//  Created by Michael Sena on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

/**
 *  Defines a common interface for asset downloaders.
 */
@interface VAssetDownloader : NSObject

/**
 *  Designated initializer for asset downloaders. Base implementation merely calls NSObject's -init.
 */
- (instancetype)initWithAsset:(PHAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 *  Downloads the asset passed in the designated initializer asynchronously.
 *
 *  @param progressHandler Called to inform the user about the progress of the download.
 *  @param completion Called to inform bout compleiton of the download. Always called on the main thread.
 */
- (void)downloadWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion;

@end
