//
//  VTrimVideoTool.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimVideoTool.h"
#import "VTrimmerViewController.h"
#import "VDependencyManager.h"
#import "VVideoFrameRateComposition.h"
#import <KVOController/FBKVOController.h>
#import "VAssetThumbnailDataSource.h"
#import "VCVideoPlayerViewController.h"
#import "victorious-Swift.h"

static const int32_t kDefaultTimeScale = 600;
static const NSInteger kDefaultMaxTrimDuration = 15;

// Dependency Manager Keys
static NSString * const kTitleKey = @"title";
static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";

@interface VTrimVideoTool () <VTrimmerViewControllerDelegate, VCVideoPlayerDelegate>

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

@property (nonatomic, assign) BOOL didTrim;

@end

@implementation VTrimVideoTool

@synthesize selected = _selected;
@synthesize mediaURL = _mediaURL;
@synthesize icon = _icon;
@synthesize selectedIcon = _selectedIcon;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        _title = [dependencyManager stringForKey:kTitleKey];
        
        _isGIF = [[dependencyManager numberForKey:@"isGIF"] boolValue];
        
        _icon = [dependencyManager imageForKey:kIconKey];
        _selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
        
        _minDuration = @(1);
        
        [self setupMaxDuration];
        
        _muteAudio = [[dependencyManager numberForKey:kVideoMuted] boolValue];
        
        NSNumber *frameDurationValue = [dependencyManager numberForKey:kVideoFrameDurationValue];
        NSNumber *frameDurationTimescale = [dependencyManager numberForKey:kVideoFrameDurationTimescale];
        _frameDuration = CMTimeMake((int)[frameDurationValue unsignedIntegerValue], (int)[frameDurationTimescale unsignedIntegerValue]);
        
        _trimViewController = [[VTrimmerViewController alloc] initWithDependencyManager:dependencyManager];
        _trimViewController.title = _title;
        _trimViewController.delegate = self;
        
        _videoPlayerController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
        _videoPlayerController.shouldFireAnalytics = NO;
        _videoPlayerController.loopWithoutComposition = YES;
        _videoPlayerController.shouldShowToolbar = NO;
        _videoPlayerController.delegate = self;
        _videoPlayerController.shouldChangeVideoGravityOnDoubleTap = YES;
        _videoPlayerController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspect;
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setMediaURL:(NSURL *)mediaURL
{
    if ([_mediaURL isEqual:mediaURL])
    {
        return;
    }
    
    _mediaURL = [mediaURL copy];
    
    self.frameRateComposition = [[VVideoFrameRateComposition alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    self.trimViewController.minimumStartTime = kCMTimeZero;
    int64_t maxTime = [self.maxDuration integerValue];
    int32_t timeScale = kDefaultTimeScale;
    self.trimViewController.maximumTrimDuration = CMTimeMake(maxTime * timeScale, timeScale);

    __weak typeof(self) welf = self;
    self.frameRateComposition.onPlayerItemReady = ^(NSError *error, AVPlayerItem *playerItem)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (error)
            {
                [welf.delegate trimVideoToolFailed:welf];
                return;
            }
            
            welf.playerItem = playerItem;
            welf.trimViewController.maximumEndTime = [playerItem duration];

            if (welf.thumbnailDataSource == nil)
            {
                welf.thumbnailDataSource = [[VAssetThumbnailDataSource alloc] initWithAsset:playerItem.asset
                                                                        andVideoComposition:welf.frameRateComposition.videoComposition];
            }
            
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
    if (_selected == selected)
    {
        return;
    }
    
    _selected = selected;
    if (selected)
    {
        self.trimViewController.thumbnailDataSource = self.thumbnailDataSource;
        [self.videoPlayerController.player pause];
        [self.KVOController observe:self.videoPlayerController.player
                            keyPath:NSStringFromSelector(@selector(status))
                            options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                              block:^(id observer, id object, NSDictionary *change)
         {
             AVPlayer *player = (AVPlayer *)object;
             switch (player.status)
             {
                 case AVPlayerStatusReadyToPlay:
                 {
                     [player prerollAtRate:1.0f
                         completionHandler:^(BOOL finished)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^
                          {
                              [player play];
                          });
                      }];
                     break;
                 }
                 case AVPlayerStatusUnknown:
                 case AVPlayerStatusFailed:
                     break;
             }
         }];
    }
    else
    {
        self.trimViewController.thumbnailDataSource = nil;
        [self.videoPlayerController.player pause];
        [self.KVOController unobserve:self.videoPlayerController.player
                              keyPath:NSStringFromSelector(@selector(status))];
    }
}

#pragma mark - VVideoTool

- (void)exportToURL:(NSURL *)url
     withCompletion:(void (^)(BOOL finished, UIImage *previewImage, NSError *error))completion
{
    AVAssetExportSession *exportSession = [self.frameRateComposition makeExportable];
    exportSession.outputURL = url;
    CMTimeRange assetRange = CMTimeRangeMake(kCMTimeZero, exportSession.asset.duration);
    CMTimeRange renderRange = CMTimeRangeGetIntersection(assetRange, self.trimViewController.selectedTimeRange);
    exportSession.timeRange = renderRange;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^
    {
        AVAssetImageGenerator *thumbnailGenerator = [[AVAssetImageGenerator alloc] initWithAsset:exportSession.asset];
        thumbnailGenerator.videoComposition = [self.frameRateComposition videoComposition];
        thumbnailGenerator.appliesPreferredTrackTransform = YES;
        NSError *error;
        CGImageRef thumbnailRef = [thumbnailGenerator copyCGImageAtTime:self.trimViewController.selectedTimeRange.start
                                                             actualTime:NULL
                                                                  error:&error];
        UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailRef
                                                      scale:1.0f
                                                orientation:UIImageOrientationUp];
        CGImageRelease(thumbnailRef);
        
        if (completion)
        {
            completion(YES, thumbnailImage, exportSession.error);
        }
    }];
}

#pragma mark - Private Methods

- (void)setupMaxDuration
{
    NSNumber *userUploadDuration = VCurrentUser.maxVideoUploadDuration;
    if (userUploadDuration != nil)
    {
        _maxDuration = userUploadDuration;
    }
    else
    {
        _maxDuration = @(kDefaultMaxTrimDuration);
    }
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

- (UIViewController *)canvasToolViewController
{
    return self.videoPlayerController;
}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewController:(VTrimmerViewController *)trimmerViewController
   didUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
{
    self.didTrim = YES;
    [self.videoPlayerController setStartSeconds:CMTimeGetSeconds(selectedTimeRange.start)];
    [self.videoPlayerController setEndSeconds:CMTimeGetSeconds(CMTimeAdd(selectedTimeRange.start, selectedTimeRange.duration))];
}

- (void)trimmerViewControllerBeganSeeking:(VTrimmerViewController *)trimmerViewController
                                   toTime:(CMTime)time
{
    [self.videoPlayerController.player pause];
    [self.videoPlayerController.player seekToTime:time];
}

- (void)trimmerViewControllerEndedSeeking:(VTrimmerViewController *)trimmerViewController
{
    __weak typeof(self) welf = self;
    [self.videoPlayerController.player prerollAtRate:1.0f
                                   completionHandler:^(BOOL finished)
    {
        if (finished)
        {
            [welf.videoPlayerController.player play];
        }
    }];
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer
      didPlayToTime:(CMTime)time
{
    self.trimViewController.currentPlayTime = time;
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [videoPlayer.player play];
    });
}

- (void)videoPlayerWasTapped
{
    if (self.videoPlayerController.isPlaying)
    {
        [self.videoPlayerController.player pause];
    }
    else
    {
        [self.videoPlayerController.player play];
    }
}

@end
