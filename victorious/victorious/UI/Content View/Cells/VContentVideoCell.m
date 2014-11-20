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

@interface VContentVideoCell () <VCVideoPlayerDelegate, VAdVideoPlayerViewControllerDelegate>

@property (nonatomic, strong, readwrite) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong, readwrite) VAdVideoPlayerViewController *adPlayerViewController;
@property (nonatomic, assign, readwrite) BOOL isPlayingAd;
@property (nonatomic, strong) NSURL *contentURL;

@end

@implementation VContentVideoCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil
                                                                                   bundle:nil];
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.view.frame = self.contentView.bounds;
    self.videoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayerViewController.shouldContinuePlayingAfterDismissal = YES;
    self.videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;
    [self.contentView addSubview:self.videoPlayerViewController.view];
}

- (void)dealloc
{
    [self.videoPlayerViewController disableTracking];
}

#pragma mark - Property Accessors

- (void)setViewModel:(VVideoCellViewModel *)viewModel
{
    _viewModel = viewModel;
    
    self.contentURL = viewModel.itemURL;
    
    if ( viewModel.monetizationPartner == VMonetizationPartnerNone )
    {
        self.isPlayingAd = NO;
        self.videoPlayerViewController.itemURL = self.contentURL;
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
    [self.adPlayerViewController start];
    [self.contentView addSubview:self.adPlayerViewController.view];
}

- (void)resumeContentPlayback
{
    // Set visibility
    self.isPlayingAd = NO;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.adPlayerViewController.view.hidden = YES;
        self.adPlayerViewController.view.alpha = 0.0f;
        self.videoPlayerViewController.view.hidden = NO;
        self.videoPlayerViewController.view.alpha = 1.0f;
    });
    self.videoPlayerViewController.itemURL = self.contentURL;
    
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
    return self.videoPlayerViewController.player.currentTime;
}

#pragma mark - Public Methods

- (void)play
{
    self.videoPlayerViewController.shouldLoop = self.loop;
    self.videoPlayerViewController.player.rate = self.speed;
}

- (void)pause
{
    [self.videoPlayerViewController.player pause];
}

- (void)togglePlayControls
{
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
    [self.delegate videoCell:self
               didPlayToTime:time
                   totalTime:[videoPlayer playerItemDuration]];
}

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [self.delegate videoCellReadyToPlay:self];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    // This should only be forwarded from the content video player
    [self.delegate videoCellPlayedToEnd:self
                          withTotalTime:[videoPlayer playerItemDuration]];
}

- (void)videoPlayerWillStartPlaying:(VCVideoPlayerViewController *)videoPlayer
{
    [self.delegate videoCellWillStartPlaying:self];
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
    
}

- (void)adDidStopPlaybackForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    NSLog(@"\n\nAdVideo was stopped");
}

- (void)adDidFinishForAdVideoPlayerViewController:(VAdVideoPlayerViewController *)adVideoPlayerViewController
{
    [self resumeContentPlayback];
}

@end
