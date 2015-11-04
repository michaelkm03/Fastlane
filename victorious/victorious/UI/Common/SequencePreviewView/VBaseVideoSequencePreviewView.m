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
@property (nonatomic, assign, readwrite) BOOL shouldAutoplay;

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

- (UIColor *)streamBackgroundColor
{
    return [UIColor colorWithWhite:0.95f alpha:1.0f]; // Visible when letterboxed
}

- (void)updateBackgroundColorAnimated:(BOOL)animated
{
    UIColor *backgroundColor = self.updatedBackgroundColor;
    void (^fadeAnimations)() = ^
    {
        [self.videoPlayer updateToBackgroundColor:backgroundColor];
        self.backgroundColor = backgroundColor;
    };
    if ( animated )
    {
        [UIView animateWithDuration:0.25f animations:fadeAnimations];
    }
    else
    {
        fadeAnimations();
    }
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

- (void)updateStateOfVideoPlayerView
{
    self.videoPlayer.view.hidden = ![self shouldAutoplay];
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    self.shouldAutoplay = sequence.firstNode.mp4Asset.streamAutoplay.boolValue && [self.videoSettings isAutoplayEnabled];
    self.videoPlayer.view.hidden = !self.shouldAutoplay;
    
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
            [strongSelf determinePreferredBackgroundColorWithImage:image];
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

- (void)determinePreferredBackgroundColorWithImage:(UIImage *)image
{
    CGFloat imageAspect = image == nil ? 0 : image.size.width / image.size.height;
    [self determinePreferredBackgroundColorWithContentAspectRatio:imageAspect lockBackgroundColor:NO];
}

- (void)determinePreferredBackgroundColorWithContentAspectRatio:(CGFloat)aspectRatio lockBackgroundColor:(BOOL)lockBackgroundColor
{
    if ( CGRectEqualToRect(self.bounds, CGRectZero) )
    {
        return;
    }
    
    if ( !self.hasDeterminedPreferredBackgroundColor )
    {
        CGFloat containerAspect = CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds);
        
        //If we'll show ANY empty space around the content, use our preferred background color
        self.usePreferredBackgroundColor = aspectRatio != containerAspect;
        [self updateBackgroundColorAnimated:NO];
        if ( lockBackgroundColor )
        {
            //We've determined the background color based on the aspect ratio of the video,
            //we don't need to update it anymore.
            self.hasDeterminedPreferredBackgroundColor = YES;
        }
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

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if ( self.hasDeterminedPreferredBackgroundColor )
    {
        //We've determined our preferred background color based on a bounds that no longer represents the bounds of the container. Update it.
        self.hasDeterminedPreferredBackgroundColor = NO;
        [self determinePreferredBackgroundColorWithContentAspectRatio:self.videoPlayer.aspectRatio lockBackgroundColor:YES];
    }
}

#pragma mark - VVideoPlayerDelegate

- (void)videoPlayerDidBecomeReady:(id<VVideoPlayer>)videoPlayer
{
    [self determinePreferredBackgroundColorWithContentAspectRatio:[self.videoPlayer aspectRatio] lockBackgroundColor:YES];
    if ( self.focusType == VFocusTypeDetail )
    {
        [self.videoPlayer playFromStart];
    }
}

- (void)videoPlayerDidReachEnd:(id<VVideoPlayer>)videoPlayer
{
    if ( [self shouldLoop] )
    {
        [videoPlayer playFromStart];
    }
    else
    {
        [videoPlayer pause];
        [self.delegate videoPlaybackDidFinish];
    }
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
    
    VFocusType previousFocusType = self.focusType;
    
    super.focusType = focusType;
    [self updateBackgroundColorAnimated:YES];

    switch (focusType)
    {
        case VFocusTypeNone:
            self.videoPlayer.muted = YES;
            self.userInteractionEnabled = NO;
            if ( previousFocusType == VFocusTypeDetail )
            {
                [[VAudioManager sharedInstance] focusedPlaybackDidEnd];
            }
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
            else
            {
                [self.videoPlayer pause];
            }
            break;
            
        case VFocusTypeStream:
            self.videoPlayer.muted = YES;
            self.userInteractionEnabled = NO;
            if ( previousFocusType == VFocusTypeDetail )
            {
                [[VAudioManager sharedInstance] focusedPlaybackDidEnd];
            }
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
            self.videoPlayer.muted = self.videoAsset.audioMuted.boolValue;
            self.userInteractionEnabled = YES;  //< Activate video UI
            [[VAudioManager sharedInstance] focusedPlaybackDidBeginWithMuted:self.videoPlayer.muted];
            if ( self.onlyShowPreview )
            {
                // If we were previously only showing the preview,
                // now we need to load the video asset for detail focus (content view)
                [self loadVideoAsset];
            }
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
    self.previewImageView.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
}

@end
