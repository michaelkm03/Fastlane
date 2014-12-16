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

- (void)videoCellDidStartPlayingVideoAd:(VContentVideoCell *)videoCell;

- (void)videoCellDidStopPlayingVideoAd:(VContentVideoCell *)videoCell;

@end

/**
 *  A UICollectionViewCell for displaying video content. Contains a VCVideoPlayerViewController for displaying of video content.
 */
@interface VContentVideoCell : VContentCell

@property (nonatomic, strong) VVideoCellViewModel *viewModel;

@property (nonatomic, weak) id <VContentVideoCellDelegate> delegate;

// KVO off of this to disable any disruptive actions
@property (nonatomic, readonly) BOOL adPlaying;

/**
 *  Instruct the video cell's video player to play. Will respect the speed and loop properties.
 */
- (void)play;

- (void)pause;

- (void)togglePlayControls;

/**
 *  The speed to play the video.
 */
@property (nonatomic, assign) float speed;

/**
 *  Whether or not to loop the video.
 */
@property (nonatomic, assign) BOOL loop;

@property (nonatomic, readonly) AVPlayerStatus status;

@property (nonatomic, readonly) UIView *videoPlayerContainer;

@property (nonatomic, readonly) CMTime currentTime;

/// Use this to animate with the same curve that animates the play controls.
- (void)setAnimateAlongsizePlayControlsBlock:(void (^)(BOOL playControlsHidden))animateWithPlayControls;

- (void)setTracking:(VTracking *)tracking;

@end
