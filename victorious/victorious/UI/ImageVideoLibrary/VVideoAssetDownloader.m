//
//  VVideoAssetDownloader.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoAssetDownloader.h"

@interface VVideoAssetDownloader ()

@property (nonatomic, strong) PHAsset *asset;

@end

@implementation VVideoAssetDownloader

- (instancetype)initWithImageAsset:(PHAsset *)asset
{
    NSParameterAssert(asset.mediaType == PHAssetMediaTypeVideo);
    self = [super init];
    if (self != nil)
    {
        _asset = asset;
    }
    return self;
}

- (void)downloadWithProgress:(void (^)(double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.networkAccessAllowed = YES;
    videoRequestOptions.version = PHVideoRequestOptionsVersionCurrent;
    videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    NSString *localizedDownloadString = NSLocalizedString(@"Exporting...", nil);
    videoRequestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
    {
        // We are downloading from iCloud
        if (progressHandler != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                progressHandler(progress, localizedDownloadString);
            });
        }
    };
    
    [[PHImageManager defaultManager] requestExportSessionForVideo:self.asset
                                                          options:videoRequestOptions
                                                     exportPreset:AVAssetExportPresetHighestQuality
                                                    resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info)
     {
         if (exportSession != nil)
         {
             [self exportWithExportSession:exportSession
                                completion:completion];
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                completion(nil, nil, nil);
                            });
         }
     }];
}

- (void)exportWithExportSession:(AVAssetExportSession *)exportSession
                     completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    [exportSession determineCompatibleFileTypesWithCompletionHandler:^(NSArray *compatibleFileTypes)
     {
         VLog(@"file types: %@", compatibleFileTypes);
         exportSession.outputFileType = [compatibleFileTypes lastObject];
         exportSession.outputURL = [self temporaryURLForAsset:self.asset
                                                   withUTType:(__bridge CFStringRef)([compatibleFileTypes lastObject])];
         [exportSession exportAsynchronouslyWithCompletionHandler:^
          {
              // Export completed
              dispatch_async(dispatch_get_main_queue(), ^
                             {
                                 completion(nil, exportSession.outputURL, nil);
                             });
          }];
     }];
}

- (NSURL *)temporaryURLForAsset:(PHAsset *)asset
                     withUTType:(CFStringRef)type
{
    NSURL *baseURL = [self cacheDirectoryURL];
    
    NSUUID *uuid = [NSUUID UUID];
    NSString *filenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension);
    
    return [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uuid.UUIDString, filenameExtension]];
}

- (NSURL *)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
}

@end
