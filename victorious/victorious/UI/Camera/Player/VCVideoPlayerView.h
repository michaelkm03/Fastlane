//
//  VCVideoPlayerView.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

/**
 A wrapper around AVPlayerLayer
 */
@interface VCVideoPlayerView : UIView

@property (nonatomic) AVPlayer *player;

@end
