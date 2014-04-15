//
//  VAbstractVideoEditorViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractVideoEditorViewController.h"
#import "VThemeManager.h"

@interface VAbstractVideoEditorViewController ()
@end

@implementation VAbstractVideoEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.previewView.player setItemByUrl:self.sourceURL];
    self.previewView.player.delegate = self;
    [self.previewView.player play];

    [self.previewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToPlayAction:)]];
    self.previewView.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.previewView.player.isPlaying)
        [self.previewView.player pause];
}

#pragma mark - Actions

- (IBAction)handleTapToPlayAction:(id)sender
{
    if (!self.previewView.player.isPlaying)
        [self.previewView.player play];
    else
        [self.previewView.player pause];
}

- (IBAction)muteAudioClicked:(id)sender
{
    UIButton*   button = (UIButton *)sender;
    button.selected = !button.selected;
    self.shouldMuteAudio = button.selected;
    self.previewView.player.muted = self.shouldMuteAudio;
    
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
        if ([self.previewView.player.currentItem canPlayFastForward])
            [self.previewView.player setRate:2.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedDouble"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackDoubleSpeed)
    {
        self.playBackSpeed = kVPlaybackHalfSpeed;
        if ([self.previewView.player.currentItem canPlaySlowForward])
            [self.previewView.player setRate:0.5];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedHalf"] forState:UIControlStateNormal];
    }
    else if (self.playBackSpeed == kVPlaybackHalfSpeed)
    {
        self.playBackSpeed = kVPlaybackNormalSpeed;
        [self.previewView.player setRate:1.0];
        [self.rateButton setImage:[UIImage imageNamed:@"cameraButtonSpeedNormal"] forState:UIControlStateNormal];
    }
}

- (IBAction)playbackLoopingClicked:(id)sender
{
    if (self.playbackLooping == kVLoopOnce)
    {
        self.playbackLooping = kVLoopRepeat;
        self.previewView.player.shouldLoop = YES;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonLoop"] forState:UIControlStateNormal];
    }
    else if (self.playbackLooping == kVLoopRepeat)
    {
        self.playbackLooping = kVLoopOnce;
        self.previewView.player.shouldLoop = NO;
        [self.loopButton setImage:[UIImage imageNamed:@"cameraButtonNoLoop"] forState:UIControlStateNormal];
    }
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

#pragma mark - Support

-(NSString *)secondsToMMSS:(double)seconds
{
    if (isnan(seconds))
        return @"";

    NSInteger time = floor(seconds);
    NSInteger hh = time / 3600;
    NSInteger mm = (time / 60) % 60;
    NSInteger ss = time % 60;
    if (hh > 0)
        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
    else
        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
}

#pragma mark - Animations

- (void)startAnimation
{
    //If we are already animating just ignore this and continue from where we are.
    if (self.animatingPlayButton)
        return;
    
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
}

#pragma mark - SCVideoPlayerDelegate

- (void)videoPlayerDidStartPlaying:(VCPlayer *)videoPlayer
{
    [self stopAnimation];
}

- (void)videoPlayerDidStopPlaying:(VCPlayer *)videoPlayer
{
    [self startAnimation];
}

@end
