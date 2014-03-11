//
//  VAbstractVideoEditorViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractVideoEditorViewController.h"

@interface VAbstractVideoEditorViewController ()    <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    CMTimeRange             timeRange = CMTIMERANGE_IS_EMPTY(aTimeRange) ? CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration) : aTimeRange;

    AVMutableComposition*   composition = [[AVMutableComposition alloc] init];

    AVMutableCompositionTrack*  videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:timeRange ofTrack:[[aVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    if (self.addAudio)
    {
        AVMutableCompositionTrack*  audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:timeRange ofTrack:[[aVideoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, aTimeRange.duration);

    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[aVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation  = UIImageOrientationUp;
    
    BOOL isVideoAssetPortrait  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
    {
        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)
    {
        videoAssetOrientation =  UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)
    {
        videoAssetOrientation =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
    {
        videoAssetOrientation = UIImageOrientationDown;
    }
    
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:timeRange.duration];

    mainInstruction.layerInstructions = @[videolayerInstruction];
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //  mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    //  mainCompositionInst.renderSize = CGSizeMake(640, 640);

    CGSize naturalSize;
    if(isVideoAssetPortrait)
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    else
        naturalSize = videoAssetTrack.naturalSize;

    mainCompositionInst.renderSize = CGSizeMake(naturalSize.width, naturalSize.height);

    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];

    AVAssetExportSession*   exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = [self exportFileURL];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
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

#pragma mark - Video Selection Support

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (controller == nil))
    {
        return NO;
    }
    
    UIImagePickerController*    picker  = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];

    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [controller presentViewController:picker animated:YES completion:nil];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (CFStringCompare((__bridge_retained CFStringRef)info[UIImagePickerControllerMediaType], kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        [self didSelectVideo:[AVAsset assetWithURL:info[UIImagePickerControllerMediaURL]]];
    }
}

- (void)didSelectVideo:(AVAsset *)asset
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
