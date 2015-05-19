//
//  VPermissionProfilePicture.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionProfilePicture.h"

@implementation VPermissionProfilePicture

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"profileImagePermission.message"];
    if (message != nil && message.length > 0)
    {
        return message;
    }
    return NSLocalizedString(@"We hope to connect and communicate with our fans. By having a profile picture, we will be able to recognize you!\n\nWould you like to take a profile picture?", @"");
}

@end
