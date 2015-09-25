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
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.clipsToBounds = YES;
        _previewImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
        
        _videoPlayer = [[VVideoView alloc] initWithFrame:self.bounds];
        _videoPlayer.delegate = self;
        [self addSubview:_videoPlayer.view];
        [self v_addFitToParentConstraintsToSubview:_videoPlayer.view];
        _videoPlayer.view.backgroundColor = [UIColor clearColor];
        
        _videoSettings = [[VVideoSettings alloc] init];
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
    
    if ( !self.onlyShowPreview )
    {
        [self loadVideoAsset];
    }
    
    self.isLoading = NO;
    
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
         strongSelf.isLoading = YES;
     }
                                 completion:^(UIImage *image)
     {
         if (image != nil)
         {
             [weakSelf determinedPreferredBackgroundColorWithImage:image];
             completionBlock();
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
                  [weakSelf determinedPreferredBackgroundColorWithImage:image];
                  completionBlock();
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
    self.isLoading = YES;
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
    
    [self updateBackgroundColorAnimated:YES];
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
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
            self.isLoading = YES;
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
                // If we were previously only showing the preview, now we need to load the video asset
                [self loadVideoAsset];
            }
            self.isLoading = YES;
            [self.likeButton show];
            [self.videoPlayer play];
            self.videoPlayer.muted = NO;
            self.userInteractionEnabled = YES;
            break;
    }
}

@end
