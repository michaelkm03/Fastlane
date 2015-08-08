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

@property (nonatomic, strong) UIView *playIconContainerView;
@property (nonatomic, strong) VVideoView *videoView;

- (void)makeBackgroundContainerViewVisible:(BOOL)visible;

@end
