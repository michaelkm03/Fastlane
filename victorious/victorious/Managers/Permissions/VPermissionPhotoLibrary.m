//
//  VPermissionPhotoLibrary.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionPhotoLibrary.h"

@import AssetsLibrary;

@implementation VPermissionPhotoLibrary

- (VPermissionState)permissionState
{
    ALAuthorizationStatus systemState = [ALAssetsLibrary authorizationStatus];
    switch (systemState)
    {
        case ALAuthorizationStatusAuthorized:
            return VPermissionStateAuthorized;
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
            return VPermissionStateSystemDenied;
        case ALAuthorizationStatusNotDetermined:
            return VPermissionStateUnknown;
    }
}

- (void)requestForPermission:(VPermissionRequestCompletionHandler)completion
{
    ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                completion(YES, [self permissionState], nil);
                            });
         }
     } failureBlock:^(NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(NO, [self permissionState], nil);
                        });
     }];
}

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"photoLibraryPermission.message"];
    if (message != nil && message.length > 0)
    {
        return message;
    }
    return NSLocalizedString(@"We need permission to access your photo library", @"");
}

@end
