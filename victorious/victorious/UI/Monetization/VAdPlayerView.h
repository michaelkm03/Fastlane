//
//  VAdPlayerView.h
//  victorious
//
//  Created by Lawrence Leach on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenXMSDK.h"

@class AVPlayer;

@interface VAdPlayerView : OXMMediaPlaybackView

/**
 The AVPlayer to be used by this view to display video
 
 @param player AVPlayer object.
 */
- (void)setPlayer:(AVPlayer *)player;

/**
 Specifies how the video is displayed within a player layer’s bounds.
 
 @param fillMode How the video is displayed: AVLayerVideoGravityResizeAspect is default value.
 */
- (void)setVideoFillMode:(NSString *)fillMode;

@end