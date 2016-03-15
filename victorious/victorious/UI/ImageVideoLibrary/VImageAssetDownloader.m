//
//  VImageAssetDownloader.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetDownloader.h"

#import "UIImage+Resize.h"
#import "NSURL+VTemporaryFiles.h"
#import "VConstants.h"

NSString * const VImageAssetDownloaderErrorDomain = @"com.victorious.VImageAssetDownloaderErrorDomain";

@interface VImageAssetDownloader ()

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) CIContext *context;

@end

@implementation VImageAssetDownloader

- (instancetype)initWithAsset:(PHAsset *)asset
{
    NSParameterAssert(asset.mediaType == PHAssetMediaTypeImage);
    self = [super initWithAsset:asset];
    if (self != nil)
    {
        _asset = asset;
        _context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(NO),
                                                   kCIContextPriorityRequestLow:@(YES)}];
    }
    return self;
}

- (BOOL)willReturnAccurateProgress
{
    return NO;
}

- (void)downloadWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion

{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.version = PHImageRequestOptionsVersionCurrent;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (progressHandler != nil)
            {
                progressHandler(YES, progress, NSLocalizedString(@"Downloading...", nil));
            }
        });
    };
    
    if (self.asset.representsBurst)
    {
        self.asset = [self assetForBurstAsset:self.asset];
    }

    NSURL *urlForAsset = [self temporaryURLForAsset:self.asset];
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:CGSizeMake(640.0, 640.0)
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                        {
                            dispatch_async(dispatch_get_main_queue(), ^
                            {
                               progressHandler(NO, 1.0f, NSLocalizedString(@"Exporting...", nil));
                           });
                            NSError *error;
                            NSData *imageData = UIImageJPEGRepresentation(result, 0.7f);
                            BOOL success = [imageData writeToURL:urlForAsset options:NSDataWritingAtomic error:&error];
                            
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               if (success)
                                               {
                                                   completion(nil, urlForAsset, result);
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
    NSString *filenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(kUTTypeJPEG, kUTTagClassFilenameExtension);
    
    return [NSURL v_temporaryFileURLWithExtension:filenameExtension inDirectory:kCameraDirectory];
}

@end
