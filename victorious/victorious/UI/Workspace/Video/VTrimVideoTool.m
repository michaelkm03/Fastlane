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
#import "VVideoFrameRateController.h"

static NSString * const kVideoFrameDurationValue = @"frameDurationValue";
static NSString * const kVideoFrameDurationTimescale = @"frameDurationTimescale";
static NSString * const kVideoMaxDuration = @"videoMaxDuration";
static NSString * const kVideoMinDuration = @"videoMinDuration";
static NSString * const kVideoMuted = @"videoMuted";

@interface VTrimVideoTool ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VTrimmerViewController *trimViewController;

@property (nonatomic, strong) NSNumber *minDuration;
@property (nonatomic, strong) NSNumber *maxDuration;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign) CMTime frameDuration;

@property (nonatomic, strong) VVideoFrameRateController *frameRateController;

@end

@implementation VTrimVideoTool

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
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
    _mediaURL = mediaURL;
    
    self.frameRateController = [[VVideoFrameRateController alloc] initWithVideoURL:mediaURL
                                                                     frameDuration:self.frameDuration
                                                                         muteAudio:self.muteAudio];
    __weak typeof(self) welf = self;
    self.frameRateController.playerItemReady = ^(AVPlayerItem *playerItem)
    {
        if (welf.playerItemReady)
        {
            welf.playerItemReady(playerItem);
        }
    };
}

- (void)setPlayerItemReady:(void (^)(AVPlayerItem *))playerItemReady
{
    _playerItemReady = [playerItemReady copy];
}

#pragma mark - VWorkspaceTool

- (UIViewController *)inspectorToolViewController
{
    return self.trimViewController;
}

- (NSString *)title
{
    return @"Video";
}

@end
