//
//  VImageAssetDownloader.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetDownloader.h"

#import "UIImage+Resize.h"

NSString * const VImageAssetDownloaderErrorDomain = @"com.victorious.VImageAssetDownloaderErrorDomain";

@interface VImageAssetDownloader ()

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation VImageAssetDownloader

- (instancetype)initWithAsset:(PHAsset *)asset
{
    NSParameterAssert(asset.mediaType == PHAssetMediaTypeImage);
    self = [super initWithAsset:asset];
    if (self != nil)
    {
        _asset = asset;
    }
    return self;
}

- (void)downloadWithProgress:(void (^)(double progress, NSString *localizedProgress))progressHandler
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
            progressHandler(progress, NSLocalizedString(@"Exporting...", nil));
        }
    };
    
    if (self.asset.representsBurst)
    {
        self.asset = [self assetForBurstAsset:self.asset];
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

- (PHAsset *)assetForBurstAsset:(PHAsset *)burstAsset
{
    PHFetchOptions *burstFetchOption = [[PHFetchOptions alloc] init];
    burstFetchOption.includeAllBurstAssets = YES;
    PHFetchResult *automaticBurstSelection = [PHAsset fetchAssetsWithBurstIdentifier:self.asset.burstIdentifier
                                                                             options:burstFetchOption];
    // Find user pick first
    PHAsset *pickedBurstAsset;
    for (PHAsset *burstAsset in automaticBurstSelection)
    {
        if (burstAsset.burstSelectionTypes | PHAssetBurstSelectionTypeUserPick)
        {
            pickedBurstAsset = burstAsset;
            break;
        }
    }
    // Return it if we find it
    if (pickedBurstAsset != nil)
    {
        return pickedBurstAsset;
    }
    // Look for auto-pick
    PHAsset *autoPickedBurstAsset;
    for (PHAsset *burstAsset in automaticBurstSelection)
    {
        if (burstAsset.burstSelectionTypes | PHAssetBurstSelectionTypeAutoPick)
        {
            pickedBurstAsset = burstAsset;
            break;
        }
    }
    // Return it if we find it
    if (autoPickedBurstAsset != nil)
    {
        return pickedBurstAsset;
    }
    else
    {
        // Just return the first one
        return [automaticBurstSelection firstObject];
    }
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
