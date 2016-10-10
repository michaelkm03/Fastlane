//
//  VTrimLoopingPlayerViewController.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrimLoopingPlayerViewController.h"
#import "UIView+AutoLayout.h"

@import KVOController;

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

@property (nonatomic, strong) id playerTimeObserver;

@end

@implementation VTrimLoopingPlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.player.currentItem];
    if (self.playerTimeObserver != nil)
    {
        [self.playerTimeObserver removeTimeObserver:self.playerTimeObserver];
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player pause];
    [self teardownKVO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.player play];
    [self setupKVO];
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
                            if (error != nil)
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
    [self.player pause];
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished)
    {
        if (finished)
        {
            [self playIfUserAllowed];
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
            [welf playWithNewComposition:composition];
        });
    });
}

- (void)playWithNewComposition:(AVComposition *)composition
{
    if (self.playerTimeObserver != nil)
    {
        [self.player removeTimeObserver:self.playerTimeObserver];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player replaceCurrentItemWithPlayerItem:[self playerItemWithAsset:composition]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    __weak typeof(self) welf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTIME_IS_VALID(self.frameDuration) ? self.frameDuration : CMTimeMake( 20, 600)
                                              queue:dispatch_get_main_queue()
                                         usingBlock:^(CMTime time)
    {
        if (!CMTIME_IS_VALID(time))
        {
            return;
        }
        CMTime timeGreaterThanDuration = time;
        while (CMTIME_COMPARE_INLINE(timeGreaterThanDuration, >, welf.trimRange.duration))
        {
            timeGreaterThanDuration = CMTimeSubtract(timeGreaterThanDuration, welf.trimRange.duration);
        }
        
        CMTime currentTime = CMTimeAdd(welf.trimRange.start, timeGreaterThanDuration);
        [welf.delegate trimLoopingPlayerDidPlayToTime:currentTime];
    }];
    
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

- (void)setupKVO
{
    __weak typeof(self) welf = self;
    [self.KVOControllerNonRetaining observe:self.player
                                    keyPath:NSStringFromSelector(@selector(status))
                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                      block:^(id observer, id object, NSDictionary *change)
     {
         __strong typeof(welf) strongSelf = welf;
         if (strongSelf == nil)
         {
             return;
         }
         if (strongSelf.player.status != AVPlayerStatusReadyToPlay)
         {
             return;
         }
         [strongSelf.player pause];
         [strongSelf.player seekToTime:kCMTimeZero
                     completionHandler:^(BOOL finished)
          {
              [strongSelf.player prerollAtRate:1.0f
                             completionHandler:^(BOOL finished)
               {
                   if (finished)
                   {
                       [strongSelf playIfUserAllowed];
                   }
               }];
          }];
     }];
    [self.KVOControllerNonRetaining observe:self.player
                                    keyPath:NSStringFromSelector(@selector(rate))
                                    options:NSKeyValueObservingOptionNew
                                      block:^(id observer, id object, NSDictionary *change)
     {
         __strong typeof(welf) strongSelf = welf;
         if (strongSelf == nil)
         {
             return;
         }
         AVPlayer *player = (AVPlayer *)object;
         if ((player.rate > 0.0f) || strongSelf.userWantsPause)
         {
             [strongSelf.acitivityIndicator stopAnimating];
         }
         else
         {
             [strongSelf.acitivityIndicator startAnimating];
         }
     }];
}

- (void)teardownKVO
{
    [self.KVOControllerNonRetaining unobserve:self.player keyPath:NSStringFromSelector(@selector(status))];
    [self.KVOControllerNonRetaining unobserve:self.player keyPath:NSStringFromSelector(@selector(rate))];
}

@end
