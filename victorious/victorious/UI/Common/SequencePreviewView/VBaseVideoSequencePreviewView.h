//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VCellFocus.h"
#import "VPreviewViewBackgroundHost.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VVideoView.h"

/**
 *  A Sequence preview view for video sequences.
 */
@interface VBaseVideoSequencePreviewView : VSequencePreviewView <VCellFocus, VPreviewViewBackgroundHost, VVideoViewDelegate>

/**
 * Responsible for the play icon that appears on the preview view.
 * Subclasses can hide this if they are playing video in-line.
 */
@property (nonatomic, strong) UIView *playIconContainerView;

/**
 * Responsible for playing video in-line. Subclasses can hide this if
 * there is no need to play video.
 */
@property (nonatomic, strong) VVideoView *videoView;

/**
 * Indicated whether or not this preview view is currently in focus.
 */
@property (nonatomic, assign, readonly) BOOL inFocus;

- (void)makeBackgroundContainerViewVisible:(BOOL)visible;

@end
