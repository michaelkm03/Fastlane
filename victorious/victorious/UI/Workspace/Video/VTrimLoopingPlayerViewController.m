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
#import "VAssetLoader.h"
#import "AVComposition+VTrimmedLoopingComposition.h"
#import "VPlayerView.h"
#import "AVAsset+VVideoCompositionWithFrameDuration.h"
#import "AVComposition+VMutedAudioMix.h"

@import AVFoundation;

@interface VTrimLoopingPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) VAssetLoader *assetLoader;
@property (nonatomic, weak) UIActivityIndicatorView *acitivityIndicator;
@property (nonatomic, assign) BOOL userWantsPause;
@property (nonatomic, strong) dispatch_queue_t loopedCompositionQueue;

@property (nonatomic, strong) AVVideoComposition *cachedVideoCompostion;

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
    self.loopedCompositionQueue = dispatch_queue_create("com.getVictorious.loopedCompositionCreation", DISPATCH_QUEUE_SERIAL);
    
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
    if ([_mediaURL isEqual:mediaURL])
    {
        return;
    }
    _mediaURL = [mediaURL copy];
    __weak typeof(self) welf = self;
    self.assetLoader = [[VAssetLoader alloc] initWithAssetURL:mediaURL
                                                   keysToLoad:@[NSStringFromSelector(@selector(duration)), NSStringFromSelector(@selector(tracks))]
                                       prefersPreciseDuration:YES
                                                   completion:^(NSError *error, AVAsset *loadedAsset)
                        {
                            if (error)
                            {
                                return;
                            }
                            
                            __strong typeof(self) strongSelf = welf;
                            if (strongSelf == nil)
                            {
                                return;
                            }
                            [strongSelf generateLoopedCompositionWithAsset:loadedAsset];
                        }];
}

- (void)setTrimRange:(CMTimeRange)trimRange
{
    if (CMTimeRangeEqual(_trimRange, trimRange))
    {
        return;
    }
    _trimRange = trimRange;
    [self.player pause];
    if (self.assetLoader.state == VAssetLoaderStateAllKeysLoaded)
    {
        [self generateLoopedCompositionWithAsset:self.assetLoader.loadedAsset];
    }
}

#pragma mark - Notification Handlers

- (void)playerItemPlayedToEnd:(NSNotification *)notification
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

- (void)generateLoopedCompositionWithAsset:(AVAsset *)asset
{
    __weak typeof(self) welf = self;
    dispatch_async(self.loopedCompositionQueue, ^
    {
        AVComposition *composition = [AVComposition trimmedLoopingCompostionWithAsset:asset
                                                                            trimRange:welf.trimRange
                                                                      minimumDuration:CMTimeMake(2 * 60 * 600, 600)]; // 2 minutes
        dispatch_async(dispatch_get_main_queue(), ^
        {
            __strong typeof(welf) strongSelf = welf;
            [strongSelf playWithNewComposition:composition];
        });
    });
}

- (void)playWithNewComposition:(AVComposition *)composition
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player replaceCurrentItemWithPlayerItem:[self playerItemWithAsset:composition]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];

    [self playIfUserAllowed];
}

- (AVPlayerItem *)playerItemWithAsset:(AVComposition *)composition
{
    AVPlayerItem *playerItemWithAsset = [AVPlayerItem playerItemWithAsset:composition];
    if (self.isMuted)
    {
        playerItemWithAsset.audioMix = [composition mutedAudioMix];
    }
    
    playerItemWithAsset.videoComposition = self.cachedVideoCompostion ?: [composition videoCompositionWithFrameDuration:self.frameDuration];
    self.cachedVideoCompostion = playerItemWithAsset.videoComposition;
    
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
