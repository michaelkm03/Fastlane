//
//  VVideoFrameRateComposition.h
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

/**
 VVideoFrameRateTool provides a convenient interface for displaying and exporting a video with a custom frame rate.
 */
@interface VVideoFrameRateComposition : NSObject

/**
 The designated initializer for this class. Pass in appropriate parameters.
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL
                   frameDuration:(CMTime)frameDuration
                       muteAudio:(BOOL)muteAudio NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSURL *videoURL; // The url to create an AVAsset from.

@property (nonatomic, readonly) CMTime frameDuration; // Reciprocal of frame rate i.e. 1/30 = 30fps.

@property (nonatomic, readonly) BOOL muteAudio; // YES if audio is muted

@property (nonatomic, copy) void (^playerItemReady)(AVPlayerItem *playerItem); // A completion block for when the video is ready to be played.

- (AVAssetExportSession *)makeExportable; // An export session for rendering.

@end
