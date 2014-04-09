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

@interface VRemixSelectViewController ()

//@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;

//@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
//@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;
//@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;
//@property (nonatomic, strong)   id                              timeObserver;

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
	
    UIImage*    closeButtonImage = [[UIImage imageNamed:@"cameraButtonClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:closeButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClicked:)];

    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];

//    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving:) forControlEvents:UIControlEventTouchDown];
//    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventTouchDragInside];
//    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventValueChanged];
//    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpOutside];

//    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds(self.sourceAsset.duration)];
//    self.currentTimeLabel.text = [self secondsToMMSS:0];
//    
//    double interval = .1f;
//    
//    double duration = CMTimeGetSeconds([self playerItemDuration]);
//	if (isfinite(duration))
//	{
//		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
//		interval = 0.5f * duration / width;
//	}
//    
//    __weak  VRemixTrimViewController*   weakSelf    =   self;
//	self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
//                         {
//                             [weakSelf syncScrubber];
//                         }];
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
    [self performSegueWithIdentifier:@"toTrim" sender:self];
    //  if error, alert
}

//-(IBAction)scrubberDidStartMoving:(id)sender
//{
//    self.restoreAfterScrubbingRate = self.previewView.player.rate;
//    [self.previewView.player setRate:0.f];
//    
//    [self removePlayerTimeObserver];
//}
//
//-(IBAction)scrubberDidMove:(id)sender
//{
//    CMTime playerDuration = [self playerItemDuration];
//    if (CMTIME_IS_INVALID(playerDuration))
//        return;
//    
//    double duration = CMTimeGetSeconds(playerDuration);
//    if (isfinite(duration))
//    {
//        float minValue = [self.scrubber minimumValue];
//        float maxValue = [self.scrubber maximumValue];
//        float value = [self.scrubber value];
//        double time = duration * (value - minValue) / (maxValue - minValue);
//        
//        [self.previewView.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
//    }
//}
//
//-(IBAction)scrubberDidEndMoving:(id)sender
//{
//	if (!self.timeObserver)
//	{
//		CMTime playerDuration = [self playerItemDuration];
//		if (CMTIME_IS_INVALID(playerDuration))
//			return;
//        
//		double duration = CMTimeGetSeconds(playerDuration);
//		if (isfinite(duration))
//		{
//			CGFloat width = CGRectGetWidth([self.scrubber bounds]);
//			double tolerance = 0.5f * duration / width;
//            
//            __weak  VRemixTrimViewController*   weakSelf    =   self;
//			self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
//                                 {
//                                     [weakSelf syncScrubber];
//                                 }];
//		}
//	}
//    
//	if (self.restoreAfterScrubbingRate)
//	{
//		[self.previewView.player setRate:self.restoreAfterScrubbingRate];
//		self.restoreAfterScrubbingRate = 0.f;
//	}
//}

#pragma mark - Properties

//- (CMTime)playerItemDuration
//{
//    AVPlayerItem *thePlayerItem = self.previewView.player.currentItem;
//    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
//        return thePlayerItem.duration;
//    else
//        return kCMTimeInvalid;
//}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toStitch"])
    {
        VRemixTrimViewController*     stitchViewController = (VRemixTrimViewController *)segue.destinationViewController;
        stitchViewController.sourceURL = self.targetURL;
    }
}

#pragma mark - Support

//-(NSString *)secondsToMMSS:(double)seconds
//{
//    NSInteger time = floor(seconds);
//    NSInteger hh = time / 3600;
//    NSInteger mm = (time / 60) % 60;
//    NSInteger ss = time % 60;
//    if (hh > 0)
//        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
//    else
//        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
//}
//
//-(void)removePlayerTimeObserver
//{
//    if (self.timeObserver)
//    {
//        [self.previewView.player removeTimeObserver:self.timeObserver];
//        self.timeObserver = nil;
//    }
//}
//
//- (void)syncScrubber
//{
//    CMTime playerDuration = [self playerItemDuration];
//	if (CMTIME_IS_INVALID(playerDuration))
//	{
//		self.scrubber.minimumValue = 0.0;
//		return;
//	}
//    
//	double duration = CMTimeGetSeconds(playerDuration);
//	if (isfinite(duration) && (duration > 0))
//	{
//		float minValue = [self.scrubber minimumValue];
//		float maxValue = [self.scrubber maximumValue];
//		double time = CMTimeGetSeconds([self.previewView.player currentTime]);
//		[self.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
//	}
//}

#pragma mark - SCVideoPlayerDelegate

//- (void)videoPlayer:(VCPlayer*)videoPlayer didPlay:(Float32)secondsElapsed
//{
//    CMTime endTime = CMTimeConvertScale([self playerItemDuration], self.previewView.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
//    if (CMTimeCompare(endTime, kCMTimeZero) != 0)
//    {
//        double normalizedTime = (double)self.previewView.player.currentTime.value / (double)endTime.value;
//        self.scrubber.value = normalizedTime;
//    }
//
//    self.currentTimeLabel.text = [self secondsToMMSS:secondsElapsed];
//}

@end
