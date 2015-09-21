//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VFocusable.h"
#import "VPreviewViewBackgroundHost.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VVideoView.h"
#import "VFocusable.h"
#import "VVideoPreviewView.h"
#import "VVideoSettings.h"

/**
 *  A Sequence preview view for video sequences.
 */
@interface VBaseVideoSequencePreviewView : VSequencePreviewView <VFocusable, VPreviewViewBackgroundHost, VVideoPlayerDelegate, VVideoPreviewView>

/**
 * Responsible for playing video in-line. Subclasses can hide this if
 * there is no need to play video.
 */
@property (nonatomic, strong, readonly) id<VVideoPlayer> videoPlayer;

/**
 * The image view responsible for showing the video's preview image
 */
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

/**
 *  Hides or shows the background that holds the image view. Defaults to hidden.
 *
 *  @parameter visible If YES, the background container is made visible without animation.
 */
- (void)setBackgroundContainerViewVisible:(BOOL)visible;

@property (nonatomic, strong) VVideoSettings *videoSettings;
@property (nonatomic, strong) VAsset *videoAsset;
@property (nonatomic, readonly) BOOL shouldAutoplay;
@property (nonatomic, readonly) BOOL shouldLoop;
@property (nonatomic, assign) BOOL preventSeekToStartOnFinish;

@end
