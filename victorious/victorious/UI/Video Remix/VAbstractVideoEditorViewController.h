//
//  VAbstractVideoEditorViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

typedef NS_ENUM(NSUInteger, RemixPlaybackSpeed)
{
    kRemixPlaybackHalfSpeed,
    kRemixPlaybackNormalSpeed,
    kRemixPlaybackDoubleSpeed
};

typedef NS_ENUM(NSUInteger, RemixLoopingType)
{
    kRemixLoopingNone,
    kRemixLoopingLoop,
    kRemixLoopingBackandForth
};

@interface VAbstractVideoEditorViewController : UIViewController

@property (nonatomic, strong)           NSURL*                  sourceURL;

@property (nonatomic)                   BOOL                    muteAudio;
@property (nonatomic)                   RemixPlaybackSpeed      playBackSpeed;
@property (nonatomic)                   RemixLoopingType        playbackLooping;
@property (nonatomic)                   CGFloat                 startSeconds;
@property (nonatomic)                   CGFloat                 endSeconds;

@end
