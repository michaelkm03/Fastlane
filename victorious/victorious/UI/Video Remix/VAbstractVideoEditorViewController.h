//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VConstants.h"
#import "VCVideoPlayerView.h"

@interface  VAbstractVideoEditorViewController : UIViewController   <VCVideoPlayerDelegate>

@property (nonatomic, weak)     IBOutlet    VCVideoPlayerView*  previewView;;

@property (nonatomic, weak)     IBOutlet    UIImageView*        playCircle;
@property (nonatomic, weak)     IBOutlet    UIImageView*        playButton;

@property (nonatomic, strong)   NSURL*                          sourceURL;
@property (nonatomic, strong)   NSURL*                          targetURL;

@property (nonatomic)           BOOL                            shouldMuteAudio;
@property (nonatomic)           VPlaybackSpeed                  playBackSpeed;
@property (nonatomic)           VLoopType                       playbackLooping;

@property (nonatomic)           BOOL                            animatingPlayButton;


- (void)startAnimation;
- (void)stopAnimation;

@end
