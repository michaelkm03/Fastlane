//
//  VAdPlayerView.h
//  victorious
//
//  Created by Lawrence Leach on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface VAdPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end