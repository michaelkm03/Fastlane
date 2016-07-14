//
//  VCoachmark.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VBackground;

/**
    A model represting a coachmark that is used to determine the appearance,
    location, and message of a coachmark view.
 */
@interface VCoachmark : NSObject <VHasManagedDependencies>

/**
    The text that should display when this coachmark is shown as a toast,
    describing the screen that is currently displayed
 */
@property (nonatomic, readonly) NSString *currentScreenText;

/**
    The text that should display when this coachmark is shown as a tooltip,
    describing a screen that is not currently displayed
 */
@property (nonatomic, readonly) NSString *relatedScreenText;

/**
    The id of the screen that this coachmark is describing.
 */
@property (nonatomic, readonly) NSString *displayTarget;

/**
    An array of ids of screens where this coachmark can appear. Can include the displayTarget.
 */
@property (nonatomic, readonly) NSArray *displayScreens;

/**
    The background of the coachmark view. This will be masked into a tooltip shape if necessary.
 */
@property (nonatomic, readonly) VBackground *background;

/**
    The color of the displayed text.
 */
@property (nonatomic, readonly) UIColor *textColor;

/**
    The font of the displayed text.
 */
@property (nonatomic, readonly) UIFont *font;

/**
    The identifier of this coachmark. This id is consistent across sessions.
 */
@property (nonatomic, readonly) NSString *remoteId;

/**
    The length this coachmark should stay on screen if the user does not
    interact with the screen. Measured in milliseconds.
 */
@property (nonatomic, readonly) NSTimeInterval displayDuration;

/**
    Whether or not this coachmark has already been shown.
 */
@property (nonatomic, assign) BOOL hasBeenShown;

/**
 Delay before the coachmark animates on screen. Defaults to 1.0f.
 */
@property (nonatomic, assign) CGFloat animationDelay;

/**
 How much this coachmark's view should be inset horizontally from it's super view's bounds. Defaults to 24.0f;
 */
@property (nonatomic, assign) CGFloat horizontalInset;

/**
 How much this coachmark's view should be inset vertically from view it's referencing. Defaults to 5.0f;
 */
@property (nonatomic, assign) CGFloat verticalInset;

@end
