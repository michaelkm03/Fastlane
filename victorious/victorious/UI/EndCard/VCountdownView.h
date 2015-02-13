//
//  VCountdownView.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view that draws two ciruclar rings, the front-most of which can
 be changed to an arc that fills a percentage of the full ring shape.
 Useful for counters, loaders or other representations of time or progress.
 */
@interface VCountdownView : UIView

/**
 The color of the ring that is animating
 */
@property (nonatomic, strong) UIColor *ringBackgroundColor;

/**
 The color of the static ring behind the animating ring.
 */
@property (nonatomic, strong) UIColor *ringColor;

/**
 The thickness of each ring to be drawn.
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 The total amount of time (seconds) that the countdown view should animate from.
 */
- (void)startCountdownWithTime:(NSTimeInterval)time;

@end
