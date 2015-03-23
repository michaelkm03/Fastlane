//
//  VVideoFrameRateComposition.h
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

/**
 VVideoFrameRateComposition provides a convenient interface for displaying and exporting a video with a custom frame rate.
 */
@interface VVideoFrameRateComposition : NSObject

/**
 The designated initializer for this class. Pass in appropriate parameters.
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL
                   frameDuration:(CMTime)frameDuration
                       muteAudio:(BOOL)muteAudio NS_DESIGNATED_INITIALIZER;

/**
 *  The url to create an AVAsset from.
 */
@property (nonatomic, readonly) NSURL *videoURL;

/**
 *  Reciprocal of frame rate i.e. 1/30 = 30fps.
 */
@property (nonatomic, readonly) CMTime frameDuration;

/**
 *  Muting the audio will remove any audio tracks from the internal composition.
 */
@property (nonatomic, readonly) BOOL muteAudio;

/**
 *  A completion block for when the video is ready to be played.
 */
@property (nonatomic, copy) void (^playerItemReady)(AVPlayerItem *playerItem);

/**
 *  An export session for rendering.
 *
 *  @return A configured export session
 */
- (AVAssetExportSession *)makeExportable;

/**
 *  The internal video composition used in construction of the player item. 
 *  Use this forfor rendering + thumbnailing.
 *
 *  @return The AVVideoComposition used in creating the AVPlayerItem.
 */
- (AVVideoComposition *)videoComposition;

@end
