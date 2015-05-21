//
//  VPermissionProfilePicture.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionProfilePicture.h"
#import "VAppInfo.h"

@implementation VPermissionProfilePicture

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"profileImagePermission.message"];
    if (message != nil && message.length > 0)
    {
        return message;
    }
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:dependencyManager];
    NSString *finalString = [NSString stringWithFormat:NSLocalizedString(@"In order to be recognized by %@ and other fans, you need to set a profile picture.\n\n Would you like to set one now?", nil), appInfo.ownerName];
    return finalString;
}

@end
