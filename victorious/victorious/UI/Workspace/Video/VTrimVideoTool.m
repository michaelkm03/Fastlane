//
//  VTrimVideoTool.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimVideoTool.h"
#import "VTrimmerViewController.h"
#import "VVideoFrameRateComposition.h"
#import "VAssetThumbnailDataSource.h"
#import "VTrimLoopingPlayerViewController.h"

#import "VDependencyManager.h"

#import <KVOController/FBKVOController.h>

static const int32_t kDefaultTimeScale = 600;

// Dependency Manager Keys
static NSString * const kTitleKey = @"title";
static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";
static NSString * const kIconKey = @"icon";

@interface VTrimVideoTool () <VTrimmerViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerViewController *trimViewController;
//@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerController;
@property (nonatomic, strong) VTrimLoopingPlayerViewController *trimLoopingViewController;

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

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        _title = [dependencyManager stringForKey:kTitleKey];
        
        _isGIF = [[dependencyManager numberForKey:@"isGIF"] boolValue];
        
        _icon = [dependencyManager imageForKey:kIconKey];
        
        _minDuration = [dependencyManager numberForKey:kVideoMinDuration];
        _maxDuration = [dependencyManager numberForKey:kVideoMaxDuration];
        
        _muteAudio = [[dependencyManager numberForKey:kVideoMuted] boolValue];
        
        NSNumber *frameDurationValue = [dependencyManager numberForKey:kVideoFrameDurationValue];
        NSNumber *frameDurationTimescale = [dependencyManager numberForKey:kVideoFrameDurationTimescale];
        _frameDuration = CMTimeMake((int)[frameDurationValue unsignedIntegerValue], (int)[frameDurationTimescale unsignedIntegerValue]);
        
        _trimViewController = [[VTrimmerViewController alloc] initWithNibName:nil bundle:nil];
        _trimViewController.title = _title;
        _trimViewController.delegate = self;
        
        _trimLoopingViewController = [[VTrimLoopingPlayerViewController alloc] initWithNibName:nil bundle:nil];
        _trimLoopingViewController.muted = _muteAudio;
        _trimLoopingViewController.frameDuration = _frameDuration;
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
            
            if (welf.thumbnailDataSource == nil)
            {
                welf.thumbnailDataSource = [[VAssetThumbnailDataSource alloc] initWithAsset:playerItem.asset
                                                                        andVideoComposition:welf.frameRateComposition.videoComposition];
            }
            
            welf.trimViewController.thumbnailDataSource = welf.thumbnailDataSource;
        });
    };
    self.trimLoopingViewController.mediaURL = mediaURL;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected)
    {
        self.trimViewController.thumbnailDataSource = self.thumbnailDataSource;
    }
    else
    {
        self.trimViewController.thumbnailDataSource = nil;
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
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
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

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

- (UIViewController *)canvasToolViewController
{
    return self.trimLoopingViewController;
}

#pragma mark - VTrimmerViewControllerDelegate

- (void)trimmerViewController:(VTrimmerViewController *)trimmerViewController
   didUpdateSelectedTimeRange:(CMTimeRange)selectedTimeRange
{
    self.didTrim = YES;
    self.trimLoopingViewController.trimRange = selectedTimeRange;
}

- (void)trimmerViewControllerBeganSeeking:(VTrimmerViewController *)trimmerViewController
                                   toTime:(CMTime)time
{
}

- (void)trimmerViewControllerEndedSeeking:(VTrimmerViewController *)trimmerViewController
{
    self.trimLoopingViewController.trimRange = trimmerViewController.selectedTimeRange;
}

#pragma mark - Private Methods

- (void)updateStartEndTimesOnVideoPlayer
{
}

@end
