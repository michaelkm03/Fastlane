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
#import "victorious-Swift.h"
#import "UIImageView+WebCache.h"

@interface VBaseVideoSequencePreviewView ()

@property (nonatomic, strong) VAsset *asset;
@property (nonatomic, strong, readwrite) UIView *videoContainer;

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
        _previewImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
        
        _videoContainer = [[UIView alloc] initWithFrame:self.bounds];
        _videoContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:_videoContainer];
        [self v_addFitToParentConstraintsToSubview:_videoContainer];
        
        _videoPlayer = [self createVideoPlayerWithFrame:frame];
        _videoPlayer.view.frame = self.bounds;
        _videoPlayer.delegate = self;
        _videoPlayer.view.backgroundColor = [UIColor clearColor];
        
        [self addVideoPlayerView:_videoPlayer.view];
        
        _videoSettings = [[VVideoSettings alloc] init];
    }
    return self;
}

- (void)addVideoPlayerView:(UIView *)view
{
    [self.videoContainer addSubview:view];
    [self.videoContainer v_addFitToParentConstraintsToSubview:view];
}

- (id<VVideoPlayer>)createVideoPlayerWithFrame:(CGRect)frame
{
    return [[VVideoView alloc] initWithFrame:self.bounds];
}

- (void)updateVideoPlayerView
{
    if ( [_videoPlayer.view.superview isEqual:self] )
    {
        [self addSubview:_videoPlayer.view];
        [self v_addFitToParentConstraintsToSubview:_videoPlayer.view];
    }
}

- (BOOL)shouldAutoplay
{
    return self.videoAsset.streamAutoplay.boolValue && [self.videoSettings isAutoplayEnabled];
}

- (BOOL)shouldLoop
{
    switch (self.focusType)
    {
        case VFocusTypeStream:
        case VFocusTypeNone:
            return YES;
        case VFocusTypeDetail:
            return self.videoAsset.loop.boolValue;
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
    
    if ( self.onlyShowPreview )
    {
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else
    {
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self loadVideoAsset];
    }
    
    VImageAssetFinder *imageFinder = [[VImageAssetFinder alloc] init];
    VImageAsset *imageAsset = [imageFinder largestAssetFromAssets:sequence.previewImageAssets];
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(UIImage *, NSError *, SDImageCacheType, NSURL *) = ^void(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        __strong typeof(self) strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            [strongSelf determinedPreferredBackgroundColorWithImage:image];
            strongSelf.readyForDisplay = YES;
        }
    };
    
    [self.previewImageView sd_setImageWithURL:[NSURL URLWithString:imageAsset.imageURL]
                             placeholderImage:nil
                                      options:SDWebImageRetryFailed
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image != nil)
         {
             completionBlock( image, error, cacheType, imageURL );
         }
         else
         {
             // that URL failed, lets gracefully fall back
             UIScreen *mainScreen = [UIScreen mainScreen];
             CGFloat maxWidth = CGRectGetWidth(mainScreen.bounds) * mainScreen.scale;
             [weakSelf.previewImageView fadeInImageAtURL:[sequence inStreamPreviewImageURLWithMaximumSize:CGSizeMake(maxWidth, CGFLOAT_MAX)]
                                    placeholderImage:nil
                                          completion:^(UIImage *image)
              {
                  completionBlock( image, error, cacheType, imageURL );
              }];
         }
     }];
}

- (void)determinedPreferredBackgroundColorWithImage:(UIImage *)image
{
    if ( !self.hasDeterminedPreferredBackgroundColor )
    {
        CGFloat imageAspect = image.size.width / image.size.height;
        CGFloat containerAspect = CGRectGetWidth(self.previewImageView.frame) / CGRectGetHeight(self.previewImageView.frame);
        self.usePreferredBackgroundColor = ABS(imageAspect - containerAspect) > 0.1;
        [self updateBackgroundColorAnimated:NO];
        self.hasDeterminedPreferredBackgroundColor = YES;
    }
}

- (void)loadVideoAsset
{
    self.videoAsset = [self.sequence.firstNode mp4Asset];
    VVideoPlayerItem *item = [[VVideoPlayerItem alloc] initWithURL:[NSURL URLWithString:self.videoAsset.data]];
    item.useAspectFit = YES;
    item.loop = YES;
    item.muted = YES;
    [self.videoPlayer setItem:item];
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    if ( self.focusType == VFocusTypeDetail )
    {
        [self.videoPlayer playFromStart];
    }
}

- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer
{
    [videoPlayer pause];
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
    
    [self updateBackgroundColorAnimated:YES];
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            self.videoPlayer.muted = YES;
            self.userInteractionEnabled = NO;
            [[VAudioManager sharedInstance] focusedPlaybackDidEnd];
            [self.likeButton hide];
            [self.videoPlayer pause];
            if ( self.onlyShowPreview )
            {
                if ( self.shouldAutoplay )
                {
                    [self.videoPlayer pause];
                }
                else
                {
                    [self.videoPlayer pauseAtStart];
                }
            }
            break;
            
        case VFocusTypeStream:
            self.videoPlayer.muted = YES;
            self.userInteractionEnabled = NO;
            [[VAudioManager sharedInstance] focusedPlaybackDidEnd];
            [self.likeButton hide];
            if ( self.shouldAutoplay && !self.onlyShowPreview )
            {
                [self.videoPlayer play];
            }
            if ( !self.onlyShowPreview )
            {
                if ( self.shouldAutoplay )
                {
                    [self.videoPlayer play];
                }
                else
                {
                    [self.videoPlayer pause];
                }
            }
            break;
            
        case VFocusTypeDetail:
            [self.likeButton show];
            self.videoPlayer.muted = self.videoAsset.audioMuted.boolValue;
            self.userInteractionEnabled = YES;  //< Activate video UI
            [[VAudioManager sharedInstance] focusedPlaybackDidBeginWithMuted:self.videoPlayer.muted];
            if ( self.onlyShowPreview )
            {
                // If we were previously only showing the preview,
                // now we need to load the video asset for detail focus (content view)
                [self loadVideoAsset];
            }
            [self.likeButton show];
            [self.videoPlayer play];
            self.userInteractionEnabled = YES;
            if ( !self.shouldAutoplay )
            {
                [self.videoPlayer playFromStart];
            }
            break;
    }
}

#pragma mark - VContentFittingPreviewView

- (void)updateToFitContent:(BOOL)fit
{
    self.videoPlayer.useAspectFit = fit;
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleToFill;
}

@end
