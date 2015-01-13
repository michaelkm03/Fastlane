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

#import "VTrimmedPlayer.h"

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
@property (nonatomic, strong) VTrimmedPlayer *trimmedPlayer;

@property (nonatomic, strong) NSNumber *minDuration;
@property (nonatomic, strong) NSNumber *maxDuration;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign, readwrite) CMTime frameDuration;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) VVideoFrameRateComposition *frameRateController;

@property (nonatomic, strong) AVAssetImageGenerator *assetGenerator;

@end

@implementation VTrimVideoTool

@synthesize selected = _selected;
@synthesize mediaURL = _mediaURL;
@synthesize playerView = _playerView;

- (void)dealloc
{
    [self.KVOController unobserve:self.trimmedPlayer
                          keyPath:NSStringFromSelector(@selector(status))];
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
    
    self.frameRateController = [[VVideoFrameRateComposition alloc] initWithVideoURL:mediaURL
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
        
#warning Get me outta here!
        welf.assetGenerator = [[AVAssetImageGenerator alloc] initWithAsset:playerItem.asset];
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
                 [trimmedPlayer pause];
                 break;
             case AVPlayerStatusReadyToPlay:
                 [trimmedPlayer play];
                 trimmedPlayer.trimRange = welf.trimViewController.selectedTimeRange;
                 break;
             case AVPlayerStatusFailed:
                 [trimmedPlayer pause];
                 break;
         }
     }];
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
    }
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewControllerDidUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
                                  trimmerViewController:(VTrimmerViewController *)trimmerViewController
{
    self.trimmedPlayer.trimRange = selectedTimeRange;
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
