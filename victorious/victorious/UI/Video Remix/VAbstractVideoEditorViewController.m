//
//  VAbstractVideoEditorViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractVideoEditorViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VElapsedTimeFormatter.h"
#import "VThemeManager.h"

@interface VAbstractVideoEditorViewController ()
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
    self.videoPlayerViewController.itemURL = self.sourceURL;
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.videoPlayerViewController.player play];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
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
            case kVPlaybackHalfSpeed:
                self.videoPlayerViewController.player.rate = 0.5f;
                break;
                
            case kVPlaybackDoubleSpeed:
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
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.shouldMuteAudio = button.selected;
    self.videoPlayerViewController.player.muted = self.shouldMuteAudio;
    
    if (self.shouldMuteAudio)
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonMute"] forState:UIControlStateNormal];
    else
        [self.muteButton setImage:[UIImage imageNamed:@"cameraButtonUnmute"] forState:UIControlStateNormal];
}

- (IBAction)playbackRateClicked:(id)sender
{
    if (self.playBackSpeed == kVPlaybackNormalSpeed)
    {
        self.playBackSpeed = kVPlaybackDoubleSpeed;
        self.videoPlayerViewController.player.rate = 2.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kVPlaybackHalfSpeed;
        self.videoPlayerViewController.player.rate = 0.5;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackHalfSpeed)
    {
        self.playBackSpeed = kVPlaybackNormalSpeed;
        self.videoPlayerViewController.player.rate = 1.0;
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kVLoopOnce)
    {
        self.playbackLooping = kVLoopRepeat;
        self.videoPlayerViewController.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kVLoopRepeat)
    {
        self.playbackLooping = kVLoopOnce;
        self.videoPlayerViewController.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
}

#pragma mark - Animations

- (void)startAnimation
{
    //If we are already animating just ignore this and continue from where we are.
    if (self.animatingPlayButton)
        return;
    
    self.playButton.alpha = 1.0;
    self.playCircle.alpha = 1.0;
    self.takeImageSnapShotButton.alpha = 1.0;
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
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                 [self firstAnimation];
             });
         }];
    }
}

- (void)stopAnimation
{
    self.animatingPlayButton = NO;
    self.playButton.alpha = 0.0;
    self.playCircle.alpha = 0.0;
    self.takeImageSnapShotButton.alpha = 0.0;
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self stopAnimation];
}

- (void)videoPlayerWillStopPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self startAnimation];
}

@end
