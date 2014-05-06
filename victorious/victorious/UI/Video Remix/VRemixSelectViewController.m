//
//  VRemixSelectViewController.m
//  victorious
//
//  Created by Gary Philipp on 4/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixSelectViewController.h"
#import "VCVideoPlayerView.h"
#import "VRemixTrimViewController.h"
#import "VObjectManager+ContentCreation.h"
#import "VThemeManager.h"
#import "MBProgressHUD.h"
#import "VConstants.h"

@interface VRemixSelectViewController ()    <NSURLSessionDownloadDelegate>

@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;

@property (nonatomic, weak)     IBOutlet    UILabel*            instructionsText;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;
@property (nonatomic, weak)     IBOutlet    UIButton*           startRemixButton;

@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;

@property (nonatomic, strong)   MBProgressHUD*                  progressHUD;

@property (nonatomic)           NSInteger                       seqID;

@end

@implementation VRemixSelectViewController

+ (UIViewController *)remixViewControllerWithURL:(NSURL *)url sequenceID:(NSInteger)sequenceID nodeID:(NSInteger)nodeID
{
    UINavigationController*     remixViewController =   [[UIStoryboard storyboardWithName:@"VideoRemix" bundle:nil] instantiateInitialViewController];
    VRemixSelectViewController* rootViewController  =   (VRemixSelectViewController *)remixViewController.topViewController;
    rootViewController.sourceURL = url;
    rootViewController.parentID = nodeID;
    rootViewController.seqID = sequenceID;
    
    return remixViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.previewView.player.shouldLoop = YES;
    self.previewView.player.startSeconds = 0;

    UIImage*    closeButtonImage = [[UIImage imageNamed:@"cameraButtonClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds([self playerItemDuration])];
    self.currentTimeLabel.text = [self secondsToMMSS:0];
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.previewView.player pause];
    [self downloadVideoSegmentForSequenceID:self.seqID atTime:self.previewView.player.startSeconds];
}

-(IBAction)scrubberDidStartMoving:(id)sender
{
    self.restoreAfterScrubbingRate = self.previewView.player.rate;
    [self.previewView.player setRate:0.0f];
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
        self.previewView.player.startSeconds = time;
    }
}

-(IBAction)scrubberDidEndMoving:(id)sender
{
	if (self.restoreAfterScrubbingRate)
	{
		[self.previewView.player setRate:self.restoreAfterScrubbingRate];
		self.restoreAfterScrubbingRate = 0.0f;
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toTrim"])
    {
        VRemixTrimViewController*     trimViewController = (VRemixTrimViewController *)segue.destinationViewController;
        trimViewController.sourceURL = self.targetURL;
        trimViewController.parentID = self.parentID;
    }
}

#pragma mark - Support

- (void)downloadVideoSegmentForSequenceID:(NSInteger)sequenceID atTime:(CGFloat)selectedTime
{
    self.progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    self.progressHUD.detailsLabelText = NSLocalizedString(@"LocatingVideo", @"");

    [[VObjectManager sharedManager] fetchRemixMP4UrlForSequenceID:@(sequenceID) atStartTime:selectedTime duration:VConstantsMaximumVideoDuration completionBlock:^(BOOL completion, NSURL *remixMp4Url, NSError* error)
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
         }
     }];
}

- (void)downloadVideoSegmentAtURL:(NSURL *)segmentURL
{
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    self.progressHUD.detailsLabelText = NSLocalizedString(@"DownloadingVideo", @"");
    
    NSURLSessionConfiguration*  sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;

    NSURLSession*               session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                        delegate:self
                                                                   delegateQueue:nil];
    NSURLSessionDownloadTask*   task = [session downloadTaskWithURL:segmentURL];
    [task resume];
}

- (void)showSegmentDownloadFailureAlert
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SegmentDownloadFail", @"")
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
        
        if (error)
            [self showSegmentDownloadFailureAlert];
        else
            [self performSegueWithIdentifier:@"toTrim" sender:self];
    });
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
{
    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds([self playerItemDuration])];
    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
}

@end
