//
//  VRemixStitchViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixStitchViewController.h"
#import "VCameraPublishViewController.h"

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
    CMTime                  startTime   = kCMTimeZero;

    AVMutableCompositionTrack*  beforeVideoTrack = nil;
    if (self.beforeAsset)
    {
        beforeVideoTrack = [self insertTimeRange:CMTimeRangeMake(kCMTimeZero, beforeAsset.duration) ofAsset:beforeAsset inComposition:composition atTime:startTime];
        startTime = CMTimeAdd(startTime, beforeAsset.duration);
    }

    AVMutableCompositionTrack*  mainVideoTrack = [self insertTimeRange:CMTimeRangeMake(kCMTimeZero, anAsset.duration) ofAsset:anAsset inComposition:composition atTime:startTime];
    startTime = CMTimeAdd(startTime, anAsset.duration);
    
    AVMutableCompositionTrack*  afterVideoTrack = nil;
    if (self.afterAsset)
    {
        afterVideoTrack = [self insertTimeRange:CMTimeRangeMake(kCMTimeZero, afterAsset.duration) ofAsset:afterAsset inComposition:composition atTime:startTime];
        startTime = CMTimeAdd(startTime, afterAsset.duration);
    }

    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, startTime);

    NSMutableArray*     instructions    =   [[NSMutableArray alloc] initWithCapacity:3];

    startTime   =   kCMTimeZero;
    if (beforeVideoTrack)
    {
        AVMutableVideoCompositionLayerInstruction*  beforeVideoTrackLayerInstruction = [self orientVideoAsset:beforeAsset videoTrack:beforeVideoTrack atTime:startTime totalDuration:beforeAsset.duration];
        [instructions addObject:beforeVideoTrackLayerInstruction];
        startTime = CMTimeAdd(startTime, beforeAsset.duration);
    }

    AVMutableVideoCompositionLayerInstruction*  mainVideoTracklayerInstruction = [self orientVideoAsset:anAsset videoTrack:mainVideoTrack atTime:startTime totalDuration:CMTimeAdd(startTime, anAsset.duration)];
    [instructions addObject:mainVideoTracklayerInstruction];
    startTime = CMTimeAdd(startTime, anAsset.duration);

    if (afterVideoTrack)
    {
        AVMutableVideoCompositionLayerInstruction*  afterVideoTrackLayerInstruction = [self orientVideoAsset:afterAsset videoTrack:afterVideoTrack atTime:startTime totalDuration:CMTimeAdd(startTime, afterAsset.duration)];
        [instructions addObject:afterVideoTrackLayerInstruction];
        startTime = CMTimeAdd(startTime, afterAsset.duration);
    }

    mainInstruction.layerInstructions = instructions;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);

    [self exportComposition:composition videoComposition:mainCompositionInst];
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
    
}

- (IBAction)selectAfterAsset:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
    
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
    if ([segue.identifier isEqualToString:@"toCaption"])
    {
        VCameraPublishViewController*     publishViewController = (VCameraPublishViewController *)segue.destinationViewController;
//        publishViewController = [AVAsset assetWithURL:self.outputURL];
//        publishViewController = self.addAudio;
    }
}

@end
