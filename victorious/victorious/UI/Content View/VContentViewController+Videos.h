//
//  VContentViewController+Videos.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VConstants.h"

const NSTimeInterval kVideoPlayerAnimationDuration; ///< The duration to be used when animating the video player into and out of view

@interface VContentViewController (Videos) <VCVideoPlayerDelegate>


@property (strong, nonatomic) VCVideoPlayerViewController* videoPlayer;

@property (nonatomic, copy) void (^onVideoCompletionBlock)(void); ///< A block to execute as soon as playback finishes. Block will be cleared after executing once.

/**
 A block to execute when -unloadVideoWithDuration:completion: is called. 
 Block will be cleared after executing once. Will be called BEFORE 
 onVideoCompletionBlock
 */
@property (nonatomic, copy) void (^onVideoUnloadBlock)(void);

/**
 Plays a video.
 
 @param contentURL   The URL of the video to play
 @param previewView  The view that contains a thumbnail of the video being played.
                     It should be a direct subview of mediaView, and it should be
                     positioned via optional constraints (i.e. constraints with a
                     priority less then UILayoutPriorityRequired), since it will
                     be temporarily re-positioned with required constraints while
                     the video is playing.
 */
- (void)playVideoAtURL:(NSURL *)contentURL withPreviewView:(UIView *)previewView;

- (void)pauseVideo; ///< Pause a playing video or prevent a loading video from starting to play
- (void)resumeVideo; ///< Resume video playback
- (BOOL)isVideoLoadingOrLoaded; ///< Returns YES if -playVideoAtURL:withPreviewView: has been called without a subsequent -unloadVideoWithDuration:
- (BOOL)isVideoLoaded; ///< Returns YES if the video player has been animated into view
- (void)unloadVideoAnimated:(BOOL)animated withDuration:(NSTimeInterval)duration completion:(void(^)(void))completion; ///< Undoes the changes that -loadVideo makes.

@end
