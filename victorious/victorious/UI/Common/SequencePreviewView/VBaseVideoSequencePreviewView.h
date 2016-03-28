//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VFocusable.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VVideoView.h"
#import "VFocusable.h"
#import "VRenderablePreviewView.h"
#import "VContentFittingPreviewView.h"
#import "VVideoPreviewView.h"

/**
 *  A Sequence preview view for video sequences.
 */
@interface VBaseVideoSequencePreviewView : VSequencePreviewView <VFocusable, VVideoPlayerDelegate, VVideoPreviewView, VContentFittingPreviewView>

/**
 * Responsible for playing video in-line. Subclasses can hide this if
 * there is no need to play video.
 */
@property (nonatomic, strong, readwrite) id<VVideoPlayer> videoPlayer;

/**
 * The image view responsible for showing the video's preview image
 */
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong, readonly) UIView *videoContainer;

@property (nonatomic, strong) VAsset *videoAsset;

@property (nonatomic, readonly) BOOL shouldAutoplay;

@property (nonatomic, readonly) BOOL shouldLoop;

@property (nonatomic, readonly) BOOL streamContentModeIsAspectFit;

/**
 Creates a video player using the provided frame.  This class provides a default implementation,
 but allows subclasses to override this method to provide a different implementation of `VVideoView`.
 */
- (id<VVideoPlayer>)createVideoPlayerWithFrame:(CGRect)frame;

/**
 Places a view that displays video playback into the view hiearchy in its proper place among
 other elements, such as UI controls and preview images.
 */
- (void)addVideoPlayerView:(UIView *)view;

/**
 Adjusts the hidden state of the video player layer as appropriate per the currently set sequence.
 */
- (void)updateStateOfVideoPlayerView;

@end
