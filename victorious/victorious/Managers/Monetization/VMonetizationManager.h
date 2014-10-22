//
//  VMonetizationManagerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAdVideoPlayerViewController.h"
#import "VCVideoPlayerViewController.h"
#import "VConstants.h"

@protocol VMonetizationManagerDelegate;

@class VSequence, VMonetizationManager;

@protocol VMonetizationManagerDelegate <NSObject>

// Content video delegation methods
- (void)contentVideo:(VMonetizationManager *)monetizationManager
       didPlayToTime:(CMTime)time
           totalTime:(CMTime)time;

- (void)contentVideoPlayedToEnd:(VMonetizationManager *)monetizationManager
                  withTotalTime:(CMTime)totalTime;

- (void)contentVideoReadyToPlay:(VMonetizationManager *)monetizationManager;

@end


@interface VMonetizationManager : NSObject

@property (nonatomic, strong) VCVideoPlayerViewController *contentVideoPlayer;
@property (nonatomic, strong) VAdVideoPlayerViewController *adVideoPlayer;

@property (nonatomic, strong) VSequence *sequence;

@property (nonatomic, strong) id<VMonetizationManagerDelegate>delegate;

- (instancetype)initWithSequenceObject:(VSequence *)sequence;

/**
 Starts the monetization manager
 */
- (void)startMonetizationManager;

@end
