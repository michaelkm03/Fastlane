//
//  VRemixStitchViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixStitchViewController.h"
#import "VRemixPublishViewController.h"

@interface VRemixStitchViewController ()
@property (nonatomic, strong)   AVAsset*    beforeAsset;
@property (nonatomic, strong)   AVAsset*    afterAsset;

@property (nonatomic)           BOOL        selectingBeforeURL;
@property (nonatomic)           BOOL        selectingAfterURL;
@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self processVideo:self.sourceAsset beforeAsset:self.beforeAsset afterAsset:self.afterAsset];
}

- (void)processVideo:(AVAsset *)anAsset beforeAsset:(AVAsset *)beforeAsset afterAsset:(AVAsset *)afterAsset
{
    AVMutableComposition*   composition = [[AVMutableComposition alloc] init];

    if (self.beforeAsset)
    {
        AVMutableCompositionTrack*  beforeVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [beforeVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.beforeAsset.duration) ofTrack:[[self.beforeAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

        if (self.addAudio)
        {
            AVMutableCompositionTrack*  beforeAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [beforeAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.beforeAsset.duration) ofTrack:[[self.beforeAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
    }

    AVMutableCompositionTrack*  videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration) ofTrack:[[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    if (self.addAudio)
    {
        AVMutableCompositionTrack*  audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration) ofTrack:[[anAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }

    if (self.afterAsset)
    {
        AVMutableCompositionTrack*  afterVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [afterVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, afterAsset.duration) ofTrack:[[self.afterAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        if (self.addAudio)
        {
            AVMutableCompositionTrack*  afterAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [afterAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.afterAsset.duration) ofTrack:[[self.afterAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
    }

    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    CMTime  totalDuration = anAsset.duration;
    if (self.beforeAsset)
        totalDuration = CMTimeAdd(totalDuration, self.beforeAsset.duration);
    if (self.afterAsset)
        totalDuration = CMTimeAdd(totalDuration, self.afterAsset.duration);
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);

//    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    AVAssetTrack *videoAssetTrack = [[aVideoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    UIImageOrientation videoAssetOrientation  = UIImageOrientationUp;
//    
//    BOOL isVideoAssetPortrait  = NO;
//    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
//    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)
//    {
//        videoAssetOrientation = UIImageOrientationRight;
//        isVideoAssetPortrait = YES;
//    }
//    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)
//    {
//        videoAssetOrientation =  UIImageOrientationLeft;
//        isVideoAssetPortrait = YES;
//    }
//    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)
//    {
//        videoAssetOrientation =  UIImageOrientationUp;
//    }
//    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0)
//    {
//        videoAssetOrientation = UIImageOrientationDown;
//    }
//    
//    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
//    [videolayerInstruction setOpacity:0.0 atTime:timeRange.duration];
//    
//    mainInstruction.layerInstructions = @[beforeLayerInstruction, mainLayerInstruction, afterLayerInstruction];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
//  mainCompositionInst.frameDuration = CMTimeMake(1, 30);
//  mainCompositionInst.renderSize = CGSizeMake(640, 640);

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

////FIXING ORIENTATION//
//AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
//AVAssetTrack *FirstAssetTrack = [[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
//BOOL  isFirstAssetPortrait_  = NO;
//CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
//if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
//if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
//if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
//if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
//CGFloat FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.width;
//if(isFirstAssetPortrait_){
//    FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.height;
//    CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
//    [FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
//}else{
//    CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
//    [FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
//}
//[FirstlayerInstruction setOpacity:0.0 atTime:firstAsset.duration];
//
//AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
//AVAssetTrack *SecondAssetTrack = [[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//UIImageOrientation SecondAssetOrientation_  = UIImageOrientationUp;
//BOOL  isSecondAssetPortrait_  = NO;
//CGAffineTransform secondTransform = SecondAssetTrack.preferredTransform;
//if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)  {SecondAssetOrientation_= UIImageOrientationRight; isSecondAssetPortrait_ = YES;}
//if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)  {SecondAssetOrientation_ =  UIImageOrientationLeft; isSecondAssetPortrait_ = YES;}
//if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)   {SecondAssetOrientation_ =  UIImageOrientationUp;}
//if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {SecondAssetOrientation_ = UIImageOrientationDown;}
//CGFloat SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.width;
//if(isSecondAssetPortrait_){
//    SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.height;
//    CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
//    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor) atTime:firstAsset.duration];
//}else{
//    ;
//    CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
//    [SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:firstAsset.duration];
//}
//
//
//MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
//

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    self.outputURL = aURL;
    [self performSegueWithIdentifier:@"toPublish" sender:self];
}


- (IBAction)selectBeforeAsset:(id)sender
{
    self.selectingBeforeURL = YES;
    self.selectingAfterURL = NO;
    
    [self startMediaBrowserFromViewController:self];
}

- (IBAction)selectAfterAsset:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
    
    [self startMediaBrowserFromViewController:self];
}

- (void)didSelectVideo:(AVAsset *)asset
{
    if (self.selectingBeforeURL)
        self.beforeAsset = asset;
    else if (self.selectingAfterURL)
        self.afterAsset = asset;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPublish"])
    {
        VRemixPublishViewController*     stitchViewController = (VRemixPublishViewController *)segue.destinationViewController;
        stitchViewController.sourceAsset = [AVAsset assetWithURL:self.outputURL];
        stitchViewController.addAudio = self.addAudio;
    }
}

@end
