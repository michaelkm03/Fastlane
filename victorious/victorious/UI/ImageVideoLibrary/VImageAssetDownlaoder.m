//
//  VImageAssetDownlaoder.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetDownlaoder.h"

#import "UIImage+Resize.h"

NSString * const VImageAssetDownlaoderErrorDomain = @"com.victorious.VImageAssetDownlaoderErrorDomain";

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
    
    if (self.asset.representsBurst)
    {
        PHFetchOptions *burstFetchOption = [[PHFetchOptions alloc] init];
        burstFetchOption.includeAllBurstAssets = YES;
        PHFetchResult *automaticBurstSelection = [PHAsset fetchAssetsWithBurstIdentifier:self.asset.burstIdentifier
                                                                                 options:burstFetchOption];
        PHAsset *pickedBurstAsset;
        for (PHAsset *burstAsset in automaticBurstSelection)
        {
            if (burstAsset.burstSelectionTypes | PHAssetBurstSelectionTypeUserPick)
            {
                pickedBurstAsset = burstAsset;
                break;
            }
        }
        if (pickedBurstAsset == nil)
        {
            self.asset = [automaticBurstSelection firstObject];
        }
        else
        {
            self.asset = pickedBurstAsset;
        }
        
    }

    [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
                                                      options:fullSizeRequestOptions
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         if (imageData == nil)
         {
             NSError *downloadFailure = [NSError errorWithDomain:VImageAssetDownlaoderErrorDomain
                                                            code:0
                                                        userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"ImageDownloadFailed", nil)}];
             completion(downloadFailure, nil, nil);
             return;
         }
         // This handler is always called on main thread per header
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            UIImage *imageFromData = [UIImage imageWithData:imageData];
                            UIImage *imageWithProperOrientation = [[UIImage imageWithCGImage:imageFromData.CGImage scale:1.0f orientation:orientation] fixOrientation];
                            NSURL *urlForAsset = [self temporaryURLForAsset:self.asset];
                            NSError *error;
                            NSData *imageData = UIImageJPEGRepresentation(imageWithProperOrientation, 1.0f);
                            BOOL success = [imageData writeToURL:urlForAsset options:NSDataWritingAtomic error:&error];
                            
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               if (success)
                                               {
                                                   completion(nil, urlForAsset, imageWithProperOrientation);
                                               }
                                               else
                                               {
                                                   completion(error, nil, nil);
                                               }
                                           });
                        });
     }];
}

#pragma mark - Convenience

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
