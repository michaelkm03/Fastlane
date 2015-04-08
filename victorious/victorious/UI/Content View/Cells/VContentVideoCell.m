//
//  VContentVideoCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentVideoCell.h"
#import "VConstants.h"
#import "VCVideoPlayerViewController.h"
#import "VAdVideoPlayerViewController.h"
#import "VEndCard.h"
#import "UIView+Autolayout.h"
#import "VDependencyManager.h"
#import "VTimerManager.h"

static const NSTimeInterval kAdTimeoutTimeInterval = 3.0;

@interface VContentVideoCell () <VCVideoPlayerDelegate, VAdVideoPlayerViewControllerDelegate>

@property (nonatomic, strong, readwrite) VAdVideoPlayerViewController *adVideoPlayerViewController;
@property (nonatomic, strong, readwrite) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, assign, readwrite) BOOL isPlayingAd;
@property (nonatomic, assign, readwrite) BOOL videoDidEnd;
@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, assign) BOOL updatedVideoBounds;

@property (nonatomic, assign) BOOL adDidStart;
@property (nonatomic, assign) BOOL videoDidStart;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, weak) IBOutlet UIButton *failureRetryButton;

@end

@implementation VContentVideoCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    const CGFloat minSide = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    return CGSizeMake(CGRectGetWidth(bounds), minSide);
}

#pragma mark - NSObject

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.videoPlayerViewController.view.hidden = YES;
    self.failureRetryButton.hidden = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.failureRetryButton.hidden = YES;
    self.failureRetryButton.enabled = NO;// If you remove this need to fix the retry logic
    self.failureRetryButton.titleLabel.numberOfLines = 0;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (!self.updatedVideoBounds)
    {
        /*
         Updating video player bounds after first time bounds is set
         Assumes cell will never be re-updated to a new "full" size but allows normal content
            resizing to work its magic
         */
        self.updatedVideoBounds = YES;
        self.videoPlayerViewController.view.frame = self.contentView.bounds;
        self.adVideoPlayerViewController.view.frame = self.contentView.bounds;
    }
}

- (void)dealloc
{
    [self.videoPlayerViewController disableTracking];
    self.videoPlayerViewController = nil;
    self.adVideoPlayerViewController = nil;
}

#pragma mark - Property Accessors

- (void)setViewModel:(VVideoCellViewModel *)viewModel
{
    _viewModel = viewModel;
    
    [self prepareUIForPlayback];
    
    self.contentURL = viewModel.itemURL;
    self.loop = viewModel.loop;
    
    [self startPlaybackForModel:viewModel];
}

- (void)setPlayerControlsDisabled:(BOOL)playerControlsDisabled
{
    _playerControlsDisabled = playerControlsDisabled;
    if ( _playerControlsDisabled )
    {
        self.videoPlayerViewController.shouldShowToolbar = NO;
        self.videoPlayerViewController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)setAudioDisabled:(BOOL)audioMuted
{
    _audioMuted = audioMuted;
    self.videoPlayerViewController.isAudioEnabled = !_audioMuted;
}

- (IBAction)retryVideo:(id)sender
{
    [self replay];
    [self setupVideoPlayer];
    self.failureRetryButton.hidden = YES;
    [self.loadingIndicator startAnimating];
}

#pragma mark - Playback Methods

- (void)prepareUIForPlayback
{
    [self.loadingIndicator startAnimating];
    [self setupVideoPlayer];
    self.videoPlayerViewController.view.hidden = YES;
}

- (void)startPlaybackForModel:(VVideoCellViewModel *)viewModel
{
    if (viewModel.monetizationPartner == VMonetizationPartnerNone)
    {
        self.isPlayingAd = NO;
        [self.videoPlayerViewController setItemURL:self.contentURL loop:self.loop];
    }
    else
    {
        self.isPlayingAd = YES;
        self.adVideoPlayerViewController = [self setupAdVideoPlayerViewController:viewModel.monetizationPartner details:viewModel.monetizationDetails];
        [self addAdVideoPlayerViewController:self.adVideoPlayerViewController];
    }
}

- (void)resumeContentPlayback
{
    self.isPlayingAd = NO;
    [self hideAdVideoPlayer];
    self.videoPlayerViewController.view.hidden = NO;
    self.videoPlayerViewController.view.alpha = 1.0f;
    [self.videoPlayerViewController setItemURL:self.contentURL loop:self.loop];
    
    [self play];
}

- (AVPlayerStatus)status
{
    return self.videoPlayerViewController.player.status;
}

- (CMTime)currentTime
{
    return self.videoPlayerViewController.currentTime;
}

#pragma mark - Video Player

- (void)setupVideoPlayer
{
    if (self.videoPlayerViewController != nil)
    {
        [self removeVideoPlayerViewController];
    }
    
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.view.frame = self.contentView.bounds;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    self.videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;
    if (self.tracking != nil)
    {
        [self.videoPlayerViewController enableTrackingWithTrackingItem:self.tracking];
    }
    
    [self addVideoPlayerViewController:self.videoPlayerViewController];
    
    self.videoPlayerViewController.view.hidden = YES;
    self.shrinkingContentView = self.videoPlayerViewController.view;
    
    if (self.contentURL)
    {
        [self.videoPlayerViewController setItemURL:self.contentURL loop:self.loop];
    }
    
    if (self.playerControlsDisabled)
    {
        self.videoPlayerViewController.shouldShowToolbar = NO;
        self.videoPlayerViewController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)addVideoPlayerViewController:(VCVideoPlayerViewController *)videoPlayerViewController
{
    [self.contentView addSubview:videoPlayerViewController.view];
    [self.contentView sendSubviewToBack:videoPlayerViewController.view];
}

- (void)removeVideoPlayerViewController
{
    [self.videoPlayerViewController.view removeFromSuperview];
    self.videoPlayerViewController = nil;
}

- (void)hideVideoPlayer
{
    self.videoPlayerViewController.view.hidden = YES;
    self.videoPlayerViewController.view.alpha = 0.0f;
}

- (void)showVideoPlayer
{
    self.videoPlayerViewController.view.hidden = NO;
    self.videoPlayerViewController.view.alpha = 1.0f;
}

#pragma mark - Ad Video Player

- (VAdVideoPlayerViewController *)setupAdVideoPlayerViewController:(VMonetizationPartner)monetizationPartner details:(NSArray *)details
{
    VAdVideoPlayerViewController *adVideoPlayerViewController = [[VAdVideoPlayerViewController alloc] initWithMonetizationPartner:monetizationPartner details:details];
    adVideoPlayerViewController.delegate = self;
    adVideoPlayerViewController.view.frame = self.contentView.bounds;
    return adVideoPlayerViewController;
}

- (void)addAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.contentView addSubview:adVideoPlayerViewController.view];
    [adVideoPlayerViewController start];

    // This timer is added as a workaround to kill the ad video if it has not started playing after kAdTimeoutTimeInterval seconds.
    [VTimerManager scheduledTimerManagerWithTimeInterval:kAdTimeoutTimeInterval target:self selector:@selector(adTimerFired) userInfo:nil repeats:NO];
}

- (void)removeAdVideoPlayerViewController
{
    [self.adVideoPlayerViewController.view removeFromSuperview];
    self.adVideoPlayerViewController = nil;
}

- (void)hideAdVideoPlayer
{
    self.adVideoPlayerViewController.view.hidden = YES;
    self.adVideoPlayerViewController.view.alpha = 0.0f;
}

- (void)showAdVideoPlayer
{
    self.adVideoPlayerViewController.view.hidden = NO;
    self.adVideoPlayerViewController.view.alpha = 1.0f;
}

#pragma mark - Public Methods

- (void)seekToStart
{
    [self.videoPlayerViewController.player seekToTime:kCMTimeZero];
}

- (void)replay
{
    self.videoDidEnd = NO;
    [self.videoPlayerViewController.player seekToTime:kCMTimeZero];
    [self.videoPlayerViewController.player play];
}

- (void)play
{
    if (!self.videoDidEnd)
    {
        self.videoPlayerViewController.player.rate = self.speed;
    }
}

- (void)pause
{
    [self.videoPlayerViewController.player pause];
}

- (void)togglePlayControls
{
    // This will not do anything if `videoPlayerViewController.shouldShowToolbar` is set to NO
    [self.videoPlayerViewController toggleToolbarHidden];
}

- (void)setAnimateAlongsizePlayControlsBlock:(void (^)(BOOL playControlsHidden))animateWithPlayControls
{
    self.videoPlayerViewController.animateWithPlayControls = animateWithPlayControls;
}

- (void)prepareForRemoval
{
    self.delegate = nil;
    self.adVideoPlayerViewController = nil;
}

#pragma mark - Private Methods

- (void)adTimerFired
{
    if (!self.adDidStart)
    {
        [self removeAdVideoPlayerViewController];
        [self resumeContentPlayback];
    }
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    if (CMTIME_COMPARE_INLINE(time, !=, kCMTimeZero))
    {
        self.videoDidStart = YES;
        [self.loadingIndicator stopAnimating];
        [self.delegate videoCell:self
                   didPlayToTime:time
                       totalTime:[videoPlayer playerItemDuration]];
    }
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    self.videoPlayerViewController.view.hidden = NO;
    [self.delegate videoCellReadyToPlay:self];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    // This should only be forwarded from the content video player
    [self.delegate videoCellPlayedToEnd:self withTotalTime:[videoPlayer playerItemDuration]];
    self.videoDidEnd = YES;
    
    if (self.viewModel.endCardViewModel != nil)
    {
        [super showEndCardWithViewModel:self.viewModel.endCardViewModel];
    }
}

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self.delegate videoCellWillStartPlaying:self];
}

- (void)videoPlayerFailed:(VCVideoPlayerViewController *)videoPlayer
{
    self.failureRetryButton.hidden = NO;
    [self removeVideoPlayerViewController];
    [self removeAdVideoPlayerViewController];
    [self.loadingIndicator stopAnimating];
    [self.failureRetryButton setTitle:NSLocalizedString(@"Video loading failed.", @"") forState:UIControlStateNormal];
}

#pragma mark - VAdVideoPlayerViewControllerDelegate

- (void)adHadErrorForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self resumeContentPlayback];
}

- (void)adDidLoadForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    // This is where we can preload the content video after the ad video has loaded
}

- (void)adDidStartPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.loadingIndicator stopAnimating];
    self.adDidStart = YES;
}

- (void)adDidStopPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self.loadingIndicator startAnimating];
}

- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self resumeContentPlayback];
}

@end
