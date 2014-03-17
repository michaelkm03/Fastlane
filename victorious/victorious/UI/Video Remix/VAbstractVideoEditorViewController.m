//
//  VAbstractVideoEditorViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractVideoEditorViewController.h"

@interface VAbstractVideoEditorViewController ()
@end

@implementation VAbstractVideoEditorViewController

#pragma mark - Overrides

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // Examples:    Overlay, Animagtion, Subtitle, Tilt
}

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
}

#pragma mark - Compositing Support

- (void)processVideo:(AVAsset *)aVideoAsset timeRange:(CMTimeRange)aTimeRange
{
    CMTimeRange                 timeRange = CMTIMERANGE_IS_EMPTY(aTimeRange) ? CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration) : aTimeRange;

    AVMutableComposition*       composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack*  videoTrack = [self insertTimeRange:timeRange ofAsset:aVideoAsset inComposition:composition atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, aTimeRange.duration);

    AVMutableVideoCompositionLayerInstruction*  videolayerInstruction = [self orientVideoAsset:aVideoAsset videoTrack:videoTrack atTime:kCMTimeZero totalDuration:aTimeRange.duration];
    mainInstruction.layerInstructions = @[videolayerInstruction];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);

    [self applyVideoEffectsToComposition:mainCompositionInst size:composition.naturalSize];
    [self exportComposition:composition videoComposition:mainCompositionInst];
}

- (AVMutableCompositionTrack *)insertTimeRange:(CMTimeRange)timeRange ofAsset:(AVAsset *)asset inComposition:(AVMutableComposition *)composition atTime:(CMTime)time
{
    AVMutableCompositionTrack*  videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:timeRange ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
    
    if (!self.muteAudio)
    {
        AVMutableCompositionTrack*  audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:timeRange ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
    }
    
    return videoTrack;
}

- (AVMutableVideoCompositionLayerInstruction *)orientVideoAsset:(AVAsset *)asset videoTrack:(AVAssetTrack *)videoTrack atTime:(CMTime)time totalDuration:(CMTime)duration
{
    AVMutableVideoCompositionLayerInstruction*  videoTrackLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack*                               videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    BOOL                                        isVideoAssetPortrait  = NO;
    CGAffineTransform                           videoTransform = videoAssetTrack.preferredTransform;
    
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
        isVideoAssetPortrait = YES;
    
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)
        isVideoAssetPortrait = YES;
    
    CGFloat assetScaleToFitRatio = 320.0 / videoAssetTrack.naturalSize.width;
    if (isVideoAssetPortrait)
    {
        assetScaleToFitRatio = 320.0 / videoAssetTrack.naturalSize.height;
        CGAffineTransform   assetScaleFactor = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
        [videoTrackLayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, assetScaleFactor) atTime:time];
    }
    else
    {
        CGAffineTransform assetScaleFactor = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
        [videoTrackLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(videoAssetTrack.preferredTransform, assetScaleFactor), CGAffineTransformMakeTranslation(0, 160)) atTime:time];
    }
    
    [videoTrackLayerInstruction setOpacity:0.0 atTime:duration];
    
    return videoTrackLayerInstruction;
}

- (void)exportComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition
{
    AVAssetExportSession*   exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = [self exportFileURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComposition;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if (session.status == AVAssetExportSessionStatusCompleted)
    {
        [self processVideoDidFinishWithURL:session.outputURL];
    }
}

- (NSURL *)exportFileURL
{
    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video-XXXXXX.mov"];
    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);

    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemps(tempFileNameCString, 4);
    
    close(fileDescriptor);
    
    NSString *tempFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString length:strlen(tempFileNameCString)];
    free(tempFileNameCString);
    
    return [NSURL fileURLWithPath:tempFileName];
}

@end
