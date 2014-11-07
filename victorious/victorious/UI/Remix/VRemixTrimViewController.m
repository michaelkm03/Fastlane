//
//  VRemixTrimViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

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

@import AVFoundation;

@interface VRemixTrimViewController ()  <VRemixVideoRangeSliderDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak)     IBOutlet    UIView             *trimControlContainer;
@property (nonatomic, strong)   VRemixVideoRangeSlider         *trimSlider;

@property (nonatomic, strong)   AVURLAsset                     *sourceAsset;

@property (nonatomic, strong)   AVAssetExportSession           *exportSession;

@property (nonatomic)           CGFloat                         startSeconds;
@property (nonatomic)           CGFloat                         endSeconds;

@end

@implementation VRemixTrimViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.sourceAsset = [AVURLAsset assetWithURL:self.sourceURL];
    self.playBackSpeed = VPlaybackNormalSpeed;
    self.playbackLooping = VLoopRepeat;
    
    self.trimSlider = [[VRemixVideoRangeSlider alloc] initWithFrame:self.trimControlContainer.bounds videoAsset:self.videoPlayerViewController.player.currentItem.asset];
    self.trimSlider.bubbleText.font = [UIFont systemFontOfSize:12];
    [self.trimSlider setPopoverBubbleWidth:120 height:60];
    
    self.trimSlider.delegate = self;
    [self.trimControlContainer addSubview:self.trimSlider];
    
    NSArray *buttons = @[self.takeImageSnapShotButton, self.loopButton, self.rateButton, self.muteButton];
    for (UIButton *button in buttons)
    {
        button.imageView.contentMode = UIViewContentModeCenter;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // To Ensure That The Navigation Bar is Always Present
    [self.navigationController setNavigationBarHidden:NO];
    
    // Set the Custom Next Button
    UIImage *nextButtonImage = [[UIImage imageNamed:@"btnNextArrowWhiteDs"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    UIImage *prevButtonImage = [[UIImage imageNamed:@"btnPrevArrowWhiteDs"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:prevButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Remix Trim"];
    
    //  Disable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Remix Trim"];
    
    //  Enable iOS 7 Back Gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    [self.trimSlider cancel];
}

#pragma mark - Properties

- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = self.videoPlayerViewController.player.currentItem;
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return thePlayerItem.duration;
    }
    else
    {
        return kCMTimeInvalid;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //  Disable iOS 7 Back Gesture
    return NO;
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
    {
        [self.videoPlayerViewController.player seekToTime:CMTimeMakeWithSeconds(leftPosition, [self.videoPlayerViewController.player currentTime].timescale)
                                          toleranceBefore:kCMTimeZero
                                           toleranceAfter:kCMTimeZero];
    }
    
    if (time > rightPosition)
    {
        [self.videoPlayerViewController.player seekToTime:CMTimeMakeWithSeconds(leftPosition, [self.videoPlayerViewController.player currentTime].timescale)
                                          toleranceBefore:kCMTimeZero
                                           toleranceAfter:kCMTimeZero];
    }
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
    }

    MBProgressHUD  *hud =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Just a moment";
    hud.detailsLabelText = @"Trimming Video...";

    NSURL      *target  =   [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"trimmedMovieSegment"] stringByAppendingPathExtension:@"mp4"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];

    AVAsset        *anAsset = [[AVURLAsset alloc] initWithURL:self.sourceURL options:nil];
    NSArray        *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
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

- (IBAction)takeSnapShotAction:(id)sender
{
    // Pause the Current Video If It Is Playing
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
    }

    // Get the Time of the Current Frame
    CMTime currentTime = CMTimeMakeWithSeconds(CMTimeGetSeconds([self.videoPlayerViewController.player currentTime]), [self.videoPlayerViewController.player currentTime].timescale);
    CMTime actualTime, actualRepeat;
    
    // Create A File Target
    NSURL *target = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"trimmedMovieSnapShot"] stringByAppendingPathExtension:@"jpg"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];
    
    // Create an AVAssetImageGenerator
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:self.sourceURL
                                               options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    
    AVAssetImageGenerator *imgGen = [[AVAssetImageGenerator alloc] initWithAsset:anAsset];
    [imgGen setRequestedTimeToleranceBefore:kCMTimeZero];
    [imgGen setRequestedTimeToleranceAfter:kCMTimeZero];

    // Using The AVAssetImageGenerator, Capture the Video Frame and Store it In A UIImage
    CGImageRef imgRef = [imgGen copyCGImageAtTime:currentTime actualTime:&actualTime error:nil];
    UIImage *thumb = [[[UIImage alloc] initWithCGImage:imgRef] squareImageScaledToSize:640.0];
    CGImageRelease(imgRef);
    
    double currentSecs = CMTimeGetSeconds(currentTime);
    double actualSecs = CMTimeGetSeconds(actualTime);
    if (currentSecs != actualSecs)
    {
        imgRef = [imgGen copyCGImageAtTime:actualTime actualTime:&actualRepeat error:nil];
        thumb = [[[UIImage alloc] initWithCGImage:imgRef] squareImageScaledToSize:640.0];
        CGImageRelease(imgRef);

    }
    
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
        VRemixStitchViewController     *stitchViewController = (VRemixStitchViewController *)segue.destinationViewController;
        stitchViewController.sourceURL = self.targetURL;
        stitchViewController.shouldMuteAudio = self.shouldMuteAudio;
        stitchViewController.playBackSpeed = self.playBackSpeed;
        stitchViewController.playbackLooping = self.playbackLooping;
        stitchViewController.parentID = self.parentID;
    }
}

#pragma mark - VCVideoPlayerDelegate methods

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    [super videoPlayer:videoPlayer didPlayToTime:time];
    [self.trimSlider updateScrubberPositionWithTime:time];
}

@end
