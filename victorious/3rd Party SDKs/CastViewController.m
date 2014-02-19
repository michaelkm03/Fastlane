// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CastViewController.h"
#import "VAppDelegate.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "NSString+VParseHelp.h"
#import "VUser.h"

@interface CastViewController ()
{
  NSTimeInterval _mediaStartTime;
  BOOL _currentlyDraggingSlider;
  BOOL _readyToShowInterface;
  BOOL _joinExistingSession;
  __weak ChromecastDeviceController* _chromecastController;
}

@property IBOutlet UIImageView* thumbnailImage;
@property IBOutlet UILabel* castingToLabel;
@property(weak, nonatomic) IBOutlet UILabel* mediaTitleLabel;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* castActivityIndicator;
@property(weak, nonatomic) NSTimer* updateStreamTimer;

@property(nonatomic) UIBarButtonItem* currTime;
@property(nonatomic) UIBarButtonItem* totalTime;
@property(nonatomic) UISlider* slider;
@property(nonatomic) NSArray* playToolbar;
@property(nonatomic) NSArray* pauseToolbar;
@end

@implementation CastViewController

+ (CastViewController *)castViewController
{
    static  UINavigationController*     castViewController;
    static  dispatch_once_t             onceToken;
    
    dispatch_once(&onceToken, ^{
        castViewController = [[UIStoryboard storyboardWithName:@"ChromeCast" bundle:nil] instantiateInitialViewController];
    });
    
    return (CastViewController *)(castViewController.topViewController);
}

- (id)initWithCoder:(NSCoder*)decoder
{
  self = [super initWithCoder:decoder];
  if (self)
  {
    [self initControls];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Store a reference to the chromecast controller.
  _chromecastController = [VAppDelegate sharedAppDelegate].chromecastDeviceController;

  self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController.delegate = self;

    // Make the navigation bar transparent.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    // We want a transparent toolbar.
    [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                       forToolbarPosition:UIBarPositionBottom
                                               barMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionBottom];
    self.navigationController.toolbarHidden = YES;
    self.toolbarItems = self.playToolbar;
    
    self.totalTime.title = @"";
    self.currTime.title = @"";
    [self.slider setValue:0];
    [self.castActivityIndicator startAnimating];
    _currentlyDraggingSlider = NO;
    self.navigationController.toolbarHidden = YES;
    _readyToShowInterface = NO;
    
    if (_joinExistingSession == YES)
    {
        [self mediaNowPlaying];
    }
    
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // I think we can safely stop the timer here
    [self.updateStreamTimer invalidate];
    self.updateStreamTimer = nil;
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setBackgroundImage:nil
                                       forToolbarPosition:UIBarPositionBottom
                                               barMetrics:UIBarMetricsDefault];
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(VSequence*)newDetailItem
{
  [self setMediaToPlay:newDetailItem withStartingTime:0];
}

- (void)setMediaToPlay:(VSequence*)newMedia withStartingTime:(NSTimeInterval)startTime
{
  _mediaStartTime = startTime;
  if (_mediaToPlay != newMedia)
  {
    _mediaToPlay = newMedia;

    // Update the view.
    [self configureView];
  }
}

- (void)mediaNowPlaying
{
  _readyToShowInterface = YES;
  [self updateInterfaceFromCast:nil];
  self.navigationController.toolbarHidden = NO;
}

- (void)updateInterfaceFromCast:(NSTimer*)timer
{
  [_chromecastController updateStatsFromDevice];

  if (!_readyToShowInterface)
    return;

  if (_chromecastController.playerState != GCKMediaPlayerStateBuffering)
  {
    [self.castActivityIndicator stopAnimating];
  }
  else
  {
    [self.castActivityIndicator startAnimating];
  }

  if (_chromecastController.streamDuration > 0 && !_currentlyDraggingSlider)
  {
    self.currTime.title = [self getFormattedTime:_chromecastController.streamPosition];
    self.totalTime.title = [self getFormattedTime:_chromecastController.streamDuration];
    [self.slider setValue:(_chromecastController.streamPosition / _chromecastController.streamDuration) animated:YES];
  }
    
  if (_chromecastController.playerState == GCKMediaPlayerStatePaused || _chromecastController.playerState == GCKMediaPlayerStateIdle)
  {
    self.toolbarItems = self.playToolbar;
  }
  else if (_chromecastController.playerState == GCKMediaPlayerStatePlaying || _chromecastController.playerState == GCKMediaPlayerStateBuffering)
  {
    self.toolbarItems = self.pauseToolbar;
  }
}

// Little formatting option here

- (NSString*)getFormattedTime:(NSTimeInterval)timeInSeconds
{
  NSInteger seconds = (NSInteger) round(timeInSeconds);
  NSInteger hours = seconds / (60 * 60);
  seconds %= (60 * 60);

  NSInteger minutes = seconds / 60;
  seconds %= 60;

  if (hours > 0)
  {
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
  }
  else
  {
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
  }
}

- (void)configureView
{
  if (self.mediaToPlay)
  {
      self.mediaTitleLabel.text = self.mediaToPlay.sequenceDescription;

      VAsset* firstAsset = [[self.mediaToPlay firstNode] firstAsset];
      NSURL* url = [NSURL URLWithString:firstAsset.data];
      NSURL* thumbnailURL = [NSURL URLWithString:[firstAsset.data previewImageURLForM3U8]];
      
      //Loading thumbnail async
      NSLog(@"Loaded thumbnail image");
      [self.thumbnailImage setImageWithURL:thumbnailURL];
      [self.view setNeedsLayout];
      
      if (_chromecastController.isConnected)
      {
          self.castingToLabel.text = [NSString stringWithFormat:@"Casting to %@", _chromecastController.deviceName];
          NSLog(@"Casting movie %@ at starting time %f", url, _mediaStartTime);

          // If the newMedia is already playing, join the existing session.
          if (![self.mediaToPlay.name isEqualToString:[_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle]])
          {
              //Cast the movie!!
              [_chromecastController loadMedia:url
                                  thumbnailURL:thumbnailURL
                                         title:self.mediaToPlay.sequenceDescription
                                      subtitle:self.mediaToPlay.user.name
                                      mimeType:@"video/mp4"
                                     startTime:_mediaStartTime
                                      autoPlay:YES];
              _joinExistingSession = NO;
          }
          else
          {
              _joinExistingSession = YES;
              [self mediaNowPlaying];
          }

          // Start the timer
          if (self.updateStreamTimer)
          {
              [self.updateStreamTimer invalidate];
              self.updateStreamTimer = nil;
          }

          self.updateStreamTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target:self
                                                                  selector:@selector(updateInterfaceFromCast:)
                                                                  userInfo:nil
                                                                   repeats:YES];
      }
      else
      {
          self.castingToLabel.text = @"Not Connected";
      }
    }
}

#pragma mark - On - screen UI elements

- (IBAction)pauseButtonClicked:(id)sender
{
  [_chromecastController pauseCastMedia:YES];
}

- (IBAction)playButtonClicked:(id)sender
{
  [_chromecastController pauseCastMedia:NO];
}

// Unsed, but if you wanted a stop, as opposed to a pause button, this is probably
// what you would call
- (IBAction)stopButtonClicked:(id)sender
{
  [_chromecastController stopCastMedia];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onTouchDown:(id)sender
{
  _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender
{
  float pctThrough = [self.slider value];
  if (_chromecastController.streamDuration > 0)
  {
    self.currTime.title = [self getFormattedTime:(pctThrough * _chromecastController.streamDuration)];
  }
}
// This is called only on one of the two touch up events
- (void)touchIsFinished
{
  [_chromecastController setPlaybackPercent:[self.slider value]];
  _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender
{
  NSLog(@"Touch up inside");
  [self touchIsFinished];

}
- (IBAction)onTouchUpOutside:(id)sender
{
  NSLog(@"Touch up outside");
  [self touchIsFinished];
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ChromecastControllerDelegate

- (void)didConnectToDevice:(GCKDevice *)device
{
    [self configureView];
}

- (void)didDisconnect
{
    [self configureView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMediaStateChange
{
  _readyToShowInterface = YES;
  self.navigationController.toolbarHidden = NO;

  if (_chromecastController.playerState == GCKMediaPlayerStateIdle)
  {
      [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)shouldDisplayModalDeviceController
{
  [self performSegueWithIdentifier:@"listDevices" sender:self];
}

#pragma mark - implementation.

- (void)initControls
{
  UIBarButtonItem* playButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                    target:self
                                                    action:@selector(playButtonClicked:)];
  playButton.tintColor = [UIColor whiteColor];
  UIBarButtonItem* pauseButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                    target:self
                                                    action:@selector(pauseButtonClicked:)];
  pauseButton.tintColor = [UIColor whiteColor];
  self.currTime = [[UIBarButtonItem alloc] initWithTitle:@"00:00"
                                                   style:UIBarButtonItemStylePlain
                                                  target:nil
                                                  action:nil];
  self.currTime.tintColor = [UIColor whiteColor];
  self.totalTime = [[UIBarButtonItem alloc] initWithTitle:@"100:00"
                                                    style:UIBarButtonItemStylePlain
                                                   target:nil
                                                   action:nil];
  self.totalTime.tintColor = [UIColor whiteColor];
  UIBarButtonItem* flexibleSpace =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
  UIBarButtonItem* flexibleSpace2 =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
  UIBarButtonItem* flexibleSpace3 =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];

  self.slider = [[UISlider alloc] init];
  [self.slider addTarget:self
                  action:@selector(onSliderValueChanged:)
        forControlEvents:UIControlEventValueChanged];
  [self.slider addTarget:self
                  action:@selector(onTouchDown:)
        forControlEvents:UIControlEventTouchDown];
  [self.slider addTarget:self
                  action:@selector(onTouchUpInside:)
        forControlEvents:UIControlEventTouchUpInside];
  [self.slider addTarget:self
                  action:@selector(onTouchUpOutside:)
        forControlEvents:UIControlEventTouchUpOutside];
  self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  UIBarButtonItem* sliderItem = [[UIBarButtonItem alloc] initWithCustomView:self.slider];
  sliderItem.tintColor = [UIColor yellowColor];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
  {
    sliderItem.width = 500;
  }

  self.playToolbar = [NSArray arrayWithObjects:flexibleSpace,
      playButton, flexibleSpace2, self.currTime, sliderItem, self.totalTime, flexibleSpace3, nil];
  self.pauseToolbar = [NSArray arrayWithObjects:flexibleSpace,
      pauseButton, flexibleSpace2, self.currTime, sliderItem, self.totalTime, flexibleSpace3, nil];
}
@end