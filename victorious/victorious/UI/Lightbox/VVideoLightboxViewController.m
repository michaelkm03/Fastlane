//
//  VVideoLightboxViewController.m
//  victorious
//
//  Created by Josh Hinman on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSLayoutConstraint+CenterConstraints.h"
#import "VActivityIndicatorView.h"
#import "VCVideoPlayerViewController.h"
#import "VThemeManager.h"
#import "VVideoLightboxViewController.h"

@interface VVideoLightboxViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayer;
@property (nonatomic, strong) UIImageView                 *previewImageView;
@property (nonatomic, weak)   VActivityIndicatorView      *activityIndicator;
@property (nonatomic)         BOOL                         videoLoaded;
@property (nonatomic, strong) NSArray                     *previewImageConstraints;

@end

@implementation VVideoLightboxViewController

- (instancetype)initWithPreviewImage:(UIImage *)previewImage videoURL:(NSURL *)videoURL
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.previewImage = previewImage;
        self.videoURL = videoURL;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    self.previewImageView = [[UIImageView alloc] initWithImage:self.previewImage];
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewImageView.clipsToBounds = YES;
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentSuperview addSubview:self.previewImageView];
    self.previewImageConstraints = [NSLayoutConstraint v_constraintsToScaleAndCenterView:self.previewImageView
                                                                              withinView:self.contentSuperview
                                                                         withAspectRatio:(self.previewImage.size.width / self.previewImage.size.height)];
    [self.contentSuperview addConstraints:self.previewImageConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.videoPlayer && self.videoURL)
    {
        self.videoPlayer = [[VCVideoPlayerViewController alloc] init];
        self.videoPlayer.delegate = self;
        self.videoPlayer.itemURL = self.videoURL;
        
        [self addChildViewController:self.videoPlayer];
        [self.contentSuperview addSubview:self.videoPlayer.view];
        [self.videoPlayer didMoveToParentViewController:self];

        [self addCloseButtonToVideoPlayer];
        
        self.videoPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.videoPlayer.view.alpha = 0;
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.previewImageView
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.previewImageView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.previewImageView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer.view
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.previewImageView
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        
        VActivityIndicatorView *activityIndicator = [[VActivityIndicatorView alloc] init];
        activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentSuperview addSubview:activityIndicator];
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentSuperview
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        [self.contentSuperview addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentSuperview
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0f
                                                                           constant:0.0f]];
        [activityIndicator startAnimating];
        self.activityIndicator = activityIndicator;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.activityIndicator)
    {
        [self.activityIndicator removeFromSuperview];
    }
    
    if (self.videoPlayer && !self.videoLoaded)
    {
        [self.videoPlayer willMoveToParentViewController:nil];
        [self.videoPlayer.view removeFromSuperview];
        [self.videoPlayer removeFromParentViewController];
        self.videoPlayer.delegate = nil;
        self.videoPlayer = nil;
    }
}

#pragma mark - Properties

- (UIView *)contentView
{
    if (self.videoLoaded)
    {
        return self.videoPlayer.view;
    }
    else
    {
        return self.previewImageView;
    }
}

- (void)setPreviewImage:(UIImage *)previewImage
{
    _previewImage = previewImage;
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
}

#pragma mark -

- (void)addCloseButtonToVideoPlayer
{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    [closeButton setImage:[[UIImage imageNamed:@"Close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(pressedClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    [self.videoPlayer.overlayView addSubview:closeButton];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[closeButton(==50)]"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(closeButton)]];
    [self.videoPlayer.overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[closeButton(==50)]"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:NSDictionaryOfVariableBindings(closeButton)]];
}

- (void)pressedClose:(UIButton *)sender
{
    if (self.onCloseButtonTapped)
    {
        self.onCloseButtonTapped();
    }
}

#pragma mark - VCVideoPlayerDelegate methods

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [self.activityIndicator removeFromSuperview];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void)
    {
        [self.contentSuperview removeConstraints:self.previewImageConstraints];
        [self.contentSuperview addConstraints:[NSLayoutConstraint v_constraintsToScaleAndCenterView:self.previewImageView withinView:self.contentSuperview withAspectRatio:(self.videoPlayer.naturalSize.width / self.videoPlayer.naturalSize.height)]];
        [self.contentSuperview layoutIfNeeded];
        self.previewImageView.alpha = 0.0f;
        self.videoPlayer.view.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
        [self.videoPlayer.player play];
        self.videoLoaded = YES;
    }];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    if (self.onVideoFinished)
    {
        self.onVideoFinished();
    }
}

@end
