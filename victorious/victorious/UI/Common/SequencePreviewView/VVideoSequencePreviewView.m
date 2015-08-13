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
            [self loadAssetURL:[NSURL URLWithString:self.HLSAsset.data] andLoop:NO];
        }
    }
}

- (void)loadAssetURL:(NSURL *)url andLoop:(BOOL)loop
{
    self.assetURL = url;
    
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
        default:
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
    }
    else
    {
        [self setState:VVideoPreviewViewStatePlaying];
    }
    [self.videoView play];
}

- (void)pauseVideo
{
    [self setState:VVideoPreviewViewStateEnded];
    [self.videoView pause];
}

#pragma mark - Video Player Delegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *__nonnull)videoView
{
    [super videoViewPlayerDidBecomeReady:videoView];
    if (self.inFocus)
    {
        [self playVideo];
    }
}

- (void)videoDidReachEnd:(VVideoView *__nonnull)videoView
{
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
    if (self.inFocus)
    {
        [self setState:VVideoPreviewViewStateBuffering];
    }
}

- (void)videoViewDidStopBuffering:(VVideoView *__nonnull)videoView
{
    if (self.inFocus)
    {
        [self setState:VVideoPreviewViewStatePlaying];
    }
}

@end
