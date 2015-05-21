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

@implementation VCoachmark

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _relatedScreenText = [dependencyManager stringForKey:@"relatedScreenText"];
        _currentScreenText = [dependencyManager stringForKey:@"currentScreenText"];
        _textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        _font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        _background = [dependencyManager background];
        _displayTarget = [dependencyManager stringForKey:@"displayTarget"];
        _displayScreens = [dependencyManager arrayOfValuesOfType:[NSString class] forKey:@"displayScreens"];
        _remoteId = [dependencyManager stringForKey:@"id"];
        _toastLocation = [self toastVerticalLocationFromString:[dependencyManager stringForKey:@"toastVerticalLocation"]];
        _displayDuration = [[dependencyManager numberForKey:@"displayDuration"] unsignedIntegerValue];
        _hasBeenShown = NO;
    }
    return self;
}

- (VToastVerticalLocation)toastVerticalLocationFromString:(NSString *)locationString
{
    VToastVerticalLocation location = VToastVerticalLocationTop;
    if ( [locationString isEqualToString:@"bottom"] )
    {
        location = VToastVerticalLocationBottom;
    }
    else if ( [locationString isEqualToString:@"middle"] )
    {
        location = VToastVerticalLocationMiddle;
    }
    else if ( [locationString isEqualToString:@"top"] )
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
