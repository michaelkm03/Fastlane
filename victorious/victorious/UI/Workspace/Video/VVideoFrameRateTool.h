//
//  VVideoCompositionController.h
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface VVideoFrameRateTool : NSObject

- (instancetype)initWithVideoURL:(NSURL *)videoURL
                   frameDuration:(CMTime)frameDuration
                       muteAudio:(BOOL)muteAudio NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSURL *videoURL;

@property (nonatomic, readonly) CMTime frameDuration;

#warning implement me
@property (nonatomic, readonly) BOOL muteAudio;

@property (nonatomic, copy) void (^playerItemRedy)(AVPlayerItem *playerItem);

#warning implement me
- (AVAssetExportSession *)makeExportable;

@end
