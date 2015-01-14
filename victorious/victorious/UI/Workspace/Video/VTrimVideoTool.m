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
#import "VVideoFrameRateComposition.h"
#import <KVOController/FBKVOController.h>

#import "VAssetThumbnailDataSource.h"

#import "VTrimmedPlayer.h"

static const int32_t kDefaultTimeScale = 600;

// Dependency Manager Keys
static NSString * const kTitleKey = @"title";
static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";

@interface VTrimVideoTool () <VTrimmerViewControllerDelegate, VTrimmedPlayerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerViewController *trimViewController;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong) VTrimmedPlayer *trimmedPlayer;

@property (nonatomic, strong) NSNumber *minDuration;
@property (nonatomic, strong) NSNumber *maxDuration;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign, readwrite) CMTime frameDuration;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) VVideoFrameRateComposition *frameRateController;

@property (nonatomic, strong) VAssetThumbnailDataSource *thumbnailDataSource;

@end

@implementation VTrimVideoTool

@synthesize selected = _selected;
@synthesize mediaURL = _mediaURL;
@synthesize playerView = _playerView;

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
    
    BOOL isLocal = [mediaURL isFileURL];
    
    self.frameRateController = [[VVideoFrameRateComposition alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    self.trimViewController.minimumStartTime = kCMTimeZero;
    int64_t maxTime = [self.maxDuration integerValue];
    int32_t timeScale = kDefaultTimeScale;
    self.trimViewController.maximumTrimDuration = CMTimeMake(maxTime * timeScale, timeScale);

    __weak typeof(self) welf = self;
    self.frameRateController.playerItemReady = ^(AVPlayerItem *playerItem)
    {
        welf.playerItem = playerItem;
        welf.trimViewController.maximumEndTime = [playerItem duration];
        
        welf.thumbnailDataSource = [[VAssetThumbnailDataSource alloc] initWithAsset:playerItem.asset];
        welf.trimViewController.thumbnailDataSource = welf.thumbnailDataSource;
    };
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    _playerItem.seekingWaitsForVideoCompositionRendering = YES;
    
    self.trimmedPlayer = [VTrimmedPlayer playerWithPlayerItem:_playerItem];
}

- (void)setTrimmedPlayer:(VTrimmedPlayer *)trimmedPlayer
{
    _trimmedPlayer = trimmedPlayer;

    self.playerView.player = trimmedPlayer;
    [self observeStatusOnTrimmedPlayer:trimmedPlayer];
    trimmedPlayer.delegate = self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (!selected)
    {
        [self.KVOController unobserve:self.trimmedPlayer
                              keyPath:NSStringFromSelector(@selector(status))];
        [self.trimmedPlayer pause];
    }
    else
    {
        [self observeStatusOnTrimmedPlayer:self.trimmedPlayer];
    }
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    [self.trimViewController reloadThumbnails];
    return self.trimViewController;
}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewControllerDidUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
                                  trimmerViewController:(VTrimmerViewController *)trimmerViewController
{
    self.trimmedPlayer.trimRange = selectedTimeRange;
}

#pragma mark - VTrimmedPlayerDelegate

- (void)trimmedPlayerPlayedToTime:(CMTime)currentPlayTime
                    trimmedPlayer:(VTrimmedPlayer *)trimmedPlayer
{
    self.trimViewController.currentPlayTime = currentPlayTime;
}

#pragma mark - Private Methods

- (void)observeStatusOnTrimmedPlayer:(VTrimmedPlayer *)trimmedPlayer
{
    __weak typeof(self) welf = self;
    [self.KVOController observe:trimmedPlayer
                        keyPath:NSStringFromSelector(@selector(status))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         VTrimmedPlayer *trimmedPlayer = object;
         switch (trimmedPlayer.status)
         {
             case AVPlayerStatusUnknown:
                 VLog(@"Player status unkown");
                 [trimmedPlayer pause];
                 break;
             case AVPlayerStatusReadyToPlay:
                 VLog(@"Player status ready to play");
                 trimmedPlayer.trimRange = welf.trimViewController.selectedTimeRange;
                 [trimmedPlayer play];
                 break;
             case AVPlayerStatusFailed:
                 VLog(@"Player status failed");
                 [trimmedPlayer pause];
                 break;
         }
     }];
}

@end
