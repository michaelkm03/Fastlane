//
//  VVideoLinkViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoLinkViewController.h"
#import "VCVideoPlayerViewController.h"
#import "UIView+AutoLayout.h"

@interface VVideoLinkViewController () <VCVideoPlayerDelegate>

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayer;
@property (nonatomic, assign) BOOL videoLoaded;
@property (nonatomic, copy) MediaLoadingCompletionBlock loadingCompletionBlock;

@end

@implementation VVideoLinkViewController

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super initWithUrlString:urlString];
    if ( self != nil )
    {
        _videoPlayer = [[VCVideoPlayerViewController alloc] init];
        _videoPlayer.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *videoPlayerView = self.videoPlayer.view;
    [self addChildViewController:self.videoPlayer];
    [self.contentContainerView addSubview:videoPlayerView];
    [self.videoPlayer didMoveToParentViewController:self];
    
    videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    videoPlayerView.alpha = 0;
    [self.contentContainerView v_addFitToParentConstraintsToSubview:videoPlayerView];
}

- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock
{
    self.loadingCompletionBlock = completionBlock;
    [self reloadVideoPlayer];
}

- (void)reloadVideoPlayer
{
    self.videoPlayer.shouldShowToolbar = !self.hidePlayControls;
    self.videoPlayer.audioMuted = self.muteAudio;
    [self.videoPlayer setItemURL:[NSURL URLWithString:self.mediaUrlString] loop:self.loop];
}

#pragma mark - Setters

- (void)setHidePlayControls:(BOOL)hidePlayControls
{
    _hidePlayControls = hidePlayControls;
    self.videoPlayer.shouldShowToolbar = !hidePlayControls;
}

- (void)setLoop:(BOOL)loop
{
    _loop = loop;
    if ( self.videoPlayer.isLooping != loop && self.mediaUrlString != nil )
    {
        [self reloadVideoPlayer];
    }
}

- (void)setMuteAudio:(BOOL)muteAudio
{
    _muteAudio = muteAudio;
    self.videoPlayer.audioMuted = muteAudio;
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
    
    self.loadingCompletionBlock ( aspectRatio );
}

@end
