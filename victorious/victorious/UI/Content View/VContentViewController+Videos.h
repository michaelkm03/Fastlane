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

- (BOOL)isVideoLoadingOrLoaded; ///< Returns YES if -playVideoAtURL:withPreviewView: has been called without a subsequent -unloadVideoWithDuration:
- (void)unloadVideoWithDuration:(NSTimeInterval)duration; ///< Undoes the changes that -loadVideo does.

@end
