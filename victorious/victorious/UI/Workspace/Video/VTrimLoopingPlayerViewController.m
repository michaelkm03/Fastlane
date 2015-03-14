//
//  VTrimLoopingPlayerViewController.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrimLoopingPlayerViewController.h"
#import "UIView+AutoLayout.h"

#import <KVOController/FBKVOController.h>

// Video
#import "VLoopingCompositionGenerator.h"
#import "VPlayerView.h"
#import "AVAsset+VVideoCompositionWithFrameDuration.h"
#import "AVComposition+VMutedAudioMix.h"

@import AVFoundation;

@interface VTrimLoopingPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) VLoopingCompositionGenerator *loopingAssetGenerator;
@property (nonatomic, weak) UIActivityIndicatorView *acitivityIndicator;
@property (nonatomic, assign) BOOL userWantsPause;

@end

@implementation VTrimLoopingPlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.player.currentItem];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _player = [[AVPlayer alloc] init];
        _frameDuration = CMTimeMake(20, 600); // Default 30fps
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[VPlayerView alloc] initWithPlayer:self.player];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:activityIndicator];
    [self.view v_addCenterToParentContraintsToSubview:activityIndicator];
    self.acitivityIndicator = activityIndicator;
    
    UITapGestureRecognizer *tapGestureRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(playerViewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognzier];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(status))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                          block:^(id observer, id object, NSDictionary *change)
    {
        if (self.player.status != AVPlayerStatusReadyToPlay)
        {
            return;
        }
        [self.player seekToTime:kCMTimeZero
              completionHandler:^(BOOL finished)
         {
             if (finished)
             {
                 [self playIfUserAllowed];
             }
         }];
    }];
    __weak typeof(self) welf = self;
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(rate))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         AVPlayer *player = (AVPlayer *)object;
         if ((player.rate > 0.0f) || self.userWantsPause)
         {
             [welf.acitivityIndicator stopAnimating];
         }
         else
         {
             [welf.acitivityIndicator startAnimating];
         }
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player pause];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.player play];
}

- (VPlayerView *)playerView
{
    return (VPlayerView *)self.view;
}

#pragma mark - Target/Action

- (void)playerViewTapped:(UITapGestureRecognizer *)tapGesture
{
    self.userWantsPause = !self.userWantsPause;
}

#pragma mark - Property Accessors

- (void)setUserWantsPause:(BOOL)userWantsPause
{
    _userWantsPause = userWantsPause;
    if (userWantsPause)
    {
        [self.player pause];
    }
    else
    {
        [self playIfUserAllowed];
    }
}

#pragma mark - Public Methods

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.loopingAssetGenerator = [[VLoopingCompositionGenerator alloc] initWithURL:mediaURL];
    [self.loopingAssetGenerator startLoading];
}

- (void)setTrimRange:(CMTimeRange)trimRange
{
    if (CMTimeRangeEqual(_trimRange, trimRange))
    {
        return;
    }
    _trimRange = trimRange;
    __weak typeof(self) welf = self;
    [self.player pause];
    [self.loopingAssetGenerator setTrimRange:trimRange
                                      CMTime:CMTimeMake(2 * 60 * 600, 600) // 2 minutes
                              withCompletion:^(NSError *error, AVComposition *loopedComposition)
    {
        if (error)
        {
#warning Handle ME!
        }
        __strong typeof(welf) strongSelf = welf;
        if (strongSelf == nil)
        {
            return;
        }
        [strongSelf playWithNewComposition:loopedComposition];
    }];
}

#pragma mark - Notification Handlers

- (void)playerReachedEnd:(NSNotification *)notification
{
    __weak typeof(self) welf = self;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished)
    {
        if (finished)
        {
            [welf playIfUserAllowed];
        }
    }];
}

#pragma mark - Private Methods

- (void)playWithNewComposition:(AVComposition *)composition
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player replaceCurrentItemWithPlayerItem:[self playerItemWithAsset:composition]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];

    [self playIfUserAllowed];
}

- (AVPlayerItem *)playerItemWithAsset:(AVComposition *)composition
{
    AVPlayerItem *playerItemWithAsset = [AVPlayerItem playerItemWithAsset:composition];
    if (self.isMuted)
    {
        playerItemWithAsset.audioMix = [composition mutedAudioMix];
    }
    playerItemWithAsset.videoComposition = [composition videoCompositionWithFrameDuration:self.frameDuration];
    
    return playerItemWithAsset;
}

- (void)playIfUserAllowed
{
    if (self.userWantsPause)
    {
        return;
    }
    [self.player play];
}

@end
