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
#import "VThemeManager.h"

@interface VRemixTrimViewController ()  <VCVideoPlayerDelegate, VRemixVideoRangeSliderDelegate>

@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;

@property (nonatomic, weak)     IBOutlet    UIButton*           rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           muteButton;

@property (nonatomic, weak)     IBOutlet    UIImageView*        playCircle;
@property (nonatomic, weak)     IBOutlet    UIImageView*        playButton;

@property (nonatomic, weak)     IBOutlet    UIView*             trimControlContainer;
@property (nonatomic, strong)   VRemixVideoRangeSlider*         trimSlider;

@property (nonatomic, strong)   AVURLAsset*                     sourceAsset;
@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;
@property (nonatomic, strong)   id                              timeObserver;

@property (nonatomic, strong)   AVAssetExportSession*           exportSession;

@property (nonatomic)           CGFloat                         startSeconds;
@property (nonatomic)           CGFloat                         endSeconds;

@end

@implementation VRemixTrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.sourceAsset = [AVURLAsset assetWithURL:self.sourceURL];
    self.playBackSpeed = kVPlaybackNormalSpeed;
    self.playbackLooping = kVLoopOnce;
    
    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving:) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventTouchDragInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventValueChanged];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpOutside];
    
    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    
    self.trimSlider = [[VRemixVideoRangeSlider alloc] initWithFrame:self.trimControlContainer.bounds videoUrl:self.sourceURL];
    self.trimSlider.bubbleText.font = [UIFont systemFontOfSize:12];
    [self.trimSlider setPopoverBubbleWidth:120 height:60];
    
    self.trimSlider.delegate = self;
    [self.trimControlContainer addSubview:self.trimSlider];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds(self.sourceAsset.duration)];
    self.currentTimeLabel.text = [self secondsToMMSS:0];
    
    double interval = .1f;

    double duration = CMTimeGetSeconds([self playerItemDuration]);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		interval = 0.5f * duration / width;
	}

    __weak  VRemixTrimViewController*   weakSelf    =   self;
	self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.previewView.player removeTimeObserver:self.timeObserver];
    
    [self.trimSlider cancel];
}

#pragma mark - Properties

- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = self.previewView.player.currentItem;
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
        return thePlayerItem.duration;
    else
        return kCMTimeInvalid;
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
{
    CMTime endTime = CMTimeConvertScale([self playerItemDuration], self.previewView.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
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
    self.startSeconds = leftPosition;
    self.previewView.player.startSeconds = leftPosition;
    self.endSeconds = rightPosition;
    self.previewView.player.endSeconds = rightPosition;
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    NSURL*      target  =   [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"movieSegment"] stringByAppendingPathExtension:@"mp4"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];

    AVAsset*        anAsset = [[AVURLAsset alloc] initWithURL:self.sourceURL options:nil];
    NSArray*        compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        self.exportSession  =   [[AVAssetExportSession alloc] initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];

        self.exportSession.outputURL = target;
        self.exportSession.outputFileType = AVFileTypeMPEG4;

        CMTime start = CMTimeMakeWithSeconds(self.startSeconds, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.endSeconds - self.startSeconds, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;

//        self.myActivityIndicator.hidden = NO;
//        [self.myActivityIndicator startAnimating];
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"Export Complete");
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.myActivityIndicator stopAnimating];
//                        self.myActivityIndicator.hidden = YES;
                        self.targetURL = target;
                    });
                    break;
            }
        }];
    }

    [self performSegueWithIdentifier:@"toStitch" sender:self];
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.shouldMuteAudio = button.selected;
    self.previewView.player.muted = self.shouldMuteAudio;
    
    if (self.shouldMuteAudio)
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
    else
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kVPlaybackNormalSpeed)
    {
        self.playBackSpeed = kVPlaybackDoubleSpeed;
        [self.previewView.player setRate:2.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kVPlaybackHalfSpeed;
        [self.previewView.player setRate:0.5];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackHalfSpeed)
    {
        self.playBackSpeed = kVPlaybackNormalSpeed;
        [self.previewView.player setRate:1.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kVLoopOnce)
    {
        self.playbackLooping = kVLoopRepeat;
        self.previewView.player.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kVLoopRepeat)
    {
        self.playbackLooping = kVLoopOnce;
        self.previewView.player.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
}

-(IBAction)scrubberDidStartMoving:(id)sender
{
    self.restoreAfterScrubbingRate = self.previewView.player.rate;
    [self.previewView.player setRate:0.f];

    [self removePlayerTimeObserver];
}

-(IBAction)scrubberDidMove:(id)sender
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
        return;

    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.scrubber minimumValue];
        float maxValue = [self.scrubber maximumValue];
        float value = [self.scrubber value];
        double time = duration * (value - minValue) / (maxValue - minValue);

        [self.previewView.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    }
}

-(IBAction)scrubberDidEndMoving:(id)sender
{
	if (!self.timeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration))
			return;

		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([self.scrubber bounds]);
			double tolerance = 0.5f * duration / width;

            __weak  VRemixTrimViewController*   weakSelf    =   self;
			self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                             }];
		}
	}

	if (self.restoreAfterScrubbingRate)
	{
		[self.previewView.player setRate:self.restoreAfterScrubbingRate];
		self.restoreAfterScrubbingRate = 0.f;
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toStitch"])
    {
        VRemixStitchViewController*     stitchViewController = (VRemixStitchViewController *)segue.destinationViewController;
        stitchViewController.sourceURL = self.targetURL;
        stitchViewController.shouldMuteAudio = self.shouldMuteAudio;
        stitchViewController.playBackSpeed = self.playBackSpeed;
        stitchViewController.playbackLooping = self.playbackLooping;
    }
}

#pragma mark - Support

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

-(void)removePlayerTimeObserver
{
    if (self.timeObserver)
    {
        [self.previewView.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		self.scrubber.minimumValue = 0.0;
		return;
	}

	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration) && (duration > 0))
	{
		float minValue = [self.scrubber minimumValue];
		float maxValue = [self.scrubber maximumValue];
		double time = CMTimeGetSeconds([self.previewView.player currentTime]);
		[self.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

@end
