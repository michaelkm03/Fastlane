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

@property (nonatomic) BOOL isRotating;
@property (nonatomic) BOOL wantsDismissal;

@end

@implementation VVideoLightboxViewController

- (instancetype)initWithPreviewImage:(UIImage *_Nullable)previewImage videoURL:(NSURL *)videoURL
{
    self = [super init];
    if ( self != nil )
    {
        self.previewImage = previewImage;
        self.videoURL = videoURL;
        self.shouldFireAnalytics = YES;
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
    self.previewImageView.backgroundColor = [UIColor blackColor];
    [self.contentSuperview addSubview:self.previewImageView];
    
    CGFloat previewImageAspectRatio;
    CGSize previewImageSize = self.previewImage.size;
    if (previewImageSize.height)
    {
        previewImageAspectRatio = previewImageSize.width / previewImageSize.height;
    }
    else
    {
        previewImageAspectRatio = 1;
    }
    self.previewImageConstraints = [NSLayoutConstraint v_constraintsToScaleAndCenterView:self.previewImageView
                                                                              withinView:self.contentSuperview
                                                                         withAspectRatio:previewImageAspectRatio];
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
        self.videoPlayer.shouldFireAnalytics = self.shouldFireAnalytics;
        self.videoPlayer.titleForAnalytics = self.titleForAnalytics;
        
        [self addChildViewController:self.videoPlayer];
        [self.contentSuperview addSubview:self.videoPlayer.view];
        [self.videoPlayer didMoveToParentViewController:self];

        [self addCloseButtonToVideoPlayer];
        
        self.videoPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.videoPlayer.view.alpha = 0;
        [self.contentSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[videoPlayerView]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:@{@"videoPlayerView":self.videoPlayer.view}]];
        [self.contentSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayerView]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:@{@"videoPlayerView":self.videoPlayer.view}]];
        
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak typeof(self) welf = self;
    self.isRotating = YES;
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         __strong typeof(self) strongSelf = welf;
         strongSelf.isRotating = NO;
         if (strongSelf.wantsDismissal && strongSelf.onCloseButtonTapped)
         {
             strongSelf.onCloseButtonTapped();
         }
     }];
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

- (void)setTitleForAnalytics:(NSString *)titleForAnalytics
{
    _titleForAnalytics = [titleForAnalytics copy];
    if (self.videoPlayer)
    {
        self.videoPlayer.titleForAnalytics = titleForAnalytics;
    }
}

- (void)setShouldFireAnalytics:(BOOL)shouldFireAnalytics
{
    _shouldFireAnalytics = shouldFireAnalytics;
    if (self.videoPlayer)
    {
        self.videoPlayer.shouldFireAnalytics = shouldFireAnalytics;
    }
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
    [self.videoPlayer.player prerollAtRate:1.0f
                         completionHandler:^(BOOL finished)
    {
        [self.videoPlayer.player play];
    }];
}

- (void)videoPlayer:(VCVideoPlayerViewController *)videoPlayer didPlayToTime:(CMTime)time
{
    CMTime timeThreshold = CMTimeMake(1, 20);
    
    if (CMTIME_COMPARE_INLINE(time, <, timeThreshold))
    {
        return;
    }
    
    [self.activityIndicator removeFromSuperview];
    
    if (self.videoLoaded)
    {
        return;
    }
    
    self.videoLoaded = YES;
    
    CGSize videoSize = self.videoPlayer.naturalSize;
    CGFloat aspectRatio = 1.0f;
    if (videoSize.height != 0.0f)
    {
        aspectRatio = videoSize.width / videoSize.height;
    }
    
    self.videoPlayer.view.alpha = 1.0f;
    self.previewImageView.alpha = 0.0f;
    [self.contentSuperview removeConstraints:self.previewImageConstraints];
    [self.contentSuperview addConstraints:[NSLayoutConstraint v_constraintsToScaleAndCenterView:self.previewImageView withinView:self.contentSuperview withAspectRatio:aspectRatio]];
    [self.contentSuperview layoutIfNeeded];
}

- (void)videoPlayerDidReachEndOfVideo:(VCVideoPlayerViewController *)videoPlayer
{
    if (self.isRotating)
    {
        self.wantsDismissal = YES;
        return;
    }
    
    if (self.onVideoFinished)
    {
        self.onVideoFinished();
    }
}

@end
