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

/**
 *  A Sequence preview view for video sequences.
 */
@interface VBaseVideoSequencePreviewView : VSequencePreviewView <VFocusable, VPreviewViewBackgroundHost, VVideoViewDelegate>

/**
 * Responsible for the play icon that appears on the preview view.
 * Subclasses can hide this if they are playing video in-line.
 */
@property (nonatomic, strong, readonly) UIView *playIconContainerView;

/**
 * Responsible for playing video in-line. Subclasses can hide this if
 * there is no need to play video.
 */
@property (nonatomic, strong, readonly) VVideoView *videoView;

/**
 * The image view responsible for showing the video's preview image
 */
@property (nonatomic, strong, readonly) UIImageView *previewImageView;


/**
 * Indicated whether or not this preview view is currently in focus.
 */
@property (nonatomic, assign) VFocusType focusType;

/**
 *  If YES, this preview view will only display the preview image for this content.
 */
@property (nonatomic, assign) BOOL onlyShowPreview;

/**
 *  Hides or shows the background that holds the image view. Defaults to hidden.
 *
 *  @parameter visible If YES, the background container is made visible without animation.
 */
- (void)setBackgroundContainerViewVisible:(BOOL)visible;

@end
