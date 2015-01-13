//
//  VTrimVideoTool.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimVideoTool.h"
#import "VVideoPlayerView.h"
#import "VTrimmerViewController.h"
#import "VDependencyManager.h"
#import "VVideoFrameRateController.h"
#import <KVOController/FBKVOController.h>

static NSString * const kTitleKey = @"title";

static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";

@interface VTrimVideoTool () <VTrimmerViewControllerDelegate, VTrimmerThumbnailDataSource>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerViewController *trimViewController;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, strong) NSNumber *minDuration;
@property (nonatomic, strong) NSNumber *maxDuration;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign, readwrite) CMTime frameDuration;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) VVideoFrameRateController *frameRateController;

@property (nonatomic, strong) id itemEndObserver;
@property (nonatomic, strong) id trimEndObserver;
@property (nonatomic, strong) id currentTimeObserver;

@property (nonatomic, strong) AVAssetImageGenerator *assetGenerator;

@end

@implementation VTrimVideoTool

@synthesize selected = _selected;
@synthesize mediaURL = _mediaURL;
@synthesize playerView = _playerView;

- (void)dealloc
{
    if (self.itemEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
        self.itemEndObserver = nil;
    }
    if (self.trimEndObserver)
    {
        [self.player removeTimeObserver:self.trimEndObserver];
    }
    if (self.currentTimeObserver)
    {
        [self.player removeTimeObserver:self.currentTimeObserver];
    }
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        _title = [dependencyManager stringForKey:kTitleKey];
        
        _minDuration = [dependencyManager numberForKey:kVideoMinDuration];
        _maxDuration = [dependencyManager numberForKey:kVideoMaxDuration];
        
        _muteAudio = [[dependencyManager numberForKey:kVideoMuted] boolValue];
        
        NSNumber *frameDurationValue = [dependencyManager numberForKey:kVideoFrameDurationValue];
        NSNumber *frameDurationTimescale = [dependencyManager numberForKey:kVideoFrameDurationTimescale];
        _frameDuration = CMTimeMake((int)[frameDurationValue unsignedIntegerValue], (int)[frameDurationTimescale unsignedIntegerValue]);
        
        _trimViewController = [[VTrimmerViewController alloc] initWithNibName:nil
                                                                       bundle:nil];
        _trimViewController.delegate = self;
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.trimViewController.thumbnailDataSource = self;
    
    self.frameRateController = [[VVideoFrameRateController alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    self.trimViewController.minimumStartTime = kCMTimeZero;
    int64_t maxTime = 15;
    int32_t timeScale = 600;
    self.trimViewController.maximumTrimDuration = CMTimeMake(maxTime * timeScale, timeScale);

    __weak typeof(self) welf = self;
    self.frameRateController.playerItemReady = ^(AVPlayerItem *playerItem)
    {
        welf.playerItem = playerItem;
        welf.trimViewController.maximumEndTime = [playerItem duration];
        
        welf.trimEndObserver = [welf.player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:welf.trimViewController.selectedTimeRange.duration]]
                                                                      queue:dispatch_get_main_queue()
                                                                 usingBlock:^
                                {
                                    [welf playerPlaayedToTrimEndTime];
                                }];
        
        welf.assetGenerator = [[AVAssetImageGenerator alloc] initWithAsset:playerItem.asset];
    };
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (self.itemEndObserver)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
        self.itemEndObserver = nil;
    }
    playerItem.seekingWaitsForVideoCompositionRendering = YES;
    _playerItem = playerItem;
    
    __weak typeof(self) welf = self;

    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                                             object:playerItem
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:^(NSNotification *note)
                            {
                                [welf.player seekToTime:welf.trimViewController.selectedTimeRange.start
                                      completionHandler:^(BOOL finished)
                                 {
                                     [welf.player play];
                                 }];
                            }];

    self.player = [AVPlayer playerWithPlayerItem:playerItem];
}

- (void)setPlayer:(AVPlayer *)player
{
    _player = player;
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    self.playerView.player = _player;
    [self observeStatus];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (!selected)
    {
        [_player pause];
        [_player.KVOController unobserve:self.player
                                 keyPath:NSStringFromSelector(@selector(status))];
    }
    else
    {
        [self observeStatus];
    }
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

#pragma mark - Private Methods

- (void)observeStatus
{
    __weak typeof(self) welf = self;
    
    [self.KVOController observe:self.player
                        keyPath:NSStringFromSelector(@selector(status))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         if (welf.player.status == AVPlayerStatusReadyToPlay)
         {
             VLog(@"Player ready to play...");
             if (welf.playerItem.isPlaybackLikelyToKeepUp)
             {
                 VLog(@"playback will continue...");
                 [welf.player play];
             }
             else
             {
                 VLog(@"playback will pause...");
                 [welf.player pause];
             }

             if (welf.currentTimeObserver)
             {
                 [welf.player removeTimeObserver:welf.currentTimeObserver];
                 welf.currentTimeObserver = nil;
             }
             welf.currentTimeObserver =  [welf.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30)
                                                                                   queue:dispatch_get_main_queue()
                                                                              usingBlock:^(CMTime time)
                                          {
                                              welf.trimViewController.currentPlayTime = time;
                                          }];
         }
         else if (welf.player.status == AVPlayerStatusFailed)
         {
             VLog(@"Player failed: %@", welf.player.error);
         }
         else if (welf.player.status == AVPlayerStatusUnknown)
         {
             VLog(@"player status unkown!!!!");
             if (welf.playerItem.isPlaybackLikelyToKeepUp)
             {
                 VLog(@"playback will continue...");
             }
             else
             {
                 VLog(@"playback will pause...");
             }
             [self.player pause];
         }
     }];
    [self.KVOController observe:self.player.currentItem
                        keyPath:@"isPlaybackLikelyToKeepUp"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         if (welf.player.currentItem.isPlaybackLikelyToKeepUp)
         {
             VLog(@"playback will continue...");
         }
         else
         {
             VLog(@"playback will pause...");
         }
     }];
}

- (void)playerPlaayedToTrimEndTime
{
    [self.player pause];
    self.trimViewController.currentPlayTime = self.trimViewController.selectedTimeRange.start;
    [self.player seekToTime:self.trimViewController.selectedTimeRange.start
          completionHandler:^(BOOL finished)
     {
         [self.player play];
     }];

}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewControllerDidUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
                                  trimmerViewController:(VTrimmerViewController *)trimmerViewController
{
    CMTime endTrimTime = CMTimeAdd(selectedTimeRange.start, selectedTimeRange.duration);

    BOOL currentTimeEarlierThanTrimStart = CMTIME_COMPARE_INLINE(self.player.currentTime, <, selectedTimeRange.start);
    BOOL currentTimeLaterThanTrimEnd = CMTIME_COMPARE_INLINE(self.player.currentTime, >, CMTimeAdd(selectedTimeRange.start, selectedTimeRange.duration));
    if (currentTimeEarlierThanTrimStart || currentTimeLaterThanTrimEnd)
    {
        [self.player seekToTime:selectedTimeRange.start];
    }

    __weak typeof(self) welf = self;
    if (self.trimEndObserver)
    {
        [self.player removeTimeObserver:self.trimEndObserver];
    }
    self.trimEndObserver = [self.player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:endTrimTime]]
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^
                            {
                                [welf playerPlaayedToTrimEndTime];
                            }];
}

#pragma mark - VTrimmerThumbnailDataSource

- (UIImage *)trimmerViewController:(VTrimmerViewController *)trimmer
                  thumbnailForTime:(CMTime)time
{
    VLog(@"Time: %@", [NSValue valueWithCMTime:time]);
    CGImageRef imageForTime = [self.assetGenerator copyCGImageAtTime:time
                                                          actualTime:NULL
                                                               error:nil];
    
    UIImage *imageWithImageRef = [UIImage imageWithCGImage:imageForTime];
    CGImageRelease(imageForTime);
    
    return imageWithImageRef;
}

@end
