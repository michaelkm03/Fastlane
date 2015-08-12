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
    VVideoPreviewViewStateEnded
};

@interface VVideoSequencePreviewView ()

@property (nonatomic, assign) VVideoPreviewViewState state;
@property (nonatomic, assign) BOOL shouldLoop;
@property (nonatomic, assign) BOOL hasPlayed;
@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, strong) VVideoSettings *videoSettings;

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
    
    VAsset *HLSAsset = [sequence.firstNode httpLiveStreamingAsset];
    
    // Check HLS asset to see if we should autoplay and only if it's over 30 seconds
    if ( !HLSAsset.streamAutoplay.boolValue )
    {
        // Check if autoplay is enabled before loading asset URL
        if ([self.videoSettings isAutoplayEnabled])
        {
            [self loadAssetURL:[NSURL URLWithString:HLSAsset.data] andLoop:NO];
        }
    }
}

- (void)loadAssetURL:(NSURL *)url andLoop:(BOOL)loop
{
    self.shouldLoop = loop;
    self.hasPlayed = NO;
    
    self.assetURL = url;
    
    [self setState:VVideoPreviewViewStateBuffering];
    
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
    if (![self playVideo])
    {
        [self.videoView pause];
    }
}

- (BOOL)playVideo
{
    if (self.inFocus && !self.hasPlayed && self.assetURL != nil)
    {
        [self.videoView play];
        return YES;
    }
    
    return NO;
}

#pragma mark - Video Player Delegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *__nonnull)videoView
{
    [super videoViewPlayerDidBecomeReady:videoView];
    [self playVideo];
}

- (void)videoDidReachEnd:(VVideoView *__nonnull)videoView
{
    self.hasPlayed = YES;
    [self.videoView play];
    [self setState:VVideoPreviewViewStateEnded];
}

- (void)videoViewDidStartBuffering:(VVideoView *__nonnull)videoView
{
    if (self.state != VVideoPreviewViewStateEnded)
    {
        [self setState:VVideoPreviewViewStateBuffering];
    }
}

- (void)videoViewDidStopBuffering:(VVideoView *__nonnull)videoView
{
    if (self.state != VVideoPreviewViewStateEnded)
    {
        [self setState:VVideoPreviewViewStatePlaying];
    }
}

@end
