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

- (instancetype)initWithAsset:(PHAsset *)asset NS_DESIGNATED_INITIALIZER;

- (void)downloadWithProgress:(void (^)(double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion;

@end
