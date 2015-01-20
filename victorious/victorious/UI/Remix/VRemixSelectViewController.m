//
//  VRemixSelectViewController.m
//  victorious
//
//  Created by Gary Philipp on 4/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VElapsedTimeFormatter.h"
#import "VRemixSelectViewController.h"
#import "VRemixTrimViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "VThemeManager.h"
#import "MBProgressHUD.h"

@interface VRemixSelectViewController ()    <NSURLSessionDownloadDelegate>

@property (nonatomic, weak)     IBOutlet    UISlider           *scrubber;

@property (nonatomic, weak)     IBOutlet    UILabel            *instructionsText;
@property (nonatomic, weak)     IBOutlet    UILabel            *currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel            *totalTimeLabel;
@property (nonatomic, weak)     IBOutlet    UIButton           *startRemixButton;

@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;

@property (nonatomic, strong)   MBProgressHUD                  *progressHUD;

@end

@implementation VRemixSelectViewController

+ (UIViewController *)remixViewControllerWithURL:(NSURL *)url sequenceID:(NSInteger)sequenceID nodeID:(NSInteger)nodeID
{
    UINavigationController     *remixViewController =   [[UIStoryboard storyboardWithName:@"VideoRemix" bundle:nil] instantiateInitialViewController];
    VRemixSelectViewController *rootViewController  =   (VRemixSelectViewController *)remixViewController.topViewController;
    rootViewController.sourceURL = url;
    rootViewController.parentNodeID = nodeID;
    rootViewController.parentSequenceID = sequenceID;
    
    return remixViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.videoPlayerViewController.startSeconds = 0;

    UIImage    *closeButtonImage = [[UIImage imageNamed:@"cameraButtonClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClicked:)];

    self.instructionsText.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.currentTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.totalTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.startRemixButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    [self.startRemixButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor] forState:UIControlStateNormal];
    self.startRemixButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving:) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventTouchDragInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventValueChanged];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.scrubber setThumbImage:[UIImage imageNamed:@"cameraButtonScrubber"] forState:UIControlStateNormal];
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 21.0f;
    style.maximumLineHeight = 21.0f;
    style.alignment = NSTextAlignmentCenter;
    
    self.instructionsText.attributedText = [[NSAttributedString alloc] initWithString:self.instructionsText.text
                                                                           attributes:@{NSParagraphStyleAttributeName:style,
                                                                                        NSFontAttributeName:[UIFont systemFontOfSize:17]}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.totalTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:[self.videoPlayerViewController playerItemDuration]];
    self.currentTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:CMTimeMakeWithSeconds(0, 1)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Remix Select" parameters:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Remix Select"];
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.videoPlayerViewController.player pause];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self downloadVideoSegmentForSequenceID:self.parentSequenceID atTime:self.videoPlayerViewController.startSeconds];
}

- (IBAction)scrubberDidStartMoving:(id)sender
{
    self.restoreAfterScrubbingRate = self.videoPlayerViewController.player.rate;
    [self.videoPlayerViewController.player setRate:0.0f];
}

- (IBAction)scrubberDidMove:(id)sender
{
    CMTime playerDuration = [self.videoPlayerViewController playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.scrubber minimumValue];
        float maxValue = [self.scrubber maximumValue];
        float value = [self.scrubber value];
        double time = duration * (value - minValue) / (maxValue - minValue);
    
        [self.videoPlayerViewController.player seekToTime:CMTimeMakeWithSeconds(time, [self.videoPlayerViewController.player.currentItem duration].timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        self.videoPlayerViewController.startSeconds = time;
    }
}

- (IBAction)scrubberDidEndMoving:(id)sender
{
	if (self.restoreAfterScrubbingRate)
	{
		[self.videoPlayerViewController.player setRate:self.restoreAfterScrubbingRate];
		self.restoreAfterScrubbingRate = 0.0f;
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toTrim"])
    {
        VRemixTrimViewController     *trimViewController = (VRemixTrimViewController *)segue.destinationViewController;
        trimViewController.sourceURL = self.targetURL;
        trimViewController.parentNodeID = self.parentNodeID;
        trimViewController.parentSequenceID = self.parentSequenceID;
    }
}

#pragma mark - Support

- (void)downloadVideoSegmentForSequenceID:(NSInteger)sequenceID atTime:(CGFloat)selectedTime
{
    self.progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    self.progressHUD.detailsLabelText = NSLocalizedString(@"LocatingVideo", @"");

    [[VObjectManager sharedManager] fetchRemixMP4UrlForSequenceID:@(sequenceID) atStartTime:selectedTime duration:VConstantsMaximumVideoDuration completionBlock:^(BOOL completion, NSURL *remixMp4Url, NSError *error)
     {
         if (completion)
         {
             [self downloadVideoSegmentAtURL:remixMp4Url];
         }
         else
         {
             [self.progressHUD hide:YES];
             self.progressHUD = nil;
             [self showSegmentDownloadFailureAlert];
             self.navigationItem.leftBarButtonItem.enabled = YES;
         }
     }];
}

- (void)downloadVideoSegmentAtURL:(NSURL *)segmentURL
{
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    self.progressHUD.detailsLabelText = NSLocalizedString(@"DownloadingVideo", @"");
    
    NSURLSessionConfiguration  *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;

    NSURLSession               *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                        delegate:self
                                                                   delegateQueue:nil];
    NSURLSessionDownloadTask   *task = [session downloadTaskWithURL:segmentURL];
    [task resume];
}

- (void)showSegmentDownloadFailureAlert
{
    UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SegmentDownloadFail", @"")
                                                           message:NSLocalizedString(@"TryAgain", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double percent = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressHUD.progress = (float)percent;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    self.targetURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.sourceURL lastPathComponent]] isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:self.targetURL error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:self.targetURL error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:YES];
        self.progressHUD = nil;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        if (error)
        {
            [self showSegmentDownloadFailureAlert];
        }
        else
        {
            [self performSegueWithIdentifier:@"toTrim" sender:self];
        }
    });
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    [super videoPlayer:videoPlayer didPlayToTime:time];
    self.totalTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:[videoPlayer playerItemDuration]];
    self.currentTimeLabel.text = [self.elapsedTimeFormatter stringForCMTime:time];
}

@end
