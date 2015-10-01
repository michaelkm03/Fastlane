//
//  VPreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 9/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@protocol VVideoPlayer;

@protocol VPreviewView <NSObject>
@optional

/**
 Allows a context to inform the receiver of a default at which asset should rendered.
 This value is open to interpretation based on the type of class implementing the protocol,
 but in general it is used to optimize display of content.
 */
- (void)setRenderingSize:(CGSize)renderingSize;

@end

/**
 Defines an object that will respond to events from a VVideoPreviewView.
 */
@protocol VVideoPreviewViewDelegate <VPreviewView>

- (void)animateAlongsideVideoToolbarWillAppear;
- (void)animateAlongsideVideoToolbarWillDisappear;
- (void)videoPlaybackDidFinish;

@end

/**
 Defines an object that displays video, exposing a `videoPlayer` object that can
 be used to control playback and other video-based interactions.
*/
@protocol VVideoPreviewView <NSObject>

@property (nonatomic, weak, readonly) id<VVideoPlayer> videoPlayer;
@property (nonatomic, weak, nullable) id<VVideoPreviewViewDelegate> delegate;
@property (nonatomic, assign) BOOL willShowEndCard;

@end