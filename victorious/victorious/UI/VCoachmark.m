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
static NSString * const kTextColorKey = @"color.text";
static NSString * const kFontKey = @"font.paragraph";
static NSString * const kBackgroundKey = @"background";
static NSString * const kDisplayTargetKey = @"displayTarget";
static NSString * const kDisplayScreensKey = @"displayScreens";
static NSString * const kIdKey = @"id";
static NSString * const kHasBeenShownKey = @"hasBeenShown";
static NSString * const kToastLocationKey = @"toastLocation";

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
        _displayTarget = [dependencyManager stringForKey:kDisplayTargetKey];
        _displayScreens = [dependencyManager arrayOfValuesOfType:[NSString class] forKey:kDisplayScreensKey];
        _remoteId = [dependencyManager stringForKey:kIdKey];
        _toastLocation = [self toastLocationFromString:[dependencyManager stringForKey:kToastLocationKey]];
        
        //Initialize default shown state to NO
        _hasBeenShown = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if ( self != nil )
    {
        _remoteId = [aDecoder decodeObjectForKey:kIdKey];
        _hasBeenShown = [aDecoder decodeBoolForKey:kHasBeenShownKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_remoteId forKey:kIdKey];
    [aCoder encodeBool:_hasBeenShown forKey:kHasBeenShownKey];
}

- (VToastLocation)toastLocationFromString:(NSString *)locationString
{
    VToastLocation location = VToastLocationTop;
    if ( [locationString isEqualToString:@"bottom"] )
    {
        location = VToastLocationBottom;
    }
    else if ( [locationString isEqualToString:@"middle"] )
    {
        location = VToastLocationMiddle;
    }
    else if ( [locationString isEqualToString:@"top"] )
    {
        location = VToastLocationTop;
    }
    else
    {
        NSAssert(false, @"Recieved invalid locationString value");
    }
    
    return location;
}

- (BOOL)isEqualToCoachmark:(VCoachmark *)coachmark
{
    return [coachmark.remoteId isEqualToString:self.remoteId];
}

- (BOOL)isEqual:(id)object
{
    if ( object == self )
    {
        return YES;
    }
    if ( ![object isKindOfClass:[VCoachmark class]] )
    {
        return NO;
    }
    return [self isEqualToCoachmark:object];
}

- (NSUInteger)hash
{
    return [self.remoteId hash];
}

@end
