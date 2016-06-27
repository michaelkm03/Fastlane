//
//  VVideoUtils.h
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

@interface VVideoUtils : NSObject

/**
 Creates an AVPlayerItem on a background thread.
 @param onReady A callback that will be called when complete and supplied with an AVPlayerItem.
 */
- (void)createPlayerItemWithURL:(NSURL *)itemURL loop:(BOOL)loop readyCallback:(void(^)(AVPlayerItem *, NSURL *composedItemURL, CMTime originalAssetDuration))onReady;

@end
