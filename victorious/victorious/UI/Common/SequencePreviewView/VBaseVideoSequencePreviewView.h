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
#import "VPreviewView.h"
#import "VVideoSettings.h"
#import "VContentFittingPreviewView.h"

/**
 *  A Sequence preview view for video sequences.
 */
@interface VBaseVideoSequencePreviewView : VSequencePreviewView <VFocusable, VVideoPlayerDelegate, VVideoPreviewView, VContentFittingPreviewView>

/**
 * Responsible for playing video in-line. Subclasses can hide this if
 * there is no need to play video.
 */
@property (nonatomic, strong, readonly) id<VVideoPlayer> videoPlayer;

/**
 * The image view responsible for showing the video's preview image
 */
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@property (nonatomic, strong) VVideoSettings *videoSettings;

@property (nonatomic, strong) VAsset *videoAsset;

@property (nonatomic, readonly) BOOL shouldAutoplay;

@property (nonatomic, readonly) BOOL shouldLoop;

@end
