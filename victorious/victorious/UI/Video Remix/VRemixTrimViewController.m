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

@interface VRemixTrimViewController ()  <VCVideoPlayerDelegate, VRemixVideoRangeSliderDelegate>
@property (nonatomic, strong)   NSURL*                          assetURL;
@property (nonatomic, weak)     IBOutlet    VCVideoPlayerView*  previewView;;
@property (nonatomic, weak)     IBOutlet    UISlider*           scrubber;
@property (nonatomic, weak)     IBOutlet    UILabel*            currentTimeLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*            totalTimeLabel;

@property (nonatomic, weak)     IBOutlet    UIButton*           rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton*           muteButton;

@property (nonatomic, weak)     IBOutlet    UIView*             trimControlContainer;
@property (nonatomic, strong)   VRemixVideoRangeSlider*         trimSlider;

@property (nonatomic, strong)   id                              periodicTimeObserver;

@property (nonatomic)           CGFloat                         restoreAfterScrubbingRate;
@property (nonatomic, assign)   CGFloat                         start;
@property (nonatomic, assign)   CGFloat                         stop;
@property (nonatomic, strong)   id                              timeObserver;
@end

@implementation VRemixTrimViewController

+ (UIViewController *)remixViewControllerWithURL:(NSURL *)url
{
    UINavigationController*     remixViewController =   [[UIStoryboard storyboardWithName:@"VideoRemix" bundle:nil] instantiateInitialViewController];
    VRemixTrimViewController*   rootViewController  =   (VRemixTrimViewController *)remixViewController.topViewController;
    rootViewController.assetURL = url;
    
    return remixViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.sourceAsset = [AVURLAsset assetWithURL:self.assetURL];
    [self.sourceAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        NSError*            error   = nil;
        AVKeyValueStatus    status  = [self.sourceAsset statusOfValueForKey:@"duration" error:&error];
        switch (status)
        {
            case AVKeyValueStatusLoaded:
//                [self updateUserInterfaceForDuration];
                break;
        }
    }];
    
    self.start  =   0.0;
    self.stop   =   self.start + CMTimeGetSeconds(self.sourceAsset.duration);
    
    self.playBackSpeed = kRemixPlaybackNormalSpeed;
    self.playbackLooping = kRemixLoopingNone;
    
    [self.previewView.player setItem:[AVPlayerItem playerItemWithURL:self.assetURL]];
    self.previewView.player.shouldLoop = YES;
    self.previewView.player.delegate = self;
    [self.previewView.player play];
    
    [self.previewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.previewView.userInteractionEnabled = YES;
    
    [self.scrubber addTarget:self action:@selector(scrubberDidStartMoving:) forControlEvents:UIControlEventTouchDown];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventTouchDragInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidMove:) forControlEvents:UIControlEventValueChanged];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrubber addTarget:self action:@selector(scrubberDidEndMoving:) forControlEvents:UIControlEventTouchUpOutside];
    
    UIImage*    nextButtonImage = [[UIImage imageNamed:@"cameraButtonNext"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonClicked:)];
    
    self.trimSlider = [[VRemixVideoRangeSlider alloc] initWithFrame:self.trimControlContainer.bounds videoUrl:self.sourceAsset];
    self.trimSlider.bubbleText.font = [UIFont systemFontOfSize:12];
    [self.trimSlider setPopoverBubbleWidth:120 height:60];
    
    self.trimSlider.delegate = self;
    [self.trimControlContainer addSubview:self.trimSlider];

//    // Yellow
//    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
//    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
//
//    // Purple
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 1];
//
//    // Gray
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.945 green: 0.945 blue: 0.945 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.806 green: 0.806 blue: 0.806 alpha: 1];
//
//    // Green
//    //self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.725 green: 0.879 blue: 0.745 alpha: 1];
//    //self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.449 green: 0.758 blue: 0.489 alpha: 1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    self.totalTimeLabel.text = [self secondsToMMSS:CMTimeGetSeconds(self.sourceAsset.duration)];
    self.currentTimeLabel.text = [self secondsToMMSS:0];
    
    double interval = .1f;

    CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
		return;

    double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		interval = 0.5f * duration / width;
	}

	self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time)
                     {
                         [self syncScrubber];
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.previewView.player.isPlaying)
        [self.previewView.player pause];
    
    [self.previewView.player removeTimeObserver:self.timeObserver];
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
    self.start = leftPosition;
    self.stop = rightPosition;
//    self.timeLabel.text = [NSString stringWithFormat:@"%f - %f", leftPosition, rightPosition];
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonClicked:(id)sender
{
    [self.activityIndicator startAnimating];
    [self trimVideo:self.sourceAsset startTrim:self.start endTrim:self.stop];
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.muteAudio = button.selected;
    self.previewView.player.muted = self.muteAudio;
    
    if (self.muteAudio)
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
    else
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kRemixPlaybackNormalSpeed)
    {
        self.playBackSpeed = kRemixPlaybackDoubleSpeed;
        [self.previewView.player setRate:2.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kRemixPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kRemixPlaybackHalfSpeed;
        [self.previewView.player setRate:0.5];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kRemixPlaybackHalfSpeed)
    {
        self.playBackSpeed = kRemixPlaybackNormalSpeed;
        [self.previewView.player setRate:1.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kRemixLoopingNone)
    {
        self.playbackLooping = kRemixLoopingLoop;
        self.previewView.player.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kRemixLoopingLoop)
    {
        self.playbackLooping = kRemixLoopingNone;
        self.previewView.player.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
}

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.previewView.player.isPlaying)
        [self.previewView.player play];
    else
        [self.previewView.player pause];
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

			self.timeObserver = [self.previewView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
                             {
                                 [self syncScrubber];
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
        stitchViewController.sourceAsset = self.outputAsset;
        stitchViewController.muteAudio = self.muteAudio;
        stitchViewController.playBackSpeed = self.playBackSpeed;
        stitchViewController.playbackLooping = self.playbackLooping;
    }
}

#pragma mark - Support

- (void)processVideoDidFinishWithURL:(NSURL *)aURL
{
    [self.activityIndicator stopAnimating];
    self.outputAsset = [[AVURLAsset alloc] initWithURL:aURL options:nil];
    [self performSegueWithIdentifier:@"toStich" sender:self];
}

- (void)trimVideo:(AVURLAsset *)assetToTrim startTrim:(CGFloat)startTrim endTrim:(CGFloat)endTrim
{
    NSArray*    compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:assetToTrim];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        AVAsset* asset = [AVAsset assetWithURL:self.assetURL];
        AVAssetExportSession*   exportSession   =   [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
        
        exportSession.outputURL = [self exportFileURL];
        exportSession.outputFileType = AVFileTypeMPEG4;
//        exportSession.shouldOptimizeForNetworkUse = YES;
        
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








//static void *MyStreamingMovieViewControllerTimedMetadataObserverContext = &MyStreamingMovieViewControllerTimedMetadataObserverContext;
//static void *MyStreamingMovieViewControllerRateObservationContext = &MyStreamingMovieViewControllerRateObservationContext;
//static void *MyStreamingMovieViewControllerCurrentItemObservationContext = &MyStreamingMovieViewControllerCurrentItemObservationContext;
//static void *MyStreamingMovieViewControllerPlayerItemStatusObserverContext = &MyStreamingMovieViewControllerPlayerItemStatusObserverContext;
//
//NSString *kTracksKey		= @"tracks";
//NSString *kStatusKey		= @"status";
//NSString *kRateKey			= @"rate";
//NSString *kPlayableKey		= @"playable";
//NSString *kCurrentItemKey	= @"currentItem";
//NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";
//
//#pragma mark -
//@interface MyStreamingMovieViewController (Player)
//- (BOOL)isPlaying;
//- (void)handleTimedMetadata:(AVMetadataItem*)timedMetadata;
//- (void)updateAdList:(NSArray *)newAdList;
//- (void)assetFailedToPrepareForPlayback:(NSError *)error;
//- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
//@end
//
//@implementation MyStreamingMovieViewController
//
//@synthesize movieURLTextField;
//@synthesize movieTimeControl;
//@synthesize playerLayerView;
//@synthesize player, playerItem;
//@synthesize isPlayingAdText;
//@synthesize toolBar, playButton, stopButton;
//
///* Prevent the slider from seeking during Ad playback. */
//- (void)sliderSyncToPlayerSeekableTimeRanges
//{
//	NSArray *seekableTimeRanges = [[player currentItem] seekableTimeRanges];
//	if ([seekableTimeRanges count] > 0)
//	{
//		NSValue *range = [seekableTimeRanges objectAtIndex:0];
//		CMTimeRange timeRange = [range CMTimeRangeValue];
//		float startSeconds = CMTimeGetSeconds(timeRange.start);
//		float durationSeconds = CMTimeGetSeconds(timeRange.duration);
//		
//		/* Set the minimum and maximum values of the time slider to match the seekable time range. */
//		movieTimeControl.minimumValue = startSeconds;
//		movieTimeControl.maximumValue = startSeconds + durationSeconds;
//	}
//}
//
//- (IBAction)loadMovieButtonPressed:(id)sender
//{
//	/* Has the user entered a movie URL? */
//	if (self.movieURLTextField.text.length > 0)
//	{
//		NSURL *newMovieURL = [NSURL URLWithString:self.movieURLTextField.text];
//		if ([newMovieURL scheme])	/* Sanity check on the URL. */
//		{
//			/*
//			 Create an asset for inspection of a resource referenced by a given URL.
//			 Load the values for the asset keys "tracks", "playable".
//			 */
//            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newMovieURL options:nil];
//            
//			NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
//			
//			/* Tells the asset to load the values of any of the specified keys that are not already loaded. */
//			[asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
//			 ^{
//				 dispatch_async( dispatch_get_main_queue(),
//								^{
//									/* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
//									[self prepareToPlayAsset:asset withKeys:requestedKeys];
//								});
//			 }];
//		}
//	}
//}
//
//#pragma mark Prepare to play asset
//
///*
// Invoked at the completion of the loading of the values for all keys on the asset that we require.
// Checks whether loading was successfull and whether the asset is playable.
// If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
// */
//- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
//{
//    /* Make sure that the value of each key has loaded successfully. */
//	for (NSString *thisKey in requestedKeys)
//	{
//		NSError *error = nil;
//		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
//		if (keyStatus == AVKeyValueStatusFailed)
//		{
//			[self assetFailedToPrepareForPlayback:error];
//			return;
//		}
//		/* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
//         out properly in the case of cancellation. */
//	}
//    
//    /* Use the AVAsset playable property to detect whether the asset can be played. */
//    if (!asset.playable)
//    {
//        /* Generate an error describing the failure. */
//		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
//		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
//		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
//								   localizedDescription, NSLocalizedDescriptionKey,
//								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
//								   nil];
//		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
//        
//        /* Display the error to the user. */
//        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
//        
//        return;
//    }
//	
//	/* At this point we're ready to set up for playback of the asset. */
//    
//	[self initScrubberTimer];
//	[self enableScrubber];
//	[self enablePlayerButtons];
//	
//    /* Stop observing our prior AVPlayerItem, if we have one. */
//    if (self.playerItem)
//    {
//        /* Remove existing player item key value observers and notifications. */
//        
//        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
//		
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:AVPlayerItemDidPlayToEndTimeNotification
//                                                      object:self.playerItem];
//    }
//	
//    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
//    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    
//    /* Observe the player item "status" key to determine when it is ready to play. */
//    [self.playerItem addObserver:self
//                      forKeyPath:kStatusKey
//                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                         context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
//	
//    /* When the player item has played to its end time we'll toggle
//     the movie controller Pause button to be the Play button */
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:self.playerItem];
//	
//    seekToZeroBeforePlay = NO;
//	
//    /* Create new player, if we don't already have one. */
//    if (![self player])
//    {
//        /* Get a new AVPlayer initialized to play the specified player item. */
//        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
//		
//        /* Observe the AVPlayer "currentItem" property to find out when any
//         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
//         occur.*/
//        [self.player addObserver:self
//                      forKeyPath:kCurrentItemKey
//                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                         context:MyStreamingMovieViewControllerCurrentItemObservationContext];
//        
//        /* A 'currentItem.timedMetadata' property observer to parse the media stream timed metadata. */
//        [self.player addObserver:self
//                      forKeyPath:kTimedMetadataKey
//                         options:0
//                         context:MyStreamingMovieViewControllerTimedMetadataObserverContext];
//        
//        /* Observe the AVPlayer "rate" property to update the scrubber control. */
//        [self.player addObserver:self
//                      forKeyPath:kRateKey
//                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                         context:MyStreamingMovieViewControllerRateObservationContext];
//    }
//    
//    /* Make our new AVPlayerItem the AVPlayer's current item. */
//    if (self.player.currentItem != self.playerItem)
//    {
//        /* Replace the player item with a new player item. The item replacement occurs
//         asynchronously; observe the currentItem property to find out when the
//         replacement will/did occur*/
//        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
//        
//        [self syncPlayPauseButtons];
//    }
//	
//    [movieTimeControl setValue:0.0];
//}
//
//#pragma mark -
//#pragma mark Asset Key Value Observing
//#pragma mark
//
//#pragma mark Key Value Observer for player rate, currentItem, player item status
//
///* ---------------------------------------------------------
// **  Called when the value at the specified key path relative
// **  to the given object has changed.
// **  Adjust the movie play and pause button controls when the
// **  player item "status" value changes. Update the movie
// **  scrubber control when the player item is ready to play.
// **  Adjust the movie scrubber control when the player item
// **  "rate" value changes. For updates of the player
// **  "currentItem" property, set the AVPlayer for which the
// **  player layer displays visual output.
// **  NOTE: this method is invoked on the main queue.
// ** ------------------------------------------------------- */
//
//- (void)observeValueForKeyPath:(NSString*) path
//                      ofObject:(id)object
//                        change:(NSDictionary*)change
//                       context:(void*)context
//{
//	/* AVPlayerItem "status" property value observer. */
//	if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
//	{
//		[self syncPlayPauseButtons];
//        
//        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//        switch (status)
//        {
//                /* Indicates that the status of the player is not yet known because
//                 it has not tried to load new media resources for playback */
//            case AVPlayerStatusUnknown:
//            {
//                [self removePlayerTimeObserver];
//                [self syncScrubber];
//                
//                [self disableScrubber];
//                [self disablePlayerButtons];
//            }
//                break;
//                
//            case AVPlayerStatusReadyToPlay:
//            {
//                /* Once the AVPlayerItem becomes ready to play, i.e.
//                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
//                 its duration can be fetched from the item. */
//                
//                playerLayerView.playerLayer.hidden = NO;
//                
//                [toolBar setHidden:NO];
//                
//                /* Show the movie slider control since the movie is now ready to play. */
//                movieTimeControl.hidden = NO;
//                
//                [self enableScrubber];
//                [self enablePlayerButtons];
//                
//                playerLayerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
//                
//                /* Set the AVPlayerLayer on the view to allow the AVPlayer object to display
//                 its content. */
//                [playerLayerView.playerLayer setPlayer:player];
//                
//                [self initScrubberTimer];
//            }
//                break;
//                
//            case AVPlayerStatusFailed:
//            {
//                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
//                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
//            }
//                break;
//        }
//	}
//	/* AVPlayer "rate" property value observer. */
//	else if (context == MyStreamingMovieViewControllerRateObservationContext)
//	{
//        [self syncPlayPauseButtons];
//	}
//	/* AVPlayer "currentItem" property observer.
//     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
//     replacement will/did occur. */
//	else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext)
//	{
//        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
//        
//        /* New player item null? */
//        if (newPlayerItem == (id)[NSNull null])
//        {
//            [self disablePlayerButtons];
//            [self disableScrubber];
//            
//            self.isPlayingAdText.text = @"";
//        }
//        else /* Replacement of player currentItem has occurred */
//        {
//            /* Set the AVPlayer for which the player layer displays visual output. */
//            [playerLayerView.playerLayer setPlayer:self.player];
//            
//            /* Specifies that the player should preserve the video’s aspect ratio and
//             fit the video within the layer’s bounds. */
//            [playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
//            
//            [self syncPlayPauseButtons];
//        }
//	}
//	/* Observe the AVPlayer "currentItem.timedMetadata" property to parse the media stream
//     timed metadata. */
//	else if (context == MyStreamingMovieViewControllerTimedMetadataObserverContext)
//	{
//		NSArray* array = [[player currentItem] timedMetadata];
//		for (AVMetadataItem *metadataItem in array)
//		{
//			[self handleTimedMetadata:metadataItem];
//		}
//	}
//	else
//	{
//		[super observeValueForKeyPath:path ofObject:object change:change context:context];
//	}
//    
//    return;
//}
//
//@end

