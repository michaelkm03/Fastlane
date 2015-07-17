//
//  VTrimControl.h
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMTimeRange.h>

// maximum height of the trim control
extern CGFloat const VTrimControlMaximumHeight;

// Sends UIControlEventValueChanged on new selection

/**
 *  VTrimControl maintains a UISlider-like UI for selecting a range of content. VTrimControl maintains a thumbView allowing the user to grab and pan across the full width of the trim control. VTrimControl passes through any touches that do not hit on the thumb's head or body.
 */
@interface VTrimControl : UIControl

/**
 *  Updates max duration that the trim control can select. Doesn't send control events.
 */
@property (nonatomic, assign) CMTime maxDuration;

/**
 *  The text to display in the thumb head.
 */
@property (nonatomic, copy) NSAttributedString *attributedTitle;

/**
 *  The current time duration selected by the trim control.
 */
@property (nonatomic, readonly) CMTime selectedDuration;

/**
 *  The height of the trimmer body plus the vertical inset of the body
 */
+ (CGFloat)topPadding;

/**
 *  The view for the handle of the trimmer control
 */
@property (nonatomic, strong) UIView *trimThumbBody;

@end
