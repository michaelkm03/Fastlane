//
//  VDependencyManager+VAvatarBadgeAppearance.m
//  victorious
//
//  Created by Sharif Ahmed on 9/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VAvatarBadgeAppearance.h"

NSString * const VDependencyManagerAvatarBadgeAppearanceMinLevelKey = @"minLevel";
NSString * const VDependencyManagerAvatarBadgeAppearanceBackgroundColorKey = @"color.link";
NSString * const VDependencyManagerAvatarBadgeAppearanceTextColorKey = @"color.text";

@implementation VDependencyManager (VAvatarBadgeAppearance)

- (VDependencyManager *)avatarBadgeAppearanceDependencyManager
{
    NSDictionary *avatarBadgeAppearanceDictionary = [self templateValueOfType:[NSDictionary class] forKey:@"avatarBadgeAppearance"];
    if ( avatarBadgeAppearanceDictionary != nil )
    {
        return [self childDependencyManagerWithAddedConfiguration:avatarBadgeAppearanceDictionary];
    }
    return nil;
}

@end
