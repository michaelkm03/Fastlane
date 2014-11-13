//
//  VRemixStitchViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixStitchViewController.h"
#import "VCameraPublishViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VSettingManager.h"
#import "VConstants.h"
#import "UIView+Masking.h"
#import "VCameraViewController.h"
#import "VThemeManager.h"
#import <MBProgressHUD.h>

static Float64 const kVideoPreviewSnapshotInSeconds = 0.5f;

static void *kExportProgressContext = &kExportProgressContext;

@interface VRemixStitchViewController ()    <VCVideoPlayerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak)     IBOutlet    UIView             *thumbnail;

@property (nonatomic, weak)     IBOutlet    UIView             *beforeButton;
@property (nonatomic, weak)     IBOutlet    UIView             *afterButton;

@property (nonatomic, strong)   AVAssetImageGenerator          *imageGenerator;
@property (nonatomic, strong)   AVAssetExportSession           *exportSession;

@property (nonatomic, strong)   NSURL                          *beforeURL;
@property (nonatomic, strong)   NSURL                          *afterURL;

@property (nonatomic)           BOOL                            selectingBeforeURL;
@property (nonatomic)           BOOL                            selectingAfterURL;

@property (nonatomic, strong) IBOutlet UIView *progressView;
@property (nonatomic, strong) IBOutlet UISlider *progressIndicator;
@property (nonatomic, strong) id progressObserver;
@property (nonatomic, strong) NSTimer *exportTimer;

@property (nonatomic, weak) MBProgressHUD *renderHud;

@end

@implementation VRemixStitchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.targetURL = self.sourceURL;

    [self.thumbnail maskWithImage:[UIImage imageNamed:@"cameraThumbnailMask"]];

    [self setupThumbnailStrip:self.thumbnail withURL:self.sourceURL];

    self.playbackLooping = VLoopRepeat;

    // Setup Progress View
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    [self.progressView setHidden:YES];

    UIImage *trackImage = [[UIImage alloc] init];
    [self.progressIndicator setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    [self.progressIndicator setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    [self.progressIndicator setThumbImage:[UIImage imageNamed:@"remixCurrentTimelineIndicator"] forState:UIControlStateNormal];

    
    [self.beforeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBeforeAssetClicked:)]];
    self.beforeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchLeft"]];
    self.beforeButton.userInteractionEnabled = YES;
    [self.beforeButton maskWithImage:[UIImage imageNamed:@"cameraLeftMask"]];
    
    [self.afterButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAfterAssetClicked:)]];
    self.afterButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchRight"]];
    self.afterButton.userInteractionEnabled = YES;
    [self.afterButton maskWithImage:[UIImage imageNamed:@"cameraRightMask"]];
    
    UIImage *prevButtonImage = [[UIImage imageNamed:@"btnPrevArrowWhiteDs"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:prevButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];

    UIImage *nextButtonImage = [[UIImage imageNamed:@"btnNextArrowWhiteDs"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventRemixStitchDidAppear];
    
    
    // Set Video Playback Rate
    CGFloat rate = 1.0;
    [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    
    if (self.playBackSpeed == VPlaybackDoubleSpeed)
    {
        rate = 2.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == VPlaybackHalfSpeed)
    {
        rate = 0.5;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    
    [self.videoPlayerViewController.player setRate:rate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventRemixStitchDidAppear];
}

#pragma mark - Video Methods

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

- (void)syncProgressIndicator
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.progressIndicator.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        float minValue = [self.progressIndicator minimumValue];
        float maxValue = [self.progressIndicator maximumValue];
        double time = CMTimeGetSeconds([self.videoPlayerViewController.player currentTime]);
        [self.progressIndicator setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    [super videoPlayer:videoPlayer didPlayToTime:time];
    CMTime endTime = CMTimeConvertScale([self playerItemDuration], self.videoPlayerViewController.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    if (CMTimeCompare(endTime, kCMTimeZero) != 0)
    {
        double normalizedTime = (double)self.videoPlayerViewController.player.currentTime.value / (double)endTime.value;
        self.progressIndicator.value = normalizedTime;
    }
}

#pragma mark - Actions

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.videoPlayerViewController.isPlaying)
    {
        [self.videoPlayerViewController.player pause];
    }
    
    VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
    publishViewController.mediaURL = self.targetURL;
    publishViewController.playBackSpeed = self.playBackSpeed;
    publishViewController.playbackLooping = self.playbackLooping;
    publishViewController.parentSequenceID = self.parentSequenceID;
    publishViewController.parentNodeID = self.parentNodeID;

    AVAsset *asset = [AVAsset assetWithURL:self.targetURL];
    AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    assetGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    assetGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    CMTime timeToSample = CMTimeMakeWithSeconds(kVideoPreviewSnapshotInSeconds, asset.duration.timescale);
    CGImageRef imageRef = [assetGenerator copyCGImageAtTime:timeToSample actualTime:NULL error:NULL];
    UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
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
    
    [self.navigationController pushViewController:publishViewController animated:YES];
}

- (IBAction)selectBeforeAssetClicked:(id)sender
{
    self.selectingBeforeURL = YES;
    self.selectingAfterURL = NO;
    
    if (self.beforeURL)
    {
        UIActionSheet  *sheet   =   [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                                  destructiveButtonTitle:NSLocalizedString(@"DeleteButton", @"")
                                                       otherButtonTitles:NSLocalizedString(@"ReplaceVideo", @""), nil];
        [sheet showInView:self.view];
    }
    else
    {
        [self selectAsset];
    }
}

- (IBAction)selectAfterAssetClicked:(id)sender
{
    self.selectingBeforeURL = NO;
    self.selectingAfterURL = YES;
    
    if (self.afterURL)
    {
        UIActionSheet  *sheet   =   [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                                  destructiveButtonTitle:NSLocalizedString(@"DeleteButton", @"")
                                                       otherButtonTitles:NSLocalizedString(@"ReplaceVideo", @""), nil];
        [sheet showInView:self.view];
    }
    else
    {
        [self selectAsset];
    }
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
        if (self.selectingBeforeURL)
        {
            self.beforeURL = nil;
            [self.beforeButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.beforeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchLeft"]];
        }
        
        if (self.selectingAfterURL)
        {
            self.afterURL = nil;
            [self.afterButton.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.afterButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraButtonStitchRight"]];
        }
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        
    }
    else
    {
        [self selectAsset];
    }
}

- (void)selectAsset
{
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToVideo];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [self dismissViewControllerAnimated:YES completion:nil];

        if (finished)
        {
            [self didSelectVideo:capturedMediaURL];
        }
    };

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Timer Target

- (void)updateProgress
{
    self.renderHud.progress = self.exportSession.progress;
}

#pragma mark - Support

- (void)didSelectVideo:(NSURL *)url
{
    if (self.selectingBeforeURL)
    {
        self.beforeURL = url;
        [self.beforeButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.beforeButton withURL:url];
    }
    else if (self.selectingAfterURL)
    {
        self.afterURL = url;
        [self.afterButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupThumbnailStrip:self.afterButton withURL:url];
    }
    
    [self compositeVideo];
}

- (void)compositeVideo
{
    AVMutableComposition       *mutableComposition      =   [AVMutableComposition composition];
    AVMutableCompositionTrack  *videoCompositionTrack   =   [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack  *audioCompositionTrack   =   [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSMutableArray             *instructions            =   [NSMutableArray arrayWithCapacity:3];

    if (self.beforeURL)
    {
        AVMutableVideoCompositionInstruction  *instruction = [self addAssetURL:self.beforeURL videoCompositionTrack:videoCompositionTrack audioCompositionTrack:((self.shouldMuteAudio) ? nil : audioCompositionTrack) atTime:mutableComposition.duration];
        [instructions addObject:instruction];
    }
    
    if (self.sourceURL)
    {
        AVMutableVideoCompositionInstruction  *instruction = [self addAssetURL:self.sourceURL videoCompositionTrack:videoCompositionTrack audioCompositionTrack:((self.shouldMuteAudio) ? nil : audioCompositionTrack) atTime:mutableComposition.duration];
        [instructions addObject:instruction];
    }
    
    if (self.afterURL)
    {
        AVMutableVideoCompositionInstruction  *instruction = [self addAssetURL:self.afterURL videoCompositionTrack:videoCompositionTrack audioCompositionTrack:((self.shouldMuteAudio) ? nil : audioCompositionTrack) atTime:mutableComposition.duration];
        [instructions addObject:instruction];
    }
    
    AVMutableVideoComposition  *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = instructions;
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(320.0, 320.0);
    
    NSURL      *target  =   [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"stitchedMovieSegment"] stringByAppendingPathExtension:@"mp4"] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:target error:nil];
    
    NSString   *videoQuality = [[VSettingManager sharedManager] exportVideoQuality];

    self.exportSession  = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:videoQuality];
    self.exportSession.outputURL = target;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.videoComposition = mainCompositionInst;
    
    self.renderHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.renderHud.mode = MBProgressHUDModeAnnularDeterminate;
    self.renderHud.labelText = NSLocalizedString(@"Stitching", @"");
    
    self.exportTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f
                                                        target:self 
                                                      selector:@selector(updateProgress)
                                                      userInfo:nil
                                                       repeats:YES];
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.exportTimer invalidate];
            self.exportTimer = nil;
            self.renderHud.progress = 1.0f;
            [self.renderHud hide:YES afterDelay:0.1f];
            
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@ : %@", [[self.exportSession error] localizedDescription], [self.exportSession error]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"Export Complete");
                    self.targetURL = target;
                    [self.videoPlayerViewController setItemURL:target];
                    [self.videoPlayerViewController.player seekToTime:kCMTimeZero];
                    break;
            }
        });
    }];
}

- (AVMutableVideoCompositionInstruction *)addAssetURL:(NSURL *)assetURL videoCompositionTrack:(AVMutableCompositionTrack *)videoCompositionTrack audioCompositionTrack:(AVMutableCompositionTrack *)audioCompositionTrack atTime:(CMTime)insertionTime
{
    AVURLAsset     *asset       =   [AVURLAsset URLAssetWithURL:assetURL options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    AVAssetTrack   *videoTrack  =   [asset tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetTrack   *audiotrack  =   [asset tracksWithMediaType:AVMediaTypeAudio][0];

    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:insertionTime error:nil];
    if (audioCompositionTrack)
    {
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audiotrack atTime:insertionTime error:nil];
    }

    AVMutableVideoCompositionInstruction   *instruction =   [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(insertionTime, asset.duration);
    
    AVMutableVideoCompositionLayerInstruction  *videoLayerInstruction   = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    CGAffineTransform                           transform = videoTrack.preferredTransform;
    BOOL                                        isAssetPortrait         =   NO;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0)
    {
        isAssetPortrait = YES;
    }

    if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0)
    {
        isAssetPortrait = YES;
    }

    CGFloat assetScaleToFitRatio = 320.0 / videoTrack.naturalSize.width;
    if (isAssetPortrait)
    {
        assetScaleToFitRatio = 320.0 / videoTrack.naturalSize.height;
        CGAffineTransform assetScaleTransform = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
        CGAffineTransform assetTranslationTransform = CGAffineTransformMakeTranslation(0, (320.0f - videoTrack.naturalSize.width * assetScaleToFitRatio) * 0.5f);
        [videoLayerInstruction setTransform:CGAffineTransformConcat(videoTrack.preferredTransform, CGAffineTransformConcat(assetScaleTransform, assetTranslationTransform)) atTime:insertionTime];
    }
    else
    {
        CGAffineTransform assetScaleFactor = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
        CGFloat naturalHeight = videoTrack.naturalSize.height * assetScaleToFitRatio;
        CGFloat offset = (320.0 - naturalHeight) / 2.0;
        [videoLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(videoTrack.preferredTransform, assetScaleFactor),CGAffineTransformMakeTranslation(0, offset)) atTime:insertionTime];
    }

    instruction.layerInstructions = @[videoLayerInstruction];

    return instruction;
}

- (void)setupThumbnailStrip:(UIView *)background withURL:(NSURL *)aURL
{
    AVAsset    *asset = [AVAsset assetWithURL:aURL];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    self.imageGenerator.maximumSize = CGSizeMake(84, 84);
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    int picWidth = 42;
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    int picsCnt = ceil(background.frame.size.width / picWidth);
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    int time4Pic = 0;
    
    for (int i = 0; i < picsCnt; i++)
    {
        time4Pic = i * picWidth;
        CMTime timeFrame = CMTimeMakeWithSeconds(durationSeconds * time4Pic / background.frame.size.width, 600);
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    __block int i = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         if (result == AVAssetImageGeneratorSucceeded)
         {
             UIImage      *thumb = [[UIImage alloc] initWithCGImage:image];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIImageView  *tmp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
                 tmp.image = thumb;
                 tmp.backgroundColor = [UIColor redColor];
                 tmp.contentMode = UIViewContentModeScaleAspectFill;
                 
                 int total = (i+1) * tmp.frame.size.width;
                 
                 CGRect currentFrame = tmp.frame;
                 currentFrame.origin.x = i * currentFrame.size.width;
                 if (total > background.frame.size.width)
                 {
                     int delta = total - background.frame.size.width;
                     currentFrame.size.width -= delta;
                 }
                 
                 tmp.frame = currentFrame;
                 i++;
                 
                 [background addSubview:tmp];
                 [background setNeedsDisplay];
             });
         }
         
         if (result == AVAssetImageGeneratorFailed)
         {
             NSLog(@"Failed with error: %@", [error localizedDescription]);
         }
         if (result == AVAssetImageGeneratorCancelled)
         {
             NSLog(@"Canceled");
         }
     }];
}

@end
