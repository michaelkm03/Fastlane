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

@interface VTrimVideoTool ()

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
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.frameRateController = [[VVideoFrameRateController alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    __weak typeof(self) welf = self;
    self.frameRateController.playerItemReady = ^(AVPlayerItem *playerItem)
    {
        welf.playerItem = playerItem;
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
    
    _playerItem = playerItem;
    
    __weak typeof(self) welf = self;

    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                                             object:playerItem
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:^(NSNotification *note)
                            {
                                [welf.player seekToTime:kCMTimeZero
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
             [welf.player play];
         }
         else if (welf.player.status == AVPlayerStatusFailed)
         {
             VLog(@"Player failed: %@", welf.player.error);
         }
     }];
}

@end
