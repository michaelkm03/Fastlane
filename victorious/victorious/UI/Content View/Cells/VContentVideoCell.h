//
//  VContentVideoCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"

#import "VCVideoPlayerViewController.h"

// ViewModel
#import "VVideoCellViewModel.h"

@class VContentVideoCell, VTracking;

@import AVFoundation;

/**
 *  Informs delegate of play progress. Forwards from an internal VCVideoPlayerViewController
 */
@protocol VContentVideoCellDelegate <NSObject>

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)time;

/**
 *  Informs the delegate of completion of the video.
 */
- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime;
- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell;

- (void)videoCellWillStartPlaying:(VContentVideoCell *)videoCell;

@end

/**
 *  A UICollectionViewCell for displaying video content. Contains a VCVideoPlayerViewController for displaying of video content.
 */
@interface VContentVideoCell : VContentCell

@property (nonatomic, strong) VVideoCellViewModel *viewModel;

@property (nonatomic, weak) id <VContentVideoCellDelegate> delegate;

// KVO off of this to disable any disruptive actions
@property (nonatomic, readonly) BOOL isPlayingAd;

/**
 *  Instruct the video cell's video player to play. Will respect the speed and loop properties.
 */
- (void)play;

- (void)replay;

- (void)pause;

- (void)togglePlayControls;

/**
 Should the video player hide the toolbar, disable tap to toggle toolbar,
 and disable double tap to change aspect fit.
 */
@property (nonatomic, assign) BOOL playerControlsDisabled;

/**
 Should the video player be muted.
 */
@property (nonatomic, assign) BOOL audioMuted;

/**
 Playback speed at which video should play.
 */
@property (nonatomic, assign) float speed;

/**
 Should the video player loop at the end of playback.
 */
@property (nonatomic, assign) BOOL loop;

@property (nonatomic, readonly) AVPlayerStatus status;

@property (nonatomic, readonly) UIView *videoPlayerContainer;

@property (nonatomic, readonly) CMTime currentTime;

/// Use this to animate with the same curve that animates the play controls.
- (void)setAnimateAlongsizePlayControlsBlock:(void (^)(BOOL playControlsHidden))animateWithPlayControls;

- (void)setTracking:(VTracking *)tracking;

/**
 Properly rotates itself and subcomponents based on the rotation of the collection view.
 Make sure to forward this from your collection view controller.
 */
- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
