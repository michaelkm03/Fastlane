//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VConstants.h"

@interface VAbstractVideoEditorViewController : UIViewController

@property (nonatomic, strong)           NSURL*          sourceURL;

@property (nonatomic)                   BOOL            muteAudio;
@property (nonatomic)                   VPlaybackSpeed  playBackSpeed;
@property (nonatomic)                   VLoopType       playbackLooping;
@property (nonatomic)                   CGFloat         startSeconds;
@property (nonatomic)                   CGFloat         endSeconds;

@end
