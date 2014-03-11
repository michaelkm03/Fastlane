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

    AVMutableCompositionTrack*  beforeVideoTrack = nil;
    if (self.beforeAsset)
    {
        beforeVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [beforeVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.beforeAsset.duration) ofTrack:[[self.beforeAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

        if (self.addAudio)
        {
            AVMutableCompositionTrack*  beforeAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [beforeAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.beforeAsset.duration) ofTrack:[[self.beforeAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
    }

    AVMutableCompositionTrack*  mainVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [mainVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration) ofTrack:[[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    if (self.addAudio)
    {
        AVMutableCompositionTrack*  mainAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [mainAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration) ofTrack:[[anAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }

    AVMutableCompositionTrack*  afterVideoTrack = nil;
    if (self.afterAsset)
    {
        afterVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
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

    NSMutableArray*     instructions    =   [[NSMutableArray alloc] initWithCapacity:3];
    CMTime              duration        =   kCMTimeZero;

    if (beforeVideoTrack)
    {
        AVMutableVideoCompositionLayerInstruction*  beforeVideoTrackLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:beforeVideoTrack];
        AVAssetTrack*                               beforeAssetTrack = [[self.beforeAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        BOOL                                        isBeforeAssetPortrait  = NO;
        CGAffineTransform                           beforeTransform = beforeAssetTrack.preferredTransform;
        
        duration = self.beforeAsset.duration;

        if (beforeTransform.a == 0 && beforeTransform.b == 1.0 && beforeTransform.c == -1.0 && beforeTransform.d == 0)
            isBeforeAssetPortrait = YES;

        if (beforeTransform.a == 0 && beforeTransform.b == -1.0 && beforeTransform.c == 1.0 && beforeTransform.d == 0)
            isBeforeAssetPortrait = YES;
        
        CGFloat beforeAssetScaleToFitRatio = 320.0/beforeAssetTrack.naturalSize.width;
        if (isBeforeAssetPortrait)
        {
            beforeAssetScaleToFitRatio = 320.0/beforeAssetTrack.naturalSize.height;
            CGAffineTransform   beforeAssetScaleFactor = CGAffineTransformMakeScale(beforeAssetScaleToFitRatio, beforeAssetScaleToFitRatio);
            [beforeVideoTrackLayerInstruction setTransform:CGAffineTransformConcat(beforeAssetTrack.preferredTransform, beforeAssetScaleFactor) atTime:kCMTimeZero];
        }
        else
        {
            CGAffineTransform beforeAssetScaleFactor = CGAffineTransformMakeScale(beforeAssetScaleToFitRatio, beforeAssetScaleToFitRatio);
            [beforeVideoTrackLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(beforeAssetTrack.preferredTransform, beforeAssetScaleFactor), CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
        }
        [beforeVideoTrackLayerInstruction setOpacity:0.0 atTime:duration];
        [instructions addObject:beforeVideoTrackLayerInstruction];
    }

    AVMutableVideoCompositionLayerInstruction*  mainVideoTracklayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mainVideoTrack];
    AVAssetTrack*                               mainAssetTrack = [[self.sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    BOOL                                        isMainAssetPortrait = NO;
    CGAffineTransform                           mainTransform = self.sourceAsset.preferredTransform;
    
    if (mainTransform.a == 0 && mainTransform.b == 1.0 && mainTransform.c == -1.0 && mainTransform.d == 0)
        isMainAssetPortrait = YES;
    
    if (mainTransform.a == 0 && mainTransform.b == -1.0 && mainTransform.c == 1.0 && mainTransform.d == 0)
        isMainAssetPortrait = YES;

    CGFloat mainAssetScaleToFitRatio = 320.0/mainAssetTrack.naturalSize.width;
    if (isMainAssetPortrait)
    {
        mainAssetScaleToFitRatio = 320.0/mainAssetTrack.naturalSize.height;
        CGAffineTransform mainAssetScaleFactor = CGAffineTransformMakeScale(mainAssetScaleToFitRatio, mainAssetScaleToFitRatio);
        [mainVideoTracklayerInstruction setTransform:CGAffineTransformConcat(mainAssetTrack.preferredTransform, mainAssetScaleFactor) atTime:duration];
    }
    else
    {
        CGAffineTransform mainAssetScaleFactor = CGAffineTransformMakeScale(mainAssetScaleToFitRatio, mainAssetScaleToFitRatio);
        [mainVideoTracklayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(mainAssetTrack.preferredTransform, mainAssetScaleFactor), CGAffineTransformMakeTranslation(0, 160)) atTime:duration];
    }
    
    duration = CMTimeAdd(duration, self.sourceAsset.duration);

    [mainVideoTracklayerInstruction setOpacity:0.0 atTime:duration];
    [instructions addObject:mainVideoTracklayerInstruction];

    if (afterVideoTrack)
    {
        AVMutableVideoCompositionLayerInstruction*  afterVideoTrackLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:afterVideoTrack];
        AVAssetTrack*                               afterAssetTrack = [[self.afterAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        BOOL                                        isAfterAssetPortrait  = NO;
        CGAffineTransform                           afterTransform = afterAssetTrack.preferredTransform;
        
        if (afterTransform.a == 0 && afterTransform.b == 1.0 && afterTransform.c == -1.0 && afterTransform.d == 0)
            isAfterAssetPortrait = YES;
        
        if (afterTransform.a == 0 && afterTransform.b == -1.0 && afterTransform.c == 1.0 && afterTransform.d == 0)
            isAfterAssetPortrait = YES;

        CGFloat afterAssetScaleToFitRatio = 320.0/afterAssetTrack.naturalSize.width;
        if (isAfterAssetPortrait)
        {
            afterAssetScaleToFitRatio = 320.0/afterAssetTrack.naturalSize.height;
            CGAffineTransform afterAssetScaleFactor = CGAffineTransformMakeScale(afterAssetScaleToFitRatio, afterAssetScaleToFitRatio);
            [afterVideoTrackLayerInstruction setTransform:CGAffineTransformConcat(afterAssetTrack.preferredTransform, afterAssetScaleFactor) atTime:duration];
        }
        else
        {
            CGAffineTransform afterAssetScaleFactor = CGAffineTransformMakeScale(afterAssetScaleToFitRatio, afterAssetScaleToFitRatio);
            [afterVideoTrackLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(afterAssetTrack.preferredTransform, afterAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:duration];
        }

        duration = CMTimeAdd(duration, self.sourceAsset.duration);
        [instructions addObject:afterVideoTrackLayerInstruction];
    }

    mainInstruction.layerInstructions = instructions;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);

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
