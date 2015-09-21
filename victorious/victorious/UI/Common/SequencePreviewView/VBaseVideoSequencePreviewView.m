//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseVideoSequencePreviewView.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VBackground.h"
#import "VImageAssetFinder.h"
#import "VImageAsset.h"

@interface VBaseVideoSequencePreviewView ()

@property (nonatomic, strong) UIView *backgroundContainerView;
@property (nonatomic, strong) VAsset *asset;

@end

@implementation VBaseVideoSequencePreviewView

#pragma mark - VVideoPlayerView

@synthesize videoPlayer = _videoPlayer;
@synthesize delegate;
@synthesize willShowEndCard;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
        
        _videoPlayer = [[VVideoView alloc] initWithFrame:self.bounds];
        _videoPlayer.delegate = self;
        [self addSubview:_videoPlayer.view];
        [self v_addFitToParentConstraintsToSubview:_videoPlayer.view];
        
        _videoSettings = [[VVideoSettings alloc] init];
        
        self.onlyShowPreview = YES;
    }
    return self;
}

- (BOOL)shouldAutoplay
{
    return self.videoAsset.streamAutoplay.boolValue && [self.videoSettings isAutoplayEnabled];
}

- (BOOL)shouldLoop
{
    switch (self.focusType)
    {
        case VFocusTypeDetail:
            return self.videoAsset.loop.boolValue;
        default:
            return YES;
    }
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    if ( self.sequence != nil && [self.sequence.remoteId isEqualToString:sequence.remoteId] )
    {
        return;
    }
    
    [super setSequence:sequence];
    
    if ( !self.onlyShowPreview )
    {
        [self loadVideoAsset];
    }
    
    [self setBackgroundContainerViewVisible:NO];
    
    VImageAssetFinder *imageFinder = [[VImageAssetFinder alloc] init];
    VImageAsset *imageAsset = [imageFinder largestAssetFromAssets:sequence.previewAssets];
    
    __weak VBaseVideoSequencePreviewView *weakSelf = self;
    
    void (^completionBlock)(void) = ^void(void)
    {
        __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
        if ( strongSelf == nil )
        {
            return;
        }
        
        strongSelf.readyForDisplay = YES;
    };
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:imageAsset.imageURL]
                           placeholderImage:nil
                        alongsideAnimations:^
     {
         __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
         [strongSelf setBackgroundContainerViewVisible:YES];
     }
                                 completion:^(UIImage *image)
     {
         if (image != nil)
         {
             completionBlock();
         }
         else
         {
             __strong VBaseVideoSequencePreviewView *strongSelf = weakSelf;
             // that URL failed, lets gracefully fall back
             UIScreen *mainScreen = [UIScreen mainScreen];
             CGFloat maxWidth = CGRectGetWidth(mainScreen.bounds) * mainScreen.scale;
             [strongSelf.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURLWithMaximumSize:CGSizeMake(maxWidth, CGFLOAT_MAX)]
                                    placeholderImage:nil
                                          completion:^(UIImage *image)
              {
                  completionBlock();
              }];
         }
     }];
}

- (void)loadVideoAsset
{
    self.videoAsset = [self.sequence.firstNode mp4Asset];
    VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:[NSURL URLWithString:self.videoAsset.data]];
    item.loop = YES;
    item.muted = YES;
    [self.videoPlayer setItem:item];
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    if (self.focusType)
    {
        [self setBackgroundContainerViewVisible:YES];
    }
}

- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer
{
    [self.delegate videoPlaybackDidFinish];
}

- (void)videoPlayerDidStartBuffering:(id<VVideoPlayer>)videoPlayer
{
}

- (void)videoPlayerDidStopBuffering:(id<VVideoPlayer>)videoPlayer
{
}

- (void)videoPlayer:(id<VVideoPlayer>)videoPlayer didPlayToTime:(Float64)time
{
}

- (void)videoPlayerDidPlay:(id<VVideoPlayer> __nonnull)videoPlayer
{
}

- (void)videoPlayerDidPause:(id<VVideoPlayer> __nonnull)videoPlayer
{
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    if ( super.focusType == focusType)
    {
        return;
    }
    
    super.focusType = focusType;
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            self.videoPlayer.view.backgroundColor = [UIColor clearColor];
            self.videoPlayer.useAspectFit = NO;
            [self.likeButton hide];
            [self.videoPlayer pause];
            self.videoPlayer.muted = YES;
            if ( self.onlyShowPreview )
            {
                [self.videoPlayer pauseAtStart];
            }
            self.userInteractionEnabled = NO;
            break;
            
        case VFocusTypeStream:
            [self setBackgroundContainerViewVisible:YES];
            self.videoPlayer.view.backgroundColor = [UIColor clearColor];
            self.videoPlayer.useAspectFit = NO;
            [self.likeButton hide];
            if ( self.shouldAutoplay && !self.onlyShowPreview )
            {
                [self.videoPlayer play];
                self.videoPlayer.muted = YES;
            }
            if ( self.onlyShowPreview )
            {
                [self.videoPlayer pauseAtStart];
            }
            self.userInteractionEnabled = NO;
            break;
            
        case VFocusTypeDetail:
            if ( self.onlyShowPreview )
            {
                [self loadVideoAsset];
            }
            [self setBackgroundContainerViewVisible:YES];
            self.videoPlayer.view.backgroundColor = [UIColor blackColor];
            self.videoPlayer.useAspectFit = YES;
            [self.likeButton show];
            [self.videoPlayer play];
            self.videoPlayer.muted = NO;
            self.userInteractionEnabled = YES;
            break;
    }
}

#pragma mark - VContentModeAdjustablePreviewView

- (void)updateToFitContent:(BOOL)fit withBackgroundSupplier:(VDependencyManager *)dependencyManager
{
    self.videoPlayer.useAspectFit = fit;
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleToFill;
    [dependencyManager addBackgroundToBackgroundHost:self];
}

- (UIView *)backgroundContainerView
{
    if ( _backgroundContainerView != nil )
    {
        return _backgroundContainerView;
    }
    
    _backgroundContainerView = [[UIView alloc] init];
    _backgroundContainerView.alpha = 0.0f;
    [self addSubview:_backgroundContainerView];
    [self sendSubviewToBack:_backgroundContainerView];
    [self v_addFitToParentConstraintsToSubview:_backgroundContainerView];
    return _backgroundContainerView;
}

- (void)setBackgroundContainerViewVisible:(BOOL)visible
{
    self.backgroundContainerView.alpha = visible ? 1.0f : 0.0f;
}

@end
