//
//  VCountdownViewController.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCountDownViewDelegate <NSObject>

- (void)countDownComplete;

@end

@interface VCountdownViewController : UIViewController

@property (nonatomic, weak) id<VCountDownViewDelegate> delegate;

/**
 Brings playing the ring depletion animation and updates label with curren time,
 counting down from the supplied duration value to zero.  Fades in the rings
 and label if not already visible.
 */
- (void)startTimerWithDuration:(NSTimeInterval)duration;

/**
 Stops the animation and fades out rings and label.
 */
- (void)stopTimer;

@end
