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
#import "MBProgressHUD.h"

@interface VRemixTrimViewController ()  <VCVideoPlayerDelegate, VRemixVideoRangeSliderDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;

@property (nonatomic, weak)     IBOutlet    UIView*             trimControlContainer;
@property (nonatomic, strong)   VRemixVideoRangeSlider*         trimSlider;

@property (nonatomic, strong)   AVURLAsset*                     sourceAsset;
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
    
    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    
    self.trimSlider = [[VRemixVideoRangeSlider alloc] initWithFrame:self.trimControlContainer.bounds videoUrl:self.sourceURL];
    self.trimSlider.bubbleText.font = [UIFont systemFontOfSize:12];
    [self.trimSlider setPopoverBubbleWidth:120 height:60];
    
    self.trimSlider.delegate = self;
    [self.trimControlContainer addSubview:self.trimSlider];
    
    [self.scrubber setThumbImage:[UIImage imageNamed:@"cameraScrubberIndicator"] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds([self playerItemDuration])];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //  Disable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //  Enable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //  Disable iOS 7 Back Gesture
    return NO;
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

    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds([self playerItemDuration])];
    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
}

#pragma mark - VRemixVideoRangeSliderDelegate

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startSeconds = leftPosition;
    self.previewView.player.startSeconds = leftPosition;
    
    self.endSeconds = rightPosition;
    self.previewView.player.endSeconds = rightPosition;

    double time = CMTimeGetSeconds([self.previewView.player currentTime]);
    if (time < leftPosition)
        [self.previewView.player seekToTime:CMTimeMakeWithSeconds(leftPosition, NSEC_PER_SEC)];
    if (time > rightPosition)
        [self.previewView.player seekToTime:CMTimeMakeWithSeconds(leftPosition, NSEC_PER_SEC)];
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.previewView.player.isPlaying)
        [self.previewView.player pause];

    MBProgressHUD*  hud =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Just a moment";
    hud.detailsLabelText = @"Trimming Video...";

    NSURL*      target  =   [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"trimmedMovieSegment"] stringByAppendingPathExtension:@"mp4"] isDirectory:NO];
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

        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                switch ([self.exportSession status])
                {
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                        self.targetURL = nil;
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"Export canceled");
                        self.targetURL = nil;
                        break;
                    default:
                        NSLog(@"Export Complete");
                        self.targetURL = target;
                        [self performSegueWithIdentifier:@"toStitch" sender:self];
                        break;
                }
            });
        }];
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
        stitchViewController.parentID = self.parentID;
    }
}

#pragma mark - Support

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
