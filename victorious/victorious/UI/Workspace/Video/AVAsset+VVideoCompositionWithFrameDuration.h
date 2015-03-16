//
//  AVAsset+VVideoCompositionWithFrameDuration.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (VVideoCompositionWithFrameDuration)

/**
 *  Create a video composition with a specific frame duration.
 *  Can lower the frame duration but not raise it.
 *  Also ensures that the video is rendered to a multiple of 16.
 *
 *  @param frameDuration The desired frame duration.
 *
 *  @return An AVVideoComposition with the given frame duration.
 */
- (AVVideoComposition *)videoCompositionWithFrameDuration:(CMTime)frameDuration;

@end
