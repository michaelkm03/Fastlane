//
//  VVideoToolController.h
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

@class VVideoPlayerView;

extern NSString * const VVideoToolControllerInitalVideoEditStateKey;
typedef NS_ENUM(NSInteger, VVideoToolControllerInitialVideoEditState)
{
    VVideoToolControllerInitialVideoEditStateVideo, // Default
    VVideoToolControllerInitialVideoEditStateGIF,
};

@interface VVideoToolController : VToolController

@property (nonatomic, strong) NSURL *mediaURL;

@property (nonatomic, strong) VVideoPlayerView *playerView;

@property (nonatomic, assign) VVideoToolControllerInitialVideoEditState defaultVideoTool;

@end
