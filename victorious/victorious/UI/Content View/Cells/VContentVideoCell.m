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

#import "VRootViewController.h"
#import "VDependencyManager.h"

@interface VContentVideoCell () <VCVideoPlayerDelegate, VAdVideoPlayerViewControllerDelegate>

@property (nonatomic, strong, readwrite) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, assign, readwrite) BOOL isPlayingAd;
@property (nonatomic, assign, readwrite) BOOL videoDidEnd;
@property (nonatomic, strong) NSURL *contentURL;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, weak) IBOutlet UIButton *failureRetryButton;

@end

@implementation VContentVideoCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    const CGFloat minSide = MIN( CGRectGetWidth(bounds), CGRectGetHeight(bounds) );
    return CGSizeMake( CGRectGetWidth(bounds), minSide );
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
    
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.view.frame = self.contentView.bounds;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    self.videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;
    [self.contentView addSubview:self.videoPlayerViewController.view];
    [self.contentView sendSubviewToBack:self.videoPlayerViewController.view];
    self.videoPlayerViewController.view.hidden = YES;
    self.shrinkingContentView = self.videoPlayerViewController.view;
    self.failureRetryButton.hidden = YES;
    self.failureRetryButton.titleLabel.numberOfLines = 0;
}

- (void)dealloc
{
    [self.videoPlayerViewController disableTracking];
    self.videoPlayerViewController = nil;
    self.adPlayerViewController = nil;
}

#pragma mark - Property Accessors

- (void)setViewModel:(VVideoCellViewModel *)viewModel
{
    _viewModel = viewModel;
    
    [self.loadingIndicator startAnimating];
    
    self.videoPlayerViewController.view.hidden = YES;
    
    self.contentURL = viewModel.itemURL;
    self.loop = viewModel.loop;
   
    if ( viewModel.monetizationPartner == VMonetizationPartnerNone )
    {
        self.isPlayingAd = NO;
        [self.videoPlayerViewController setItemURL:self.contentURL loop:self.loop];
        return;
    }
    
    [self showPreRollWithPartner:viewModel.monetizationPartner withDetails:viewModel.monetizationDetails];
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:1.0f];
}

#pragma mark - Playback Methods

- (void)showPreRollWithPartner:(VMonetizationPartner)monetizationPartner withDetails:(NSArray *)details
{
    // Set visibility
    self.isPlayingAd = YES;
    
    self.videoPlayerViewController.view.hidden = YES;
    
    // Ad Video Player
    self.adPlayerViewController = [[VAdVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
    [self.adPlayerViewController assignMonetizationPartner:monetizationPartner withDetails:details];
    self.adPlayerViewController.delegate = self;
    self.adPlayerViewController.view.hidden = NO;
    [self.contentView addSubview:self.adPlayerViewController.view];
    [self.contentView sendSubviewToBack:self.adPlayerViewController.view];
    [self.adPlayerViewController start];
}

- (void)resumeContentPlayback
{
    // Set visibility
    self.isPlayingAd = NO;
    self.adPlayerViewController.view.hidden = YES;
    self.adPlayerViewController.view.alpha = 0.0f;
    self.videoPlayerViewController.view.hidden = NO;
    self.videoPlayerViewController.view.alpha = 1.0f;
    [self.videoPlayerViewController setItemURL:self.contentURL loop:self.loop];
    
    // Play content Video
    [self play];
}

- (AVPlayerStatus)status
{
    return self.videoPlayerViewController.player.status;
}

- (UIView *)videoPlayerContainer
{
    return self.videoPlayerViewController.view;
}

- (CMTime)currentTime
{
    return self.videoPlayerViewController.currentTime;
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
    self.failureRetryButton.hidden = YES;
    [self.loadingIndicator startAnimating];
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
    if ( !self.videoDidEnd )
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

- (void)setTracking:(VTracking *)tracking
{
    [self.videoPlayerViewController enableTrackingWithTrackingItem:tracking];
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer
      didPlayToTime:(CMTime)time
{
    if (CMTIME_COMPARE_INLINE(time, ==, kCMTimeZero))
    {
        return;
    }
    [self.loadingIndicator stopAnimating];
    [self.delegate videoCell:self
               didPlayToTime:time
                   totalTime:[videoPlayer playerItemDuration]];
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    self.videoPlayerViewController.view.hidden = NO;
    [self.delegate videoCellReadyToPlay:self];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    // This should only be forwarded from the content video player
    [self.delegate videoCellPlayedToEnd:self
                          withTotalTime:[videoPlayer playerItemDuration]];
    self.videoDidEnd = YES;
    
    if ( self.viewModel.endCardViewModel != nil )
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
    [self.loadingIndicator stopAnimating];
    [self.failureRetryButton setTitle:NSLocalizedString(@"Video loading failed. Retry?", @"") forState:UIControlStateNormal];
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
