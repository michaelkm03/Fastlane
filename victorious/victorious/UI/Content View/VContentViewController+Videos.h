//
//  VContentViewController+Videos.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VCVideoPlayerView.h"

@interface VContentViewController (Videos) <VCVideoPlayerDelegate>

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
- (BOOL)isVideoLoadingOrLoaded; ///< Returns YES if -playVideoAtURL:withPreviewView: has been called without a subsequent -unloadVideoWithDuration:
- (void)unloadVideoWithDuration:(NSTimeInterval)duration completion:(void(^)(void))completion; ///< Undoes the changes that -loadVideo makes.

@end
