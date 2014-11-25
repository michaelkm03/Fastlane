//
//  VNotificationSettings+Fetcher.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettings.h"
#import "VObjectManager.h"
#import "VNotificationSettings+RestKit.h"

@implementation VNotificationSettings (Fetcher)

+ (VNotificationSettings *)createDefaultSettings
{
    NSString *entityName = [VNotificationSettings entityName];
    id obj = [[VObjectManager sharedManager] objectWithEntityName:entityName subclass:[VNotificationSettings class]];
    NSAssert( [obj isKindOfClass:[VNotificationSettings class]], @"" );
    
    // Set defaults if object was created successfully
    VNotificationSettings *settings = (VNotificationSettings *)obj;
    settings.isPostFromCreatorEnabled = @NO;
    settings.isNewFollowerEnabled = @NO;
    settings.isNewPrivateMessageEnabled = @NO;
    settings.isNewCommentOnMyPostEnabled = @NO;
    settings.isPostFromFollowedEnabled = @NO;
    
    return obj;
}

- (BOOL)equals:(VNotificationSettings *)settings
{
    return settings.isPostFromCreatorEnabled.boolValue == self.isPostFromCreatorEnabled.boolValue &&
        settings.isNewFollowerEnabled.boolValue == self.isNewFollowerEnabled.boolValue &&
        settings.isNewPrivateMessageEnabled.boolValue == self.isNewPrivateMessageEnabled.boolValue &&
        settings.isNewCommentOnMyPostEnabled.boolValue == self.isNewCommentOnMyPostEnabled.boolValue &&
        settings.isPostFromFollowedEnabled.boolValue == self.isPostFromFollowedEnabled.boolValue;
}

@end
