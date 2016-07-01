//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSequencePreviewView.h"
#import "victorious-Swift.h"
#import "VTrackingManager.h"
#import "UIResponder+VResponderChain.h"
#import "VVideoPlayerToolbarView.h"
#import "VPassthroughContainerView.h"

static const CGFloat kMinimumPlayButtonInset = 14.0f;

/**
 Describes the state of the video preview view
 */
typedef NS_ENUM(NSUInteger, VVideoState)
{
    VVideoStateNotStarted,
    VVideoStateEnded,
    VVideoStateBuffering,
    VVideoStatePlaying,
    VVideoStatePaused,
    VVideoStateScrubbing
};
@interface VVideoSequencePreviewView () <VideoToolbarDelegate>

@property (nonatomic, strong) VPassthroughContainerView *videoUIContainer;
@property (nonatomic, strong, readwrite, nullable) VideoToolbarView *toolbar;
@property (nonatomic, strong) SoundBarView *soundIndicator;

@property (nonatomic, assign) VVideoState state;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL wasPlayingBeforeScrubbingStarted;

@property (nonatomic, assign) BOOL didPlay25;
@property (nonatomic, assign) BOOL didPlay50;
@property (nonatomic, assign) BOOL didPlay75;
@property (nonatomic, assign) BOOL didPlay100;

@property (nonatomic, strong) UIButton *largePlayButton;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _videoUIContainer = [[VPassthroughContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:_videoUIContainer];
        [self v_addFitToParentConstraintsToSubview:_videoUIContainer];
        
        [self setupVideoUI];
    }
    return self;
}

- (void)setupVideoUI
{
    self.soundIndicator = [[SoundBarView alloc] initWithNumberOfBars:3 distanceBetweenBars:1.0];
    self.soundIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.soundIndicator.alpha = 0;
    [self.videoUIContainer addSubview:self.soundIndicator];
    NSDictionary *views = @{ @"soundIndicator" : self.soundIndicator };
    NSDictionary *metrics = @{ @"left" : @(10.0),
                               @"right" : @(10.0),
                               @"width" : @(16.0),
                               @"height" : @(14.0) };
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-left-[soundIndicator(height)]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[soundIndicator(width)]-right-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    UIImage *playIcon = [UIImage imageNamed:@"play-btn-icon"];
    self.largePlayButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.largePlayButton setImage:playIcon forState:UIControlStateNormal];
    [self.largePlayButton addTarget:self action:@selector(onPreviewPlayButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.largePlayButton.backgroundColor = [UIColor clearColor];
    [self.videoUIContainer addSubview:self.largePlayButton];
    [self.videoUIContainer v_addCenterToParentContraintsToSubview:self.largePlayButton];
    self.largePlayButton.userInteractionEnabled = NO;
    self.largePlayButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *constraintMetrics = @{ @"minInset" : @(kMinimumPlayButtonInset), @"priority" : @(990) };
    NSDictionary *constraintViews = @{ @"playButton" : self.largePlayButton };
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=minInset@priority)-[playButton]-(>=minInset@priority)-|"
                                                                                  options:kNilOptions
                                                                                  metrics:constraintMetrics
                                                                                    views:constraintViews]];
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=minInset@priority)-[playButton]-(>=minInset@priority)-|"
                                                                                  options:kNilOptions
                                                                                  metrics:constraintMetrics
                                                                                    views:constraintViews]];
    [self.largePlayButton addConstraint:[NSLayoutConstraint constraintWithItem:self.largePlayButton
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.largePlayButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
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
    self.videoPlayer.useAspectFit = !self.videoPlayer.useAspectFit;
}

- (BOOL)toolbarDisabled
{
    return NO;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if ( self.toolbarDisabled )
    {
        return;
    }
    
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
        [self.toolbar setVisible:YES animated:YES];
    }
    else if ( _toolbar != nil )
    {
        [self.toolbar setVisible:NO animated:YES];
    }
}

- (void)hideToolbar
{
    if ( _toolbar != nil )
    {
        self.toolbar.hidden = YES;
    }
}

- (void)loadVideoAsset
{
    [self resetTracking];
    self.state = VVideoStateNotStarted;
    
    self.videoAsset = [self.sequence.firstNode httpLiveStreamingAsset];
    
    VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:[NSURL URLWithString:self.videoAsset.data]];
    item.muted = self.videoAsset.audioMuted.boolValue;
    item.remoteContentId = self.videoAsset.remoteContentId;
    [self.videoPlayer setItem:item];
    
    [self updateUIState];
}

- (void)resetTracking
{
    self.didPlay25 = NO;
    self.didPlay50 = NO;
    self.didPlay75 = NO;
    self.didPlay100 = NO;
}

- (void)setState:(VVideoState)state
{
    _state = state;
    [self updateUIState];
}

- (void)updateUIState
{
    // Toolbar
    [self setToolbarHidden:self.focusType != VFocusTypeDetail animated:self.focusType != VFocusTypeNone];
    self.toolbar.paused = self.state != VVideoStatePlaying;
    
    // Tap/Double Tap gestures
    [self setGesturesEnabled:self.focusType == VFocusTypeDetail];
    
    // Play button and preview image
    if ( self.focusType == VFocusTypeDetail )
    {
        // Aspect ratio
        self.videoPlayer.useAspectFit = YES;
        
        self.largePlayButton.userInteractionEnabled = YES;
        if ( self.state == VVideoStateNotStarted )
        {
            self.largePlayButton.hidden = YES;
            self.previewImageView.hidden = YES;
            self.videoPlayer.view.hidden = YES;
        }
        else
        {
            self.largePlayButton.hidden = YES;
            self.previewImageView.hidden = YES;
            self.videoPlayer.view.hidden = NO;
        }
    }
    else
    {
        // Set proper aspect ratio for stream focus type
        self.videoPlayer.useAspectFit = self.streamContentModeIsAspectFit;
        
        self.largePlayButton.userInteractionEnabled = NO;
        if ( self.shouldAutoplay )
        {
            if (self.state == VVideoStateNotStarted)
            {
                self.largePlayButton.hidden = YES;
                self.previewImageView.hidden = NO;
                self.videoPlayer.view.hidden = YES;
            }
            else
            {
                self.largePlayButton.hidden = YES;
                self.videoPlayer.view.hidden = NO;
            }
        }
        else
        {
            self.largePlayButton.hidden = NO;
            self.previewImageView.hidden = NO;
            self.videoPlayer.view.hidden = YES;
        }
    }
    
    // Sound indicator
    BOOL soundIdicatorHidden = !([self shouldAutoplay] && self.state == VVideoStatePlaying && self.focusType == VFocusTypeStream);
    soundIdicatorHidden ? [self.soundIndicator stopAnimating] : [self.soundIndicator startAnimating];
    CGFloat newAlpha = soundIdicatorHidden ? 0 : 1;
    if (self.soundIndicator.alpha == newAlpha)
    {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^
    {
        self.soundIndicator.alpha = newAlpha;
    }];
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    if ( super.focusType != focusType && focusType == VFocusTypeDetail )
    {
        // When entering .Detail focus, tracking must be reset to account for non-autoplay views
        [self resetTracking];
    }
    
    super.focusType = focusType;
    
    [self updateUIState];
}

- (void)onPreviewPlayButtonTapped:(UIButton *)button
{
    [self.videoPlayer playFromStart];
}

#pragma mark - Helpers

- (void)trackAutoplayEvent:(NSString *)event urls:(NSArray *)urls
{
    VideoTrackingEvent *trackingEvent = [[VideoTrackingEvent alloc] initWithName:event urls:urls ?: @[]];
    trackingEvent.currentTime = @([self.videoPlayer currentTimeSeconds]);
    
    id<VideoTracking>responder = [self v_targetConformingToProtocol:@protocol(VideoTracking)];
    if ( responder != nil )
    {
        // If there's a responder to handle this, then use that.  This allows other parts
        // of the responder chain to add context to the tracking event before the repsonder handles
        // performing the tracking call
        [responder trackAutoplayEvent:trackingEvent];
    }
    else
    {
        // Otherwise, just do the tracking call with the current info we have
        [trackingEvent track];
    }
}

- (NSDictionary *)trackingInfo
{
    return @{VTrackingKeyTimeCurrent : @(self.videoPlayer.currentTimeMilliseconds) };
}

- (void)updateQuartileTracking
{
    if ( self.trackingData == nil )
    {
        VLog( @"Cannot track video events without a valid `trackingData`" );
        return;
    }
    
    const float percent = (self.videoPlayer.currentTimeSeconds / self.videoPlayer.durationSeconds) * 100.0f;
    if (percent >= 25.0f && percent < 50.0f && !self.didPlay25)
    {
        self.didPlay25 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete25 urls:(NSArray *)self.trackingData.videoComplete25];
    }
    else if (percent >= 50.0f && percent < 75.0f && !self.didPlay50)
    {
        self.didPlay50 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete50 urls:(NSArray *)self.trackingData.videoComplete50];
    }
    else if (percent >= 75.0f && percent < 95.0f && !self.didPlay75)
    {
        self.didPlay75 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete75 urls:(NSArray *)self.trackingData.videoComplete75];
    }
    else if (percent >= 95.0f && !self.didPlay100)
    {
        self.didPlay100 = YES;
        [self trackAutoplayEvent:VTrackingEventVideoDidComplete100 urls:(NSArray *)self.trackingData.videoComplete100];
    }
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidBecomeReady:videoPlayer];
    self.state = VVideoStatePlaying;
}

- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer
{
    [self.videoPlayer pause];
    
    if ( self.shouldLoop )
    {
        [self.videoPlayer playFromStart];
    }
    else
    {
        self.state = VVideoStateEnded;
        [super videoPlayerDidReachEnd:videoPlayer];
    }
}

- (void)videoPlayerDidStartBuffering:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidStartBuffering:videoPlayer];
    if (self.state != VVideoStateScrubbing )
    {
        self.state = VVideoStateBuffering;
    }
}

- (void)videoPlayerDidStopBuffering:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidStopBuffering:videoPlayer];
    if ( self.state != VVideoStateEnded && self.state != VVideoStateScrubbing)
    {
        self.state = VVideoStatePlaying;
        [self.videoPlayer play];
    }
}

- (void)videoPlayer:(VVideoView *__nonnull)videoPlayer didPlayToTime:(Float64)time
{
    [super videoPlayer:videoPlayer didPlayToTime:time];
    
    if ( self.toolbar != nil )
    {   
        [self.toolbar setCurrentTime:videoPlayer.currentTimeSeconds duration:videoPlayer.durationSeconds];
    }
    
    [self updateQuartileTracking];
}

- (void)videoPlayerDidPlay:(id<VVideoPlayer> __nonnull)videoPlayer
{
    [super videoPlayerDidPlay:videoPlayer];
    self.state = VVideoStatePlaying;
}

- (void)videoPlayerDidPause:(id<VVideoPlayer> __nonnull)videoPlayer
{
    [super videoPlayerDidPause:videoPlayer];
    if ( self.state != VVideoStateNotStarted )
    {
        self.state = VVideoStatePaused;
    }
}

#pragma mark - VideoToolbarDelegate

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didStartScrubbingToLocation:(float)location
{
    self.wasPlayingBeforeScrubbingStarted = self.videoPlayer.isPlaying;
    [self.videoPlayer pause];
    self.state = VVideoStateScrubbing;
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didScrubToLocation:(float)location
{
    NSTimeInterval timeSeconds = location * self.videoPlayer.durationSeconds;
    [self.videoPlayer seekToTimeSeconds:timeSeconds];
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didEndScrubbingToLocation:(float)location
{
    if ( self.wasPlayingBeforeScrubbingStarted )
    {
        self.wasPlayingBeforeScrubbingStarted = NO;
        [self.videoPlayer play];
    }
    else
    {
        self.state = VVideoStatePaused;
    }
}

- (void)videoToolbarDidPause:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.videoPlayer pause];
}

- (void)videoToolbarDidPlay:(VideoToolbarView *__nonnull)videoToolbar
{
    [self.videoPlayer play];
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