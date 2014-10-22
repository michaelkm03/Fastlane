//
//  VContentVideoCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"

#import "VCVideoPlayerViewController.h"

@class VContentVideoCell;

@import AVFoundation;

/**
 *  Informs delegate of play progress.
 */
@protocol VContentVideoCellDelgetate <NSObject>

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)time;

/**
 *  Informs the delegate of completion of the video.
 */
- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime;

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell;

@end

/**
 *  A UICollectionViewCell for displaying video content. Contains a VCVideoPlayerViewController for displaying of video content.
 */
@interface VContentVideoCell : VContentCell

@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, strong, readonly) VCVideoPlayerViewController *videoPlayerViewController;

@property (nonatomic, weak) id <VContentVideoCellDelgetate> delegate;

/**
 *  Instruct the video cell's video player to play.
 */
- (void)play;

@end