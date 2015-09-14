//
//  VVideoPreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 9/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@protocol VVideoPlayer;

/**
 Defines an object that displays video, exposing a `videoPlayer` object that can
 be used to control playback and other video-based interactions.
*/
@protocol VVideoPreviewView <NSObject>

@property (nonatomic, weak, readonly) id<VVideoPlayer> videoPlayer;

@end