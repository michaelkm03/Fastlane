//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSequencePreviewView.h"
#import "victorious-Swift.h"
#import "VVideoSettings.h"
#import "VTrackingManager.h"

/**
 Describes the state of the video preview view
 */
typedef NS_ENUM(NSUInteger, VVideoPreviewViewState)
{
    VVideoPreviewViewStateBuffering,
    VVideoPreviewViewStatePlaying,
    VVideoPreviewViewStatePaused,
    VVideoPreviewViewStateEnded
};

const CGFloat kMaximumLoopingTime = 30.0f;

@interface VVideoSequencePreviewView ()

@property (nonatomic, assign) VVideoPreviewViewState state;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) VVideoSettings *videoSettings;
@property (nonatomic, strong) VAsset *HLSAsset;
@property (nonatomic, strong) VTracking *trackingItem;
@property (nonatomic, strong) AutoplayTrackingHelper *trackingHelper;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL hasPlayed;

@property (nonatomic, strong) SoundBarView *soundIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _soundIndicator = [[SoundBarView alloc] init];
        _soundIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _soundIndicator.hidden = YES;
        [self addSubview:_soundIndicator];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_soundIndicator(20)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_soundIndicator)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_soundIndicator(16)]-10-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_soundIndicator)]];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.hidden = YES;
        [self addSubview:_activityIndicator];
        [self v_addCenterToParentContraintsToSubview:_activityIndicator];
        
        _videoSettings = [[VVideoSettings alloc] init];
        _trackingHelper = [[AutoplayTrackingHelper alloc] initWithTrackingItem:self.trackingItem];
    }
    return self;
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self setState:VVideoPreviewViewStateEnded];
    
    self.assetURL = nil;
    
    self.HLSAsset = [sequence.firstNode httpLiveStreamingAsset];
    
    // Check HLS asset to see if we should autoplay and only if it's over 30 seconds
    if ( !self.HLSAsset.streamAutoplay.boolValue )
    {
        // Check if autoplay is enabled before loading asset URL
        if ([self.videoSettings isAutoplayEnabled])
        {
            self.trackingItem = sequence.tracking;
            [self loadAssetURL:[NSURL URLWithString:self.HLSAsset.data] andLoop:NO];
        }
    }
}

- (void)loadAssetURL:(NSURL *)url andLoop:(BOOL)loop
{
    self.assetURL = url;
    
    self.hasPlayed = NO;
    
    __weak VVideoSequencePreviewView *weakSelf = self;
    [self.videoView setItemURL:url
                          loop:loop
                    audioMuted:YES
            alongsideAnimation:^
     {
         [weakSelf makeBackgroundContainerViewVisible:YES];
     }];
}

- (void)setState:(VVideoPreviewViewState)state
{
    _state = state;
    switch (state)
    {
        case VVideoPreviewViewStateBuffering:
            [self.activityIndicator startAnimating];
            self.activityIndicator.hidden = NO;
            [self.soundIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            self.videoView.hidden = NO;
            self.playIconContainerView.hidden = YES;
            break;
        case VVideoPreviewViewStatePlaying:
            [self makeBackgroundContainerViewVisible:YES];
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = NO;
            [self.soundIndicator startAnimating];
            self.videoView.hidden = NO;
            self.playIconContainerView.hidden = YES;
            break;
        case VVideoPreviewViewStatePaused:
            [self makeBackgroundContainerViewVisible:YES];
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            [self.soundIndicator stopAnimating];
            self.videoView.hidden = YES;
            self.playIconContainerView.hidden = YES;
            break;
        case VVideoPreviewViewStateEnded:
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            [self.soundIndicator stopAnimating];
            self.videoView.hidden = YES;
            self.playIconContainerView.hidden = NO;
            break;
    }
}

- (void)setHasFocus:(BOOL)hasFocus
{
    [super setHasFocus:hasFocus];
    
    // If we're not autoplaying, return right away
    if (self.assetURL == nil)
    {
        return;
    }
    
    // Play or pause video depending on focus
    if (self.inFocus)
    {
        [self playVideo];
        [self.trackingHelper trackAutoplayStart];
    }
    else
    {
        [self pauseVideo];
    }
}

- (void)playVideo
{
    if (![self.videoView playbackLikelyToKeepUp])
    {
        [self setState:VVideoPreviewViewStateBuffering];
        [self.trackingHelper trackAutoplayStall];
    }
    else
    {
        [self setState:VVideoPreviewViewStatePlaying];
    }
    [self.videoView playWithoutSeekingToBeginning];
}

- (void)pauseVideo
{
    [self setState:VVideoPreviewViewStateEnded];
    [self.videoView pauseWithoutSeekingToBeginning];
}

#pragma mark - Video Player Delegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *__nonnull)videoView
{
    [super videoViewPlayerDidBecomeReady:videoView];
    if (self.inFocus)
    {
        [self playVideo];
        [self.trackingHelper trackAutoplayStart];
    }
}

- (void)videoDidReachEnd:(VVideoView *__nonnull)videoView
{
    self.hasPlayed = YES;
    
    // Loop if asset is under max looping time
    if (self.HLSAsset.duration != nil && [self.HLSAsset.duration integerValue] <= kMaximumLoopingTime)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.videoView playFromStart];
        });
    }
    else
    {
        [self setState:VVideoPreviewViewStateEnded];
    }
}

- (void)videoViewDidStartBuffering:(VVideoView *__nonnull)videoView
{
    if (self.inFocus && self.hasPlayed)
    {
        [self setState:VVideoPreviewViewStateBuffering];
    }
}

- (void)videoViewDidStopBuffering:(VVideoView *__nonnull)videoView
{
    if (self.inFocus && !self.hasPlayed)
    {
        [self setState:VVideoPreviewViewStatePlaying];
    }
}

- (void)videoView:(VVideoView *__nonnull)videoView didProgressWithPercentComplete:(float)percent
{
    if (percent >= 25.0f && percent < 50.0f)
    {
        [self.trackingHelper trackAutoplayComplete25];
    }
    else if (percent >= 50.0f && percent < 75.0f)
    {
        [self.trackingHelper trackAutoplayComplete50];
    }
    else if (percent >= 75.0f && percent < 95.0f)
    {
        [self.trackingHelper trackAutoplayComplete75];
    }
    else if (percent >= 95.0f)
    {
        [self.trackingHelper trackAutoplayComplete100];
    }
}

@end
