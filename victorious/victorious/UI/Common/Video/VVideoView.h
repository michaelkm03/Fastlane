//
//  VVideoView.h
//  victorious
//
//  Created by Patrick Lynch on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VVideoPlayerDelegate.h"
@import AVFoundation;
#import "GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h"

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
//TODO: Remove it when this class is migrated to Swift
/// Don't use me. It's exposed so we can use it in a Swift extension
@property (nonatomic, assign, readonly) AVPlayer *player;
/// Don't use me. It's exposed so we can use it in a Swift extension
@property (nonatomic, assign, readwrite) IMAAVPlayerContentPlayhead *contentPlayhead;
/// Don't use me. It's exposed so we can use it in a Swift extension
@property (nonatomic, assign, readwrite) IMAAdsLoader *adsLoader;

NS_ASSUME_NONNULL_END

@end