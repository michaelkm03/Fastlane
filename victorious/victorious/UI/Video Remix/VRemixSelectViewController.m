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
#import "VThemeManager.h"

@interface VRemixSelectViewController ()

@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;

@property (nonatomic, weak)     IBOutlet    UILabel*            instructionsText;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;
@property (nonatomic, weak)     IBOutlet    UIButton*           startRemixButton;

@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;

@end

@implementation VRemixSelectViewController

+ (UIViewController *)remixViewControllerWithURL:(NSURL *)url
{
    UINavigationController*     remixViewController =   [[UIStoryboard storyboardWithName:@"VideoRemix" bundle:nil] instantiateInitialViewController];
    VRemixSelectViewController* rootViewController  =   (VRemixSelectViewController *)remixViewController.topViewController;
    rootViewController.sourceURL = url;
    
    return remixViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.previewView.player.shouldLoop = YES;
    self.previewView.player.startSeconds = 0;
    self.previewView.player.endSeconds = 15;

    UIImage*    closeButtonImage = [[UIImage imageNamed:@"cameraButtonClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClicked:)];

    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    
    self.instructionsText.font = [[VThemeManager sharedThemeManager] themedFontForKey:@""];
    self.currentTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:@""];
    self.totalTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:@""];
    self.startRemixButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:@""];
    [self.startRemixButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:@""] forState:UIControlStateNormal];
    self.startRemixButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:@""];
    

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
    //  Make API call
    //  Modal, busy indicator
    //  With result, segue, setting result to self.targetURL
    NSData*     movieData = [NSData dataWithContentsOfURL:self.sourceURL];
    self.targetURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[self.sourceURL lastPathComponent]] isDirectory:NO];
    [movieData writeToURL:self.targetURL atomically:YES];

    [self performSegueWithIdentifier:@"toTrim" sender:self];
    //  if error, alert
}

-(IBAction)scrubberDidStartMoving:(id)sender
{
    self.restoreAfterScrubbingRate = self.previewView.player.rate;
    [self.previewView.player setRate:0.f];
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
        self.previewView.player.endSeconds = time + 15;
    }
}

-(IBAction)scrubberDidEndMoving:(id)sender
{
	if (self.restoreAfterScrubbingRate)
	{
		[self.previewView.player setRate:self.restoreAfterScrubbingRate];
		self.restoreAfterScrubbingRate = 0.f;
	}
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toTrim"])
    {
        VRemixTrimViewController*     trimViewController = (VRemixTrimViewController *)segue.destinationViewController;
        trimViewController.sourceURL = self.targetURL;
    }
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
{
    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds([self playerItemDuration])];
    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
}

@end
