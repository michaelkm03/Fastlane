//
//  VVideoAssetDownloader.m
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoAssetDownloader.h"
#import "VTimerManager.h"
#import "NSURL+VTemporaryFiles.h"
#import "VConstants.h"

NSString * const VVideoAssetDownloaderErrorDomain = @"com.victorious.VVideoAssetDownlaoderErrorDomain";

// Downloads go from 0 -> 0.5
static double kProgressSplit = 0.5f;
// Exports go from 0.5 -> 1

@interface VVideoAssetDownloader ()

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isInIcloud;
@property (nonatomic, copy) void (^progressBlock)(BOOL accurateProgress, double progress, NSString *localizedProgress);
@property (nonatomic, weak) AVAssetExportSession *exportSession;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VVideoAssetDownloader

- (instancetype)initWithAsset:(PHAsset *)asset
{
    NSParameterAssert(asset.mediaType == PHAssetMediaTypeVideo);
    self = [super initWithAsset:asset];
    if (self != nil)
    {
        _asset = asset;
    }
    return self;
}

- (BOOL)willReturnAccurateProgress
{
    return YES;
}

- (void)downloadWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    [self atttempOfflineExportWithProgress:progressHandler
                                completion:completion];
    // Also grab a previewImage
    [self downloadPreviewImage];
}

- (void)atttempOfflineExportWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                              completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.networkAccessAllowed = NO;
    videoRequestOptions.version = PHVideoRequestOptionsVersionCurrent;
    videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    self.progressBlock = progressHandler;
    
    [[PHImageManager defaultManager] requestExportSessionForVideo:self.asset
                                                          options:videoRequestOptions
                                                     exportPreset:AVAssetExportPresetHighestQuality
                                                    resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            if (exportSession != nil)
                            {
                                self.isInIcloud = NO;
                                [self exportWithExportSession:exportSession
                                                   completion:completion];
                            }
                            else if ([info[PHImageResultIsInCloudKey] boolValue])
                            {
                                [self attemptOnlineDownloadWithProgress:progressHandler
                                                             completion:completion];
                            }
                            else
                            {
                                NSError *error = [NSError errorWithDomain:VVideoAssetDownloaderErrorDomain code:0 userInfo:nil];
                                completion(error, nil, nil);
                            }
                        });
     }];
}

- (void)attemptOnlineDownloadWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                               completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.networkAccessAllowed = YES;
    videoRequestOptions.version = PHVideoRequestOptionsVersionCurrent;
    videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    NSString *localizedDownloadString = NSLocalizedString(@"Downloading...", nil);
    self.progressBlock = progressHandler;
    videoRequestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           // We are downloading from iCloud
                           if (progressHandler != nil)
                           {
                               self.isInIcloud = YES;
                               double adjustedProgress = progress * kProgressSplit;
                               progressHandler(YES, adjustedProgress, localizedDownloadString);
                           }
                       });
    };
    
    [[PHImageManager defaultManager] requestExportSessionForVideo:self.asset
                                                          options:videoRequestOptions
                                                     exportPreset:AVAssetExportPresetHighestQuality
                                                    resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            if (exportSession != nil)
                            {
                                [self exportWithExportSession:exportSession
                                                   completion:completion];
                            }
                            else
                            {
                                NSError *error = [NSError errorWithDomain:VVideoAssetDownloaderErrorDomain code:0 userInfo:nil];
                                completion(error, nil, nil);
                            }
                        });
     }];
}

- (void)exportWithExportSession:(AVAssetExportSession *)exportSession
                     completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    [VTimerManager scheduledTimerManagerWithTimeInterval:0.1f
                                                  target:self
                                                selector:@selector(exportTimerTick:)
                                                userInfo:nil
                                                 repeats:YES];
    self.exportSession = exportSession;
    __weak typeof(self) welf = self;
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
                                 __strong typeof(welf) strongSelf = welf;
                                 completion(nil, exportSession.outputURL, strongSelf.previewImage);
                             });
          }];
     }];
}

- (void)exportTimerTick:(NSTimer *)timer
{
    if (self.progressBlock == nil)
    {
        [timer invalidate];
        return;
    }
    
    if (self.exportSession.progress > 0.99)
    {
        [timer invalidate];
        self.progressBlock(YES, 1.0, NSLocalizedString(@"Exporting...", nil));
        return;
    }
    
    double adjustedProgress;
    
    if (self.isInIcloud)
    {
        adjustedProgress = (self.exportSession.progress * kProgressSplit) + kProgressSplit;
    }
    else
    {
        adjustedProgress = self.exportSession.progress;
    }
    
    self.progressBlock(YES, adjustedProgress, NSLocalizedString(@"Exporting...", nil));
}

- (NSURL *)temporaryURLForAsset:(PHAsset *)asset
                     withUTType:(CFStringRef)type
{
    NSString *filenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension);
    
    return [NSURL v_temporaryFileURLWithExtension:filenameExtension inDirectory:kCameraDirectory];
}

- (void)downloadPreviewImage
{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.networkAccessAllowed = YES;
    __weak typeof(self) welf = self;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                               targetSize:CGSizeMake(100.0f, 100.0f)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:requestOptions
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         __strong typeof(welf) strongSelf = welf;
         strongSelf.previewImage = result;
     }];
}

@end
