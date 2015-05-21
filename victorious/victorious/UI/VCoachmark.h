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

typedef NS_ENUM( NSUInteger, VToastVerticalLocation )
{
    VToastVerticalLocationTop,
    VToastVerticalLocationMiddle,
    VToastVerticalLocationBottom,
    VToastVerticalLocationInvalid
};

@interface VCoachmark : NSObject <VHasManagedDependencies>

/**
    The text that should display when this coachmark is shown as a toast,
    describing the screen that is currently displayed
 */
@property (nonatomic, strong) NSString *currentScreenText;

/**
    The text that should display when this coachmark is shown as a tooltip,
    describing a screen that is not currently displayed
 */
@property (nonatomic, strong) NSString *relatedScreenText;

/**
    The id of the screen that this coachmark is describing.
 */
@property (nonatomic, strong) NSString *displayTarget;

/**
    An array of ids of screens where this coachmark can appear. Can include the displayTarget.
 */
@property (nonatomic, strong) NSArray *displayScreens;

/**
    The background of the coachmark view. This will be masked into a tooltip shape if necessary.
 */
@property (nonatomic, strong) VBackground *background;

/**
    The color of the displayed text.
 */
@property (nonatomic, strong) UIColor *textColor;

/**
    The font of the displayed text.
 */
@property (nonatomic, strong) UIFont *font;

/**
    The vertical location of the coachmark when it is shown as a toast.
 */
@property (nonatomic, assign) VToastVerticalLocation toastLocation;

/**
    The identifier of this coachmark. This id is consistent across sessions.
 */
@property (nonatomic, strong) NSString *remoteId;

/**
    The length this coachmark should stay on screen if the user does not interact with the screen.
 */
@property (nonatomic, readonly) NSUInteger displayDuration;

/**
    Whether or not this coachmark has already been shown.
 */
@property (nonatomic, assign) BOOL hasBeenShown;

@end
