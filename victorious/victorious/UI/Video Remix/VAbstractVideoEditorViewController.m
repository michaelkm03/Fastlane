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
    [self.previewView.player seekToTime:CMTimeMakeWithSeconds(self.startSeconds, NSEC_PER_SEC)];
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
        [UIView animateKeyframesWithDuration:1.4f delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear
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
