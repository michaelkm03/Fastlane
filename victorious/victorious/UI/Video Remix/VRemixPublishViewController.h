//
//  VRemixPublishViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraPublishViewController.h"
#import "VConstants.h"

@interface VRemixPublishViewController : VCameraPublishViewController

@property (nonatomic)                   BOOL            muteAudio;
@property (nonatomic)                   VPlaybackSpeed  playBackSpeed;
@property (nonatomic)                   VLoopType       playbackLooping;
@property (nonatomic)                   CGFloat         startSeconds;
@property (nonatomic)                   CGFloat         endSeconds;

@end
