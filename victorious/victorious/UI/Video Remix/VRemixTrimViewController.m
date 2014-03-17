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
#import "SCVideoPlayerView.h"

@interface VRemixTrimViewController ()  <SCVideoPlayerDelegate>
@property (nonatomic, assign)   CGFloat                         start;
@property (nonatomic, assign)   CGFloat                         stop;

@property (nonatomic, strong)   AVAssetImageGenerator*          imageGenerator;
@property (nonatomic, strong)   NSMutableArray*                 thumbnails;
@property (nonatomic, strong)   NSMutableArray*                 thumbnailTimes;

@property (nonatomic, weak)     IBOutlet    SCVideoPlayerView*  previewView;;
@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;

@property (nonatomic, strong)   id                              periodicTimeObserver;
@property (nonatomic)           BOOL                            sliderTouched;

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
    
    self.thumbnails = [[NSMutableArray alloc] initWithCapacity:10.0];
    self.thumbnailTimes = [[NSMutableArray alloc] initWithCapacity:10.0];

    [self.previewView.player setSmoothLoopItemByUrl:self.sourceAsset.URL smoothLoopCount:1];
    self.previewView.player.shouldLoop = YES;
    self.previewView.player.delegate = self;
    
    [self.previewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.previewView.userInteractionEnabled = YES;
    
    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove) forControlEvents:UIControlEventTouchDragInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[self.sourceAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.sourceAsset];
        self.imageGenerator.maximumSize = CGSizeMake(100.0, 100.0);
    }
    
    [self.thumbnails removeAllObjects];
    [self.thumbnailTimes removeAllObjects];
    
    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds(self.previewView.player.playableDuration)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.previewView.player.isPlaying)
        [self.previewView.player pause];
    
    [self.previewView.player removeTimeObserver:self.periodicTimeObserver];
}

#pragma mark - SCVideoPlayerDelegate

- (void) videoPlayer:(SCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
{
    CMTime endTime = CMTimeConvertScale(self.previewView.player.currentItem.asset.duration, self.previewView.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    if (CMTimeCompare(endTime, kCMTimeZero) != 0)
    {
        double normalizedTime = (double)self.previewView.player.currentTime.value / (double)endTime.value;
        self.scrubber.value = normalizedTime;
    }

    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self trimVideo:self.sourceAsset startTrim:self.start endTrim:self.stop];
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
    [self generateThumbnailsForTime];
}

#pragma mark - Video Processing

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    self.outputAsset = [[AVURLAsset alloc] initWithURL:aURL options:nil];
    [self performSegueWithIdentifier:@"toStich" sender:self];
}

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

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.muteAudio = button.selected;
    self.previewView.player.muted = self.muteAudio;
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kRemixPlaybackNormalSpeed)
    {
        self.playBackSpeed = kRemixPlaybackDoubleSpeed;
        self.previewView.player.rate = 2.0;
    }
    else if (self.playBackSpeed == kRemixPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kRemixPlaybackHalfSpeed;
        self.previewView.player.rate = 0.5;
    }
    else if (self.playBackSpeed == kRemixPlaybackHalfSpeed)
    {
        self.playBackSpeed = kRemixPlaybackNormalSpeed;
        self.previewView.player.rate = 1.0;
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kRemixLoopingNone)
    {
        self.playbackLooping = kRemixLoopingLoop;
        self.previewView.player.shouldLoop = YES;
    }
    else if (self.playbackLooping == kRemixLoopingLoop)
    {
        self.playbackLooping = kRemixLoopingNone;
        self.previewView.player.shouldLoop = NO;
    }
}

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.previewView.player.isPlaying)
        [self.previewView.player play];
    else
        [self.previewView.player pause];
}

#pragma mark - Support

- (void)generateThumbnailsForTime
{
    CGFloat currentTimeInSeconds    =   CMTimeGetSeconds(self.previewView.player.currentTime);
    CGFloat endTimeInSeconds        =   CMTimeGetSeconds(CMTimeConvertScale(self.previewView.player.currentItem.asset.duration, self.previewView.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero));
    CGFloat interval                =   15.0;
    CGFloat start                   =   currentTimeInSeconds - interval;
    CGFloat end                     =   currentTimeInSeconds + interval;
    
    if (end < endTimeInSeconds)
    {
        end = endTimeInSeconds;
        start = end - interval;
    }
    
    if (start < 0)
    {
        start = 0;
        end = start + interval;
    }
    
    CMTimeRange range               =   CMTimeRangeFromTimeToTime(CMTimeMake(start, self.previewView.player.currentTime.timescale), CMTimeMake(end, self.previewView.player.currentTime.timescale));
    [self generateThumnailsForRange:range];
}

- (void)generateThumnailsForRange:(CMTimeRange)timeRange;
{
    Float64             duration    = CMTimeGetSeconds(timeRange.duration);
    NSMutableArray*     times       = [[NSMutableArray alloc] initWithCapacity:10.0];
    
    for (CMTime aTime = timeRange.start; CMTimeRangeContainsTime(timeRange, aTime); aTime = CMTimeAdd(aTime, CMTimeMake(duration / 10.0, timeRange.start.timescale)))
    {
        [times addObject:[NSValue valueWithCMTime:aTime]];
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
    {
//        [self.thumbnails addObject:image];
//        [self.thumbnailTimes addObject:[NSValue valueWithCMTime:actualTime]];
        //  set strip view to range
    }];
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
    if(hh > 0)
        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
    else
        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
}

@end
