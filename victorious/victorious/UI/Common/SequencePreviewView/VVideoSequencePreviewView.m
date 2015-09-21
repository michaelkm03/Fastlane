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
};
@interface VVideoSequencePreviewView () <VideoToolbarDelegate>

@property (nonatomic, strong) UIView *videoUIContainer;
@property (nonatomic, strong) VideoToolbarView *toolbar;
@property (nonatomic, strong) SoundBarView *soundIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) VVideoState state;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) VTracking *trackingItem;
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
        _videoUIContainer = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_videoUIContainer];
        [self v_addFitToParentConstraintsToSubview:_videoUIContainer];
        
        [self setupVideoUI];
    }
    return self;
}

- (void)setupVideoUI
{
    self.soundIndicator = [[SoundBarView alloc] init];
    self.soundIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.soundIndicator.hidden = YES;
    [self.videoUIContainer addSubview:self.soundIndicator];
    NSDictionary *views = @{ @"soundIndicator" : self.soundIndicator };
    NSDictionary *metrics = @{ @"left" : @(10.0),
                               @"right" : @(10.0),
                               @"width" : @(16.0),
                               @"height" : @(20.0) };
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-left-[soundIndicator(height)]"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    [self.videoUIContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[soundIndicator(width)]-right-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.videoUIContainer addSubview:self.activityIndicator];
    [self.videoUIContainer v_addCenterToParentContraintsToSubview:self.activityIndicator];
    
    
    UIImage *playIcon = [UIImage imageNamed:@"play-btn-icon"];
    self.largePlayButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.largePlayButton setImage:playIcon forState:UIControlStateNormal];
    [self.largePlayButton addTarget:self action:@selector(onPreviewPlayButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.largePlayButton.backgroundColor = [UIColor clearColor];
    [self.videoUIContainer addSubview:self.largePlayButton];
    [self.videoUIContainer v_addCenterToParentContraintsToSubview:self.largePlayButton];
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

- (void)loadVideoAsset
{
    [self resetTracking];
    self.state = VVideoStateNotStarted;
    
    self.videoAsset = [self.sequence.firstNode httpLiveStreamingAsset];
    self.trackingItem = self.sequence.tracking;
    
    VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:[NSURL URLWithString:self.videoAsset.data]];
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
    if ( self.focusType == VFocusTypeDetail )
    {
        self.largePlayButton.hidden = !((self.state == VVideoStateEnded || self.state == VVideoStateNotStarted) && ![self shouldLoop]);
    }
    else
    {
        self.largePlayButton.hidden = !(self.state == VVideoStateNotStarted && ![self shouldAutoplay]);
    }
    
    self.activityIndicator.hidden = self.state != VVideoStateBuffering;
    
    self.soundIndicator.hidden = !([self shouldAutoplay] && self.state == VVideoStatePlaying && self.focusType == VFocusTypeStream);
    if ( !self.soundIndicator.hidden )
    {
        [self.soundIndicator startAnimating];
    }
    
    self.videoPlayer.view.hidden = self.state == VVideoStateNotStarted;
    self.previewImageView.hidden = !self.videoPlayer.view.hidden;
    
    self.toolbar.paused = self.state != VVideoStatePlaying;
    
    [self setToolbarHidden:self.focusType != VFocusTypeDetail animated:self.focusType != VFocusTypeNone];
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    super.focusType = focusType;
    
    [self setToolbarHidden:self.focusType != VFocusTypeDetail animated:self.focusType != VFocusTypeNone];
    [self setGesturesEnabled:YES];
    
    if ( ![self shouldAutoplay] && focusType != VFocusTypeDetail)
    {
        [self.videoPlayer pauseAtStart];
        self.state = VVideoStateNotStarted;
    }
    else if (focusType == VFocusTypeDetail)
    {
        [self.videoPlayer play];
    }
    
    [self updateUIState];
}

- (void)onPreviewPlayButtonTapped:(UIButton *)button
{
    [self.videoPlayer playFromStart];
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
    return @{VTrackingKeyTimeCurrent : @(self.videoPlayer.currentTimeMilliseconds) };
}

- (void)updateQuartileTracking
{
    const float percent = (self.videoPlayer.currentTimeSeconds / self.videoPlayer.durationSeconds) * 100.0f;
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

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidBecomeReady:videoPlayer];
}

- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer
{
    if ( self.shouldLoop )
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.videoPlayer playFromStart];
                       });
    }
    else if ( !self.willShowEndCard )
    {
        [self.videoPlayer pause];
        self.state = VVideoStateEnded;
        [super videoPlayerDidReachEnd:videoPlayer];
    }
    else
    {
        [super videoPlayerDidReachEnd:videoPlayer];
    }
}

- (void)videoPlayerDidStartBuffering:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidStartBuffering:videoPlayer];
}

- (void)videoPlayerDidStopBuffering:(id<VVideoPlayer>)videoPlayer
{
    [super videoPlayerDidStopBuffering:videoPlayer];
}

- (void)videoPlayer:(VVideoView *__nonnull)videoPlayer didPlayToTime:(Float64)time
{
    [super videoPlayer:videoPlayer didPlayToTime:time];
    
    if ( self.toolbar != nil )
    {   
        [self.toolbar setCurrentTime:videoPlayer.currentTimeSeconds duration:videoPlayer.durationSeconds];
    }
    
    if ( self.focusType == VFocusTypeDetail )
    {
        [self updateQuartileTracking];
    }
}

- (void)videoPlayerDidPlay:(id<VVideoPlayer> __nonnull)videoPlayer
{
    [super videoPlayerDidPlay:videoPlayer];
    self.state = VVideoStatePlaying;
}

- (void)videoPlayerDidPause:(id<VVideoPlayer> __nonnull)videoPlayer
{
    [super videoPlayerDidPause:videoPlayer];
    self.state = VVideoStatePaused;
}

#pragma mark - VideoToolbarDelegate

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didStartScrubbingToLocation:(float)location
{
    self.wasPlayingBeforeScrubbingStarted = self.videoPlayer.isPlaying;
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didScrubToLocation:(float)location
{
    NSTimeInterval timeSeconds = location * self.videoPlayer.durationSeconds;
    [self.videoPlayer pause];
    [self.videoPlayer seekToTimeSeconds:timeSeconds];
}

- (void)videoToolbar:(VideoToolbarView *__nonnull)videoToolbar didEndScrubbingToLocation:(float)location
{
    if ( self.wasPlayingBeforeScrubbingStarted )
    {
        self.wasPlayingBeforeScrubbingStarted = NO;
        [self.videoPlayer play];
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