//
//  VImageAssetDownlaoder.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetDownlaoder.h"

#import "UIImage+Resize.h"

@interface VImageAssetDownlaoder ()

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation VImageAssetDownlaoder

- (instancetype)initWithImageAsset:(PHAsset *)asset
{
    NSParameterAssert(asset.mediaType == PHAssetMediaTypeImage);
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
    }
    return self;
}

- (void)downloadWithProgress:(void (^)(double progress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion

{
    PHImageRequestOptions *fullSizeRequestOptions = [[PHImageRequestOptions alloc] init];
    fullSizeRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    fullSizeRequestOptions.version = PHImageRequestOptionsVersionCurrent;
    fullSizeRequestOptions.networkAccessAllowed = YES;
    fullSizeRequestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
    {
        if (progressHandler != nil)
        {
            progressHandler(progress);
        }
    };

    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
                                                      options:fullSizeRequestOptions
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            UIImage *imageFromData = [UIImage imageWithData:imageData];
                            UIImage *imageWithProperOrientation = [[UIImage imageWithCGImage:imageFromData.CGImage scale:1.0f orientation:orientation] fixOrientation];
                            NSURL *urlForAsset = [self temporaryURLForAsset:self.asset];
                            [self saveImage:imageWithProperOrientation
                                      toURL:urlForAsset];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               completion(nil, urlForAsset, imageWithProperOrientation);
                                           });
                        });
     }];
}

#pragma mark - Convenience

- (void)saveImage:(UIImage *)image
            toURL:(NSURL *)fileURL
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSError *error = nil;
    [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
}

- (NSURL *)temporaryURLForAsset:(PHAsset *)asset
{
    NSURL *baseURL = [self cacheDirectoryURL];
    
    NSUUID *uuid = [NSUUID UUID];
    NSString *filenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(kUTTypeJPEG, kUTTagClassFilenameExtension);
    
    return [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uuid.UUIDString, filenameExtension]];
}

- (NSURL *)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
}

@end
