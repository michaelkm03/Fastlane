//
//  VContentViewController+Videos.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VCVideoPlayerView.h"

@interface VContentViewController (Videos) <VCVideoPlayerDelegate>

- (void)loadVideo; ///< Loads and plays a video
- (BOOL)isVideoLoadingOrLoaded; ///< Returns YES if -loadVideo has been called without a subsequent -unloadVideo.
- (void)unloadVideoWithDuration:(NSTimeInterval)duration; ///< Undoes the changes that -loadVideo does.

- (IBAction)pressedRemix:(id)sender;

@end
