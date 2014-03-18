//
//  VRemixTrimViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MediaPlayer;

#import "VRemixTrimViewController.h"
#import "VRemixStitchViewController.h"
#import "VCVideoPlayerView.h"
#import "VRemixVideoRangeSlider.h"

@interface VRemixTrimViewController ()  <VCVideoPlayerDelegate, VRemixVideoRangeSliderDelegate>
@property (nonatomic, weak)     IBOutlet    VCVideoPlayerView*  previewView;;
@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;

@property (nonatomic, weak)     IBOutlet    UIButton*           rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           muteButton;

@property (nonatomic, weak)     IBOutlet    UIView*             trimControlContainer;
@property (nonatomic, strong)   VRemixVideoRangeSlider*         trimSlider;

@property (nonatomic, strong)   id                              periodicTimeObserver;

@property (nonatomic)           BOOL                            sliderTouched;
@property (nonatomic, assign)   CGFloat                         start;
@property (nonatomic, assign)   CGFloat                         stop;
@end

@implementation VRemixTrimViewController

+ (UIViewController *)remixViewControllerWithAsset:(AVURLAsset *)asset
{
    UINavigationController*     remixViewController =   [[UIStoryboard storyboardWithName:@"VideoRemix" bundle:nil] instantiateInitialViewController];
    VRemixTrimViewController*   rootViewController  =   (VRemixTrimViewController *)remixViewController.topViewController;
    rootViewController.sourceAsset = asset;
    
    return remixViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.start  =   0.0;
    self.stop   =   0.0;
    
    self.playBackSpeed  =   kRemixPlaybackNormalSpeed;
    self.playbackLooping  =   kRemixLoopingNone;
    
    [self.previewView.player setSmoothLoopItemByUrl:self.sourceAsset.URL smoothLoopCount:1];
    self.previewView.player.shouldLoop = YES;
    self.previewView.player.delegate = self;
    
    [self.previewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.previewView.userInteractionEnabled = YES;
    
    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove) forControlEvents:UIControlEventTouchDragInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    
    self.trimSlider = [[VRemixVideoRangeSlider alloc] initWithFrame:self.trimControlContainer.frame videoUrl:self.sourceAsset];
    self.trimSlider.bubbleText.font = [UIFont systemFontOfSize:12];
    [self.trimSlider setPopoverBubbleWidth:120 height:60];
    
    self.trimSlider.delegate = self;
    [self.trimControlContainer addSubview:self.trimSlider];

//    // Yellow
//    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
//    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
//
//    // Purple
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 1];
//
//    // Gray
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.945 green: 0.945 blue: 0.945 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.806 green: 0.806 blue: 0.806 alpha: 1];
//
//    // Green
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.725 green: 0.879 blue: 0.745 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.449 green: 0.758 blue: 0.489 alpha: 1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds(self.previewView.player.playableDuration)];
    self.currentTimeLabel.text = [self secondsToMMSS:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.previewView.player.isPlaying)
        [self.previewView.player pause];
    
    [self.previewView.player removeTimeObserver:self.periodicTimeObserver];
}

#pragma mark - SCVideoPlayerDelegate

- (void) videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
{
    CMTime endTime = CMTimeConvertScale(self.previewView.player.currentItem.asset.duration, self.previewView.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    if (CMTimeCompare(endTime, kCMTimeZero) != 0)
    {
        double normalizedTime = (double)self.previewView.player.currentTime.value / (double)endTime.value;
        self.scrubber.value = normalizedTime;
    }

    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
}

#pragma mark - VRemixVideoRangeSliderDelegate

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.start = leftPosition;
    self.stop = rightPosition;
//    self.timeLabel.text = [NSString stringWithFormat:@"%f - %f", leftPosition, rightPosition];
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self trimVideo:self.sourceAsset startTrim:self.start endTrim:self.stop];
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.muteAudio = button.selected;
    self.previewView.player.muted = self.muteAudio;
    
    if (self.muteAudio)
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
    else
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kRemixPlaybackNormalSpeed)
    {
        self.playBackSpeed = kRemixPlaybackDoubleSpeed;
        self.previewView.player.rate = 2.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kRemixPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kRemixPlaybackHalfSpeed;
        self.previewView.player.rate = 0.5;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kRemixPlaybackHalfSpeed)
    {
        self.playBackSpeed = kRemixPlaybackNormalSpeed;
        self.previewView.player.rate = 1.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kRemixLoopingNone)
    {
        self.playbackLooping = kRemixLoopingLoop;
        self.previewView.player.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kRemixLoopingLoop)
    {
        self.playbackLooping = kRemixLoopingNone;
        self.previewView.player.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
}

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.previewView.player.isPlaying)
        [self.previewView.player play];
    else
        [self.previewView.player pause];
}

-(void)scrubberDidStartMoving
{
}

-(void)scrubberDidMove
{
    [self.previewView.player seekToTime:CMTimeMake(self.scrubber.value, self.previewView.player.currentTime.timescale)];
}

-(void)scrubberDidEndMoving
{
    [self.previewView.player seekToTime:CMTimeMake(self.scrubber.value, self.previewView.player.currentTime.timescale)];
//    [self generateThumbnailsForTime];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toStitch"])
    {
        VRemixStitchViewController*     stitchViewController = (VRemixStitchViewController *)segue.destinationViewController;
        stitchViewController.sourceAsset = self.outputAsset;
        stitchViewController.muteAudio = self.muteAudio;
        stitchViewController.playBackSpeed = self.playBackSpeed;
        stitchViewController.playbackLooping = self.playbackLooping;
    }
}

#pragma mark - Support

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    self.outputAsset = [[AVURLAsset alloc] initWithURL:aURL options:nil];
    [self performSegueWithIdentifier:@"toStich" sender:self];
}

- (void)trimVideo:(AVURLAsset *)assetToTrim startTrim:(CGFloat)startTrim endTrim:(CGFloat)endTrim
{
    NSArray*    compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:assetToTrim];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        AVAssetExportSession*   exportSession   =   [[AVAssetExportSession alloc] initWithAsset:assetToTrim presetName:AVAssetExportPresetPassthrough];
        
        exportSession.outputURL = [self exportFileURL];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        CMTime start = CMTimeMakeWithSeconds(startTrim, assetToTrim.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(endTrim - startTrim, assetToTrim.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", exportSession.error.localizedDescription);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                    
                default:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self exportDidFinish:exportSession];
                    });
                    break;
            }
        }];
    }
}

-(NSString *)secondsToMMSS:(double)seconds
{
    NSInteger time = floor(seconds);
    NSInteger hh = time / 3600;
    NSInteger mm = (time / 60) % 60;
    NSInteger ss = time % 60;
    if (hh > 0)
        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
    else
        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
}

@end
