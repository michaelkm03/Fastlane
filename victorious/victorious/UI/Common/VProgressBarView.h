//
//  VProgressBarView.h
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Displays a progress bar.
 */
@interface VProgressBarView : UIView

/**
 *  The color to use for elapsed progress.
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 *  The current progress that should be displayed.
 */
@property (nonatomic, assign) CGFloat progress;

/**
 *  Will update the elapsed progress view with an animation.
 */
- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated;

/**
 * Will hide the progress view by flattening it down, as if
 * shrinking up into itself.
 */
- (void)clearProgressAnimated:(BOOL)animated;

@end
