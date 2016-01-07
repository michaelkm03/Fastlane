//
//  VVideoPreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 10/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@protocol VVideoPlayer;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an object that will respond to events from a VVideoPreviewView.
 */
@protocol VVideoPreviewViewDelegate

- (void)animateAlongsideVideoToolbarWillAppear;
- (void)animateAlongsideVideoToolbarWillDisappear;
- (void)videoPlaybackDidFinish;

@end

@protocol VVideoPlayer;

/**
 Defines an object that displays video, exposing a `videoPlayer` object that can
 be used to control playback and other video-based interactions.
 */
@protocol VVideoPreviewView <NSObject>

@property (nonatomic, strong, readonly) id<VVideoPlayer> videoPlayer;
@property (nonatomic, weak, nullable) id<VVideoPreviewViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
