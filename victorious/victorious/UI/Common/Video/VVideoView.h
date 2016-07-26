//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VVideoPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VVideoView;

/**
 A simple video player that displays video content only, without any UI.
 Conforms to `VVideoPlayer`, which provides the interface for controlling playback
 and responding to playback events.
 */
@interface VVideoView : UIView <VVideoPlayer>

@property (nonatomic, assign, readonly) BOOL playbackLikelyToKeepUp;
@property (nonatomic, assign, readonly) BOOL playbackBufferEmpty;

NS_ASSUME_NONNULL_END

@end
