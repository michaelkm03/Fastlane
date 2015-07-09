//
//  VCoachmark.m
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmark.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VBackground.h"

static NSString * const kRelatedScreenTextKey = @"relatedScreenText";
static NSString * const kCurrentScreenTextKey = @"currentScreenText";
static NSString * const kDisplayTargetIDKey = @"displayTarget";
static NSString * const kDisplayScreensIDsKey = @"displayScreens";
static NSString * const kToastVerticalLocationKey = @"toastVerticalLocation";
static NSString * const kDisplayDurationKey = @"displayDuration";
static NSString * const kToastVerticalLocationTopKey = @"top";
static NSString * const kToastVerticalLocationMiddleKey = @"middle";
static NSString * const kToastVerticalLocationBottomKey = @"bottom";

static const CGFloat kAnimationDelay = 1.0f;
static const CGFloat kCoachmarkHorizontalInset = 24.0f;
static const CGFloat kCoachmarkVerticalInset = 5.0f;

@implementation VCoachmark

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _relatedScreenText = [dependencyManager stringForKey:kRelatedScreenTextKey];
        _currentScreenText = [dependencyManager stringForKey:kCurrentScreenTextKey];
        _textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        _font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        _background = [dependencyManager background];
        _displayTarget = [dependencyManager stringForKey:kDisplayTargetIDKey];
        _displayScreens = [dependencyManager arrayOfValuesOfType:[NSString class] forKey:kDisplayScreensIDsKey];
        _remoteId = [dependencyManager stringForKey:VDependencyManagerIDKey];
        _toastLocation = [self toastVerticalLocationFromString:[dependencyManager stringForKey:kToastVerticalLocationKey]];
        _displayDuration = [[dependencyManager numberForKey:kDisplayDurationKey] unsignedIntegerValue];
        _hasBeenShown = NO;
        _animationDelay = kAnimationDelay;
        _horizontalInset = kCoachmarkHorizontalInset;
        _verticalInset = kCoachmarkVerticalInset;
    }
    return self;
}

- (VToastVerticalLocation)toastVerticalLocationFromString:(NSString *)locationString
{
    VToastVerticalLocation location = VToastVerticalLocationTop;
    if ( [locationString isEqualToString:kToastVerticalLocationBottomKey] )
    {
        location = VToastVerticalLocationBottom;
    }
    else if ( [locationString isEqualToString:kToastVerticalLocationMiddleKey] )
    {
        location = VToastVerticalLocationMiddle;
    }
    else if ( [locationString isEqualToString:kToastVerticalLocationTopKey] )
    {
        location = VToastVerticalLocationTop;
    }
    else
    {
        NSAssert(false, @"Recieved invalid locationString value");
    }
    
    return location;
}

@end
