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
#import "VLoopingAssetGenerator.h"
#import "VPlayerView.h"
#import "AVAsset+VVideoCompositionWithFrameDuration.h"
#import "AVComposition+VMutedAudioMix.h"

@import AVFoundation;

@interface VTrimLoopingPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) VLoopingAssetGenerator *loopingAssetGenerator;
@property (nonatomic, weak) UIActivityIndicatorView *acitivityIndicator;

@end

@implementation VTrimLoopingPlayerViewController

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
                 [self.player play];
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
         if (player.rate > 0.0f)
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

#pragma mark - Public Methods

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.loopingAssetGenerator = [[VLoopingAssetGenerator alloc] initWithURL:mediaURL];
    __weak typeof(self) welf = self;
    self.loopingAssetGenerator.loopedAssetBecameAvailable = ^void(AVAsset *loopedAsset)
    {
        __strong typeof(welf) strongSelf = welf;
        if (strongSelf == nil)
        {
            return;
        }
        [strongSelf playWithNewAsset:loopedAsset];
    };;
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
                              withCompletion:^(AVAsset *loopedAsset)
     {
         __strong typeof(welf) strongSelf = welf;
         if (strongSelf == nil)
         {
             return;
         }
         [strongSelf playWithNewAsset:loopedAsset];
     }];
}

#pragma mark - Private Methods

- (void)playWithNewAsset:(AVAsset *)asset
{
    AVComposition *composition = (AVComposition *)asset;

    AVPlayerItem *playerItemWithAsset = [AVPlayerItem playerItemWithAsset:composition];
    if (self.isMuted)
    {
        playerItemWithAsset.audioMix = [composition mutedAudioMix];
    }
    playerItemWithAsset.videoComposition = [composition videoCompositionWithFrameDuration:self.frameDuration];
    
    [self.player replaceCurrentItemWithPlayerItem:playerItemWithAsset];
    [self.player play];
}

@end
