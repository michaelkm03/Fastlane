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
#import "VCVideoPlayerViewController.h"

static const int32_t kDefaultTimeScale = 600;

// Dependency Manager Keys
static NSString * const kTitleKey = @"title";
static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";

@interface VTrimVideoTool () <VTrimmerViewControllerDelegate, VTrimmedPlayerDelegate, VCVideoPlayerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerViewController *trimViewController;
@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerController;

@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;

@property (nonatomic, strong) NSNumber *minDuration;
@property (nonatomic, strong) NSNumber *maxDuration;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign, readwrite) CMTime frameDuration;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) VVideoFrameRateComposition *frameRateComposition;

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
        
        _videoPlayerController = [[VCVideoPlayerViewController alloc] initWithNibName:nil
                                                                               bundle:nil];
        _videoPlayerController.shouldFireAnalytics = NO;
//        _videoPlayerController.shouldShowToolbar = NO;
        _videoPlayerController.shouldLoop = YES;
        _videoPlayerController.delegate = self;
        _videoPlayerController.shouldChangeVideoGravityOnDoubleTap = YES;
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = [mediaURL copy];
    
    self.frameRateComposition = [[VVideoFrameRateComposition alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    self.trimViewController.minimumStartTime = kCMTimeZero;
    int64_t maxTime = [self.maxDuration integerValue];
    int32_t timeScale = kDefaultTimeScale;
    self.trimViewController.maximumTrimDuration = CMTimeMake(maxTime * timeScale, timeScale);

    __weak typeof(self) welf = self;
    self.frameRateComposition.playerItemReady = ^(AVPlayerItem *playerItem)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            welf.playerItem = playerItem;
            welf.trimViewController.maximumEndTime = [playerItem duration];
            
            welf.thumbnailDataSource = [[VAssetThumbnailDataSource alloc] initWithAsset:playerItem.asset];
            welf.trimViewController.thumbnailDataSource = welf.thumbnailDataSource;
        });
    };
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    _playerItem = playerItem;
    
    self.videoPlayerController.playerItem = playerItem;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (!selected)
    {
        [self.videoPlayerController.player pause];
    }
    else
    {
    }
}

#pragma mark - VVideoTool

- (void)exportToURL:(NSURL *)url
     withCompletion:(void (^)(BOOL finished, UIImage *previewImage))completion
{
    AVAssetExportSession *exportSession = [self.frameRateComposition makeExportable];
    exportSession.outputURL = url;
    exportSession.timeRange = self.trimViewController.selectedTimeRange;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^
    {
        if (completion)
        {
            completion(YES, nil);
        }
    }];
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    [self.trimViewController reloadThumbnails];
    return self.trimViewController;
}

- (UIViewController *)canvasToolViewController
{
    return self.videoPlayerController;
}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewControllerDidUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
                                  trimmerViewController:(VTrimmerViewController *)trimmerViewController
{
    [self.videoPlayerController setStartSeconds:CMTimeGetSeconds(selectedTimeRange.start)];
    [self.videoPlayerController setEndSeconds:CMTimeGetSeconds(CMTimeAdd(selectedTimeRange.start, selectedTimeRange.duration))];
}

#pragma mark - VTrimmedPlayerDelegate

- (void)trimmedPlayerPlayedToTime:(CMTime)currentPlayTime
                    trimmedPlayer:(VTrimmedPlayer *)trimmedPlayer
{
    self.trimViewController.currentPlayTime = currentPlayTime;
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{

}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    VLog(@"ready to play");
    [videoPlayer.player play];
}

- (void)videoPlayerFailed:(VCVideoPlayerViewController *)videoPlayer
{
    VLog(@"failed");
}

- (void)videoPlayerWasTapped
{
    VLog(@"play/pause");
    self.videoPlayerController.isPlaying ? [self.videoPlayerController.player pause] : [self.videoPlayerController.player play];
}

- (void)videoPlayerWillStopPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    
}

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    
}

@end
