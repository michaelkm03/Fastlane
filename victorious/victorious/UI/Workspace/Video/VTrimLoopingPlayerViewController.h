//
//  VTrimLoopingPlayerViewController.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreMedia;

@class VTrimLoopingPlayerViewController;

/**
 *  A delegate for informing consumers of this class about playback.
 */
@protocol VTrimLoopingPlayerViewControllerDelegate <NSObject>

/**
 *  Informs the consumer about the current play time in original time.
 *
 *  @param currentTime The current time of the player.
 */
- (void)trimLoopingPlayerDidPlayToTime:(CMTime)currentTime;

@end

/**
 *  VTrimLoopingPlayerViewController loops a video at a specified mediaURL. 
 *  With an optional trim range within the duration of the video to loop over.
 */
@interface VTrimLoopingPlayerViewController : UIViewController

/**
 *  The media URL to load the video from.
 */
@property (nonatomic, copy) NSURL *mediaURL;

/**
 *  A delegate to inform about playback.
 */
@property (nonatomic, weak) id <VTrimLoopingPlayerViewControllerDelegate> delegate;

/**
 *  A trim range to loop over within the entire duration of the video.
 */
@property (nonatomic, assign) CMTimeRange trimRange;

/**
 *  Whether or not to mute the looping player.
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/**
 *  A custom frame duration, uses the video's native frame duration if never assigned.
 */
@property (nonatomic, assign) CMTime frameDuration;

@end
