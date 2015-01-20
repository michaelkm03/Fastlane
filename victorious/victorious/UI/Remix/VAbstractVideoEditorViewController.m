//
//  VAbstractVideoEditorViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "VAbstractVideoEditorViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VThemeManager.h"

@interface VAbstractVideoEditorViewController ()

@property (nonatomic) BOOL waitingForVideoPlayerToStart;

@end

@implementation VAbstractVideoEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];

    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] init];
    self.videoPlayerViewController.shouldShowToolbar = NO;
    self.videoPlayerViewController.shouldFireAnalytics = NO;
    [self.videoPlayerViewController setItemURL:self.sourceURL loop:YES];
    self.videoPlayerViewController.delegate = self;
    
    [self addChildViewController:self.videoPlayerViewController];
    
    self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewParentView addSubview:self.videoPlayerViewController.view];
    UIView *videoPlayerView = self.videoPlayerViewController.view;
    [self.previewParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(videoPlayerView)]];
    [self.previewParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[videoPlayerView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(videoPlayerView)]];
    [self.videoPlayerViewController didMoveToParentViewController:self];
    [self.videoPlayerViewController.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    
    // Transparent Nav Bar
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.videoPlayerViewController.delegate = self;
    [MBProgressHUD showHUDAddedTo:self.previewParentView animated:YES];
    self.waitingForVideoPlayerToStart = YES;
    [self.videoPlayerViewController.player play];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.videoPlayerViewController.delegate = nil;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Actions

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.videoPlayerViewController.isPlaying)
    {
        switch (self.playBackSpeed)
        {
            case VPlaybackHalfSpeed:
                self.videoPlayerViewController.player.rate = 0.5f;
                break;
                
            case VPlaybackDoubleSpeed:
                self.videoPlayerViewController.player.rate = 2.0f;
                break;
                
            default:
                self.videoPlayerViewController.player.rate = 1.0f;
                break;
        }
    }
    else
    {
        [self.videoPlayerViewController.player pause];
    }
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton   *button = (UIButton *)sender;
    button.selected = !button.selected;
    self.shouldMuteAudio = button.selected;
    self.videoPlayerViewController.player.muted = self.shouldMuteAudio;
    
    if (self.shouldMuteAudio)
    {
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
    }
    else
    {
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == VPlaybackNormalSpeed)
    {
        self.playBackSpeed = VPlaybackDoubleSpeed;
        self.videoPlayerViewController.player.rate = 2.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == VPlaybackDoubleSpeed)
    {
        self.playBackSpeed = VPlaybackHalfSpeed;
        self.videoPlayerViewController.player.rate = 0.5;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == VPlaybackHalfSpeed)
    {
        self.playBackSpeed = VPlaybackNormalSpeed;
        self.videoPlayerViewController.player.rate = 1.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == VLoopOnce)
    {
        self.playbackLooping = VLoopRepeat;
        //self.videoPlayerViewController.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == VLoopRepeat)
    {
        self.playbackLooping = VLoopOnce;
        //self.videoPlayerViewController.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
}

- (void)setPlaybackLooping:(VLoopType)playbackLooping
{
    _playbackLooping = playbackLooping;

    if (self.playbackLooping == VLoopOnce)
    {
        //self.videoPlayerViewController.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == VLoopRepeat)
    {
        //self.videoPlayerViewController.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
}

#pragma mark - Animations

- (void)startAnimation
{
    //If we are already animating just ignore this and continue from where we are.
    if (self.animatingPlayButton)
    {
        return;
    }
    
    self.playButton.alpha = 1.0;
    self.playCircle.alpha = 1.0;
    self.animatingPlayButton = YES;
    [self firstAnimation];
}

- (void)firstAnimation
{
    if (self.animatingPlayButton)
    {
        [UIView animateKeyframesWithDuration:1.4f
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:^
         {
             [UIView addKeyframeWithRelativeStartTime:0      relativeDuration:.37f   animations:^{   self.playButton.alpha = 1;      }];
             [UIView addKeyframeWithRelativeStartTime:.37f   relativeDuration:.21f   animations:^{   self.playButton.alpha = .3f;    }];
             [UIView addKeyframeWithRelativeStartTime:.58f   relativeDuration:.17f   animations:^{   self.playButton.alpha = .9f;    }];
             [UIView addKeyframeWithRelativeStartTime:.75f   relativeDuration:.14f   animations:^{   self.playButton.alpha = .3f;    }];
             [UIView addKeyframeWithRelativeStartTime:.89f   relativeDuration:.11f   animations:^{   self.playButton.alpha = .5f;    }];
         }
                                  completion:^(BOOL finished)
         {
             __weak typeof(self) welf = self;
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^
             {
                 [welf firstAnimation];
             });
         }];
    }
}

- (void)stopAnimation
{
    self.animatingPlayButton = NO;
    self.playButton.alpha = 0.0;
    self.playCircle.alpha = 0.0;
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self stopAnimation];
}

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    if (self.waitingForVideoPlayerToStart && CMTIME_IS_VALID(time) && time.value > 0)
    {
        self.waitingForVideoPlayerToStart = NO;
        [MBProgressHUD hideAllHUDsForView:self.previewParentView animated:YES];
    }
}

- (void)videoPlayerWillStopPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self startAnimation];
}

@end
