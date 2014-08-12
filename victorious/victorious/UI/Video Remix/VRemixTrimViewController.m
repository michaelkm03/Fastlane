//
//  VRemixTrimViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MediaPlayer;

#import "VAnalyticsRecorder.h"
#import "VElapsedTimeFormatter.h"
#import "VRemixTrimViewController.h"
#import "VRemixStitchViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VCameraPublishViewController.h"
#import "VMediaPreviewViewController.h"
#import "VRemixVideoRangeSlider.h"
#import "UIImage+Cropping.h"
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
    
    self.currentTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.totalTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.totalTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:[self playerItemDuration]];
    self.currentTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:CMTimeMakeWithSeconds(0, 1)];
    
    double interval = .1f;
    double duration = CMTimeGetSeconds([self playerItemDuration]);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		interval = 0.5f * duration / width;
	}

    __weak  VRemixTrimViewController*   weakSelf    =   self;
	self.timeObserver = [self.videoPlayerViewController.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Remix Trim"];
    
    //  Disable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
    
    //  Enable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    [self.videoPlayerViewController.player removeTimeObserver:self.timeObserver];
    [self.trimSlider cancel];
}

#pragma mark - Properties

- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = self.videoPlayerViewController.player.currentItem;
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

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    CMTime endTime = CMTimeConvertScale([self playerItemDuration], self.videoPlayerViewController.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    if (CMTimeCompare(endTime, kCMTimeZero) != 0)
    {
        double normalizedTime = (double)self.videoPlayerViewController.player.currentTime.value / (double)endTime.value;
        self.scrubber.value = normalizedTime;
    }

    self.totalTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:[self playerItemDuration]];
    self.currentTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:time];
}

#pragma mark - VRemixVideoRangeSliderDelegate

- (void)videoRange:(VRemixVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startSeconds = leftPosition;
    self.videoPlayerViewController.startSeconds = leftPosition;
    
    self.endSeconds = rightPosition;
    self.videoPlayerViewController.endSeconds = rightPosition;

    double time = CMTimeGetSeconds([self.videoPlayerViewController.player currentTime]);
    if (time < leftPosition)
        [self.videoPlayerViewController.player seekToTime:CMTimeMakeWithSeconds(leftPosition, NSEC_PER_SEC)];
    if (time > rightPosition)
        [self.videoPlayerViewController.player seekToTime:CMTimeMakeWithSeconds(leftPosition, NSEC_PER_SEC)];
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.videoPlayerViewController.isPlaying)
        [self.videoPlayerViewController.player pause];

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

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)takeSnapShotAction:(id)sender
{
    NSLog(@"\n\n-----\nTaking An Image Snapshot\n-----\n\n");
    
    // Pause the Current Video If It Is Playing
    if (self.videoPlayerViewController.isPlaying)
        [self.videoPlayerViewController.player pause];

    // Get the Time of the Current Frame
    CMTime currentTime = [self.videoPlayerViewController.player currentTime];
    CMTime actualTime;
    NSError *error = nil;
    
    
    
    // Create A File Target
    NSURL *target = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"trimmedMovieSnapShot"] stringByAppendingPathExtension:@"jpg"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];
    
    // Create an AVAssetImageGenerator
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:self.sourceURL options:nil];
    AVAssetImageGenerator *imgGen = [[AVAssetImageGenerator alloc] initWithAsset:anAsset];
    //imgGen.appliesPreferredTrackTransform = YES;

    // Using The AVAssetImageGenerator, Capture the Video Frame and Store it In A UIImage
    CGImageRef imgRef = [imgGen copyCGImageAtTime:currentTime actualTime:&actualTime error:&error];
    UIImage *thumb = [[[UIImage alloc] initWithCGImage:imgRef] squareImageScaledToSize:640.0];
    CGImageRelease(imgRef);
    
    // Write the Captured Image to Disk
    [UIImageJPEGRepresentation(thumb, VConstantJPEGCompressionQuality) writeToURL:target atomically:YES];
    self.targetURL = target;
    
    VMediaPreviewViewController *previewViewController = [VMediaPreviewViewController previewViewControllerForMediaAtURL:target];
    previewViewController.mediaURL = self.targetURL;
    previewViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        
        if (finished)
        {
            // Push the Captured Image to the Publish Screen
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.mediaURL = capturedMediaURL;
            publishViewController.playBackSpeed = self.playBackSpeed;
            publishViewController.playbackLooping = self.playbackLooping;
            publishViewController.parentID = self.parentID;
            publishViewController.previewImage = previewImage;
            publishViewController.completion = ^(BOOL complete)
            {
                if (complete)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            };
            
            // Push the Publish Screen onto the Navigation Stack
            [self.navigationController pushViewController:publishViewController animated:YES];

        }
    };

    [self.navigationController pushViewController:previewViewController animated:YES];
    
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
		double time = CMTimeGetSeconds([self.videoPlayerViewController.player currentTime]);
		[self.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

@end
