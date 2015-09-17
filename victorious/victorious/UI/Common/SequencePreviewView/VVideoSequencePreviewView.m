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
#import "UIResponder+VResponderChain.h"
#import "VVideoPlayerToolbarView.h"

/**
 Describes the state of the video preview view
 */
typedef NS_ENUM(NSUInteger, VSequenceVideoPreviewViewUIState)
{
    VSequenceVideoPreviewViewUIStateEnded,
    VSequenceVideoPreviewViewUIStateBuffering,
    VSequenceVideoPreviewViewUIStatePlaying,
    VSequenceVideoPreviewViewUIStatePaused,
};

static const CGFloat kMaximumLoopingTime = 30.0f;
static const NSTimeInterval kPreviewVisibilityAnimationDuration = 0.4f;

@interface VVideoSequencePreviewView () <VideoToolbarDelegate>

@property (nonatomic, strong) VideoToolbarView *toolbar;
@property (nonatomic, assign) VSequenceVideoPreviewViewUIState state;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) VVideoSettings *videoSettings;
@property (nonatomic, strong) VAsset *HLSAsset;
@property (nonatomic, strong) VTracking *trackingItem;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL noReplay;
@property (nonatomic, assign) BOOL wasPlayingBeforeScrubbingStarted;

@property (nonatomic, strong) SoundBarView *soundIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL didPlay25;
@property (nonatomic, assign) BOOL didPlay50;
@property (nonatomic, assign) BOOL didPlay75;
@property (nonatomic, assign) BOOL didPlay100;

@property (nonatomic, readonly) BOOL shouldAutoplay;

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
        
        [self updateUIState];
    }
    return self;
}

- (void)onContentTap
{
    if ( !self.toolbar.isVisible )
    {
        [self setToolbarHidden:NO animated:YES];
    }
    else if ( self.toolbar != nil )
    {
        [self setToolbarHidden:YES animated:YES];
    }
}

- (void)onContentDoubleTap
{
    self.videoView.useAspectFit = !self.videoView.useAspectFit;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if ( !hidden )
    {
        if ( self.toolbar == nil )
        {
            self.toolbar = [VideoToolbarView viewFromNib];
            self.toolbar.delegate = self;
            [self addSubview:self.toolbar];
            [self.toolbar v_addHeightConstraint:41.0f];
            [self v_addPinToLeadingTrailingToSubview:self.toolbar];
            [self v_addPinToBottomToSubview:self.toolbar];
        }
        [self.toolbar showWithAnimated:YES];
    }
    else if ( _toolbar != nil )
    {
        [self.toolbar hideWithAnimated:animated];
    }
}

- (void)hideToolbar
{
    if ( _toolbar != nil )
    {
        self.toolbar.hidden = YES;
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    self.videoView.alpha = 0;
    
    if ( !self.onlyShowPreview )
    {
        self.HLSAsset = [sequence.firstNode httpLiveStreamingAsset];
        self.trackingItem = sequence.tracking;
        [self loadAssetURL:[NSURL URLWithString:self.HLSAsset.data] andLoop:NO];
    }
    [self updateUIState];
}

- (BOOL)shouldAutoplay
{
    self.HLSAsset = [self.sequence.firstNode httpLiveStreamingAsset];
    return !self.onlyShowPreview && self.HLSAsset.streamAutoplay.boolValue && [self.videoSettings isAutoplayEnabled];
}

- (void)loadAssetURL:(NSURL *)url andLoop:(BOOL)loop
{
    self.assetURL = url;
    
    [self reset];
    
    __weak VVideoSequencePreviewView *weakSelf = self;
    [self.videoView setItemURL:url
                          loop:loop
                    audioMuted:YES
            alongsideAnimation:^
     {
         [weakSelf setBackgroundContainerViewVisible:YES];
     }];
}

- (void)reset
{
    self.noReplay = NO;
    
    self.didPlay25 = NO;
    self.didPlay50 = NO;
    self.didPlay75 = NO;
    self.didPlay100 = NO;
}

- (void)setState:(VSequenceVideoPreviewViewUIState)state
{
    _state = state;
    
    [self updateUIState];
}

- (void)updateUIState
{
    switch (self.state)
    {
        case VSequenceVideoPreviewViewUIStateBuffering:
            [self.activityIndicator startAnimating];
            self.activityIndicator.hidden = NO;
            [self.soundIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            self.videoView.hidden = NO;
            self.largePlayButton.hidden = YES;
            break;
        case VSequenceVideoPreviewViewUIStatePlaying:
            [self setBackgroundContainerViewVisible:YES];
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = self.focusType != VFocusTypeStream;
            [self.soundIndicator startAnimating];
            self.videoView.hidden = NO;
            self.largePlayButton.hidden = YES;
            break;
        case VSequenceVideoPreviewViewUIStatePaused:
            [self setBackgroundContainerViewVisible:YES];
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            [self.soundIndicator stopAnimating];
            self.videoView.hidden = YES;
            self.largePlayButton.hidden = YES;
            break;
        case VSequenceVideoPreviewViewUIStateEnded:
            [self.activityIndicator stopAnimating];
            self.soundIndicator.hidden = YES;
            [self.soundIndicator stopAnimating];
            self.videoView.hidden = YES;
            self.largePlayButton.hidden = NO;
            break;
    }
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    
    if ( !self.shouldAutoplay && focusType == VFocusTypeStream )
    {
        focusType = VFocusTypeNone;
    }
    
    if ( super.focusType == focusType)
    {
        return;
    }
    
    super.focusType = focusType;
    
    // If we're not autoplaying, return right away
    if (self.assetURL == nil)
    {
        return;
    }
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            if ( !self.shouldAutoplay )
            {
                [self setState:VSequenceVideoPreviewViewUIStateEnded];
                [self.videoView seekToTimeSeconds:0.0f];
            }
            [self pauseVideo];
            [self showPreview];
            [self setToolbarHidden:YES animated:YES];
            self.userInteractionEnabled = NO;
            self.toolbar.autoVisbilityTimerEnabled = NO;
            self.videoView.muted = YES;
            break;
            
        case VFocusTypeStream:
            [self playVideo];
            [self hidePreview];
            [self trackAutoplayEvent:VTrackingEventViewDidStart urls:self.trackingItem.viewStart];
            [self setGesturesEnabled:NO];
            [self setToolbarHidden:YES animated:YES];
            self.userInteractionEnabled = NO;
            self.toolbar.autoVisbilityTimerEnabled = NO;
            self.videoView.muted = YES;
            break;
            
        case VFocusTypeDetail:
            self.trackingItem = self.sequence.tracking;
            [self loadAssetURL:[NSURL URLWithString:[self.sequence.firstNode httpLiveStreamingAsset].data] andLoop:NO];
            [self playVideo];
            [self hidePreview];
            [self setGesturesEnabled:YES];
            self.videoView.muted = NO;
            self.userInteractionEnabled = YES;
            self.toolbar.autoVisbilityTimerEnabled = YES;
            [self setToolbarHidden:NO animated:YES];
            break;
    }
    [self updateUIState];
}

- (void)playVideo
{
    if (![self.videoView playbackLikelyToKeepUp])
    {
        [self setState:VSequenceVideoPreviewViewUIStateBuffering];
        [self trackAutoplayEvent:VTrackingEventVideoDidStall urls:self.trackingItem.videoStall];
    }
    else
    {
        [self setState:VSequenceVideoPreviewViewUIStatePlaying];
        [self trackAutoplayEvent:VTrackingEventViewDidStart urls:self.trackingItem.viewStart];
    }
}

- (void)onPreviewPlayButtonTapped:(UIButton *)button
{
    [self.videoView playFromStart];
    [self playVideo];
}

- (void)pauseVideo
{
    [self.videoView pause];
}

- (void)showPreview
{
    [UIView animateWithDuration:kPreviewVisibilityAnimationDuration
                     animations:^
     {
         self.videoView.alpha = 0.0f;
     } completion:^(BOOL finished)
     {
         [self.videoView pause];
     }];
}

- (void)hidePreview
{
    [self.videoView play];
    [UIView animateWithDuration:kPreviewVisibilityAnimationDuration animations:^
     {
         self.videoView.alpha = 1.0f;
     } completion:nil];
}

#pragma mark - Helpers

- (void)trackAutoplayEvent:(NSString *)event urls:(NSArray *)urls
{
    AutoplayTrackingEvent *trackingEvent = [[AutoplayTrackingEvent alloc] initWithName:event urls:urls ?: @[]];
    
    // Walk responder chain to track autoplay events
    id<AutoplayTracking>responder = [self v_targetConformingToProtocol:@protocol(AutoplayTracking)];
    if (responder != nil)
    {
        [responder trackAutoplayEvent:trackingEvent];
    }
}

- (NSDictionary *)trackingInfo
{
    return @{VTrackingKeyTimeCurrent : [NSNumber numberWithUnsignedInteger:[self.videoView currentTimeMilliseconds]]};
}

- (void)updateQuartileTracking
{
    const float percent = (self.videoView.currentTimeSeconds / self.videoView.durationSeconds) * 100.0f;
    if (percent >= 25.0f && percent < 50.0f && !self.didPlay25)
    {
        self.didPlay25 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete25 urls:self.trackingItem.videoComplete25];
    }
    else if (percent >= 50.0f && percent < 75.0f && !self.didPlay50)
    {
        self.didPlay50 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete50 urls:self.trackingItem.videoComplete50];
    }
    else if (percent >= 75.0f && percent < 95.0f && !self.didPlay75)
    {
        self.didPlay75 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete75 urls:self.trackingItem.videoComplete75];
    }
    else if (percent >= 95.0f && !self.didPlay100)
    {
        self.didPlay100 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete100 urls:self.trackingItem.videoComplete100];
    }
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(VVideoView *__nonnull)videoView
{
    [super videoPlayerDidBecomeReady:videoView];
    if ( self.focusType != VFocusTypeNone && self.shouldAutoplay )
    {
        [self playVideo];
    }
}

- (void)videoDidReachEnd:(VVideoView *__nonnull)videoView
{
    if ( self.focusType != VFocusTypeDetail || self.HLSAsset.loop.boolValue )
    {
        // Loop if asset is under max looping time
        if (self.HLSAsset.duration != nil && [self.HLSAsset.duration integerValue] <= kMaximumLoopingTime)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self.videoView playFromStart];
                           });
        }
    }
    else
    {
        self.noReplay = YES;
        [self setState:VSequenceVideoPreviewViewUIStateEnded];
        [self.delegate videoPlaybackDidFinish];
    }
}

- (void)videoPlayerDidStartBuffering:(VVideoView *__nonnull)videoView
{
    if ( self.focusType != VFocusTypeNone && !self.noReplay )
    {
        [self setState:VSequenceVideoPreviewViewUIStateBuffering];
    }
}

- (void)videoPlayerDidStopBuffering:(VVideoView *__nonnull)videoView
{
    if ( self.focusType != VFocusTypeNone && !self.noReplay )
    {
        [self setState:VSequenceVideoPreviewViewUIStatePlaying];
    }
}

- (void)videoPlayer:(VVideoView *__nonnull)videoView didPlayToTime:(Float64)time
{
    if ( self.toolbar != nil )
    {   
        [self.toolbar setCurrentTime:videoView.currentTimeSeconds duration:videoView.durationSeconds];
    }
    
    [self updateQuartileTracking];
}

- (void)videoPlayerDidPlay:(id<VVideoPlayer> __nonnull)videoPlayer
{
    self.toolbar.paused = NO;
}

- (void)videoPlayerDidPause:(id<VVideoPlayer> __nonnull)videoPlayer
{
    self.toolbar.paused = YES;
    [self.toolbar showWithAnimated:YES];
}

#pragma mark - VideoToolbarDelegate

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didStartScrubbingToLocation:(float)location
{
    self.wasPlayingBeforeScrubbingStarted = self.videoView.isPlaying;
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didScrubToLocation:(float)location
{
    NSTimeInterval timeSeconds = location * self.videoView.durationSeconds;
    [self.videoView pause];
    [self.videoView seekToTimeSeconds:timeSeconds];
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didEndScrubbingToLocation:(float)location
{
    if ( self.wasPlayingBeforeScrubbingStarted )
    {
        self.wasPlayingBeforeScrubbingStarted = NO;
        [self.videoView play];
    }
}

- (void)videoToolbarDidPause:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.videoView pause];
}

- (void)videoToolbarDidPlay:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.videoView play];
}

- (void)animateAlongsideVideoToolbarWillAppear:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.delegate animateAlongsideVideoToolbarWillAppear];
    self.likeButton.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.likeButton.bounds));
}

- (void)animateAlongsideVideoToolbarWillDisappear:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.delegate animateAlongsideVideoToolbarWillDisappear];
    self.likeButton.transform = CGAffineTransformMakeTranslation(0, 0);
}

@end