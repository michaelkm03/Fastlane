//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VConstants.h"
#import "VCVideoPlayerViewController.h"

@class VElapsedTimeFormatter;

@interface  VAbstractVideoEditorViewController : UIViewController   <VCVideoPlayerDelegate>

@property (nonatomic, weak)     IBOutlet    UIView             *previewParentView;
@property (nonatomic, strong)   VCVideoPlayerViewController    *videoPlayerViewController;

@property (nonatomic, weak)     IBOutlet    UIImageView        *playCircle;
@property (nonatomic, weak)     IBOutlet    UIImageView        *playButton;
@property (nonatomic, weak)     IBOutlet    UIButton            *takeImageSnapShotButton;

@property (nonatomic, strong)   NSURL                          *sourceURL;
@property (nonatomic, strong)   NSURL                          *targetURL;

@property (nonatomic, weak)     IBOutlet    UIButton           *rateButton;
@property (nonatomic, weak)     IBOutlet    UIButton           *loopButton;
@property (nonatomic, weak)     IBOutlet    UIButton           *muteButton;

@property (nonatomic)           BOOL                            shouldMuteAudio;
@property (nonatomic)           VPlaybackSpeed                  playBackSpeed;
@property (nonatomic)           VLoopType                       playbackLooping;

@property (nonatomic)           NSInteger                       parentNodeID;
@property (nonatomic)           NSInteger                       parentSequenceID;

@property (nonatomic)           BOOL                            animatingPlayButton;

@property (nonatomic, strong)   VElapsedTimeFormatter          *elapsedTimeFormatter;

- (void)startAnimation;
- (void)stopAnimation;

@end
