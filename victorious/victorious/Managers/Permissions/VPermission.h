//
//  VPermission.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDependencyManager.h"
#import "VPermissionAlertViewController.h"

static NSString * const VPermissionAlertViewControllerKey = @"permissionsAlert";

/**
 *  Enum representing permission states
 */
typedef NS_ENUM( NSInteger, VPermissionState )
{
    /**
     *  Status of the permission is not yet known.
     */
    VPermissionStateUnknown,
    /**
     *  Permission not supported on this device.
     */
    VPermissionUnsupported,
    /**
     *  Initial prompt for permission was denied.
     */
    VPermissionStatePromptDenied,
    /**
     *  iOS prompt for permission was denied.
     */
    VPermissionStateSystemDenied,
    /**
     *  Permission is authorized.
     */
    VPermissionStateAuthorized
};

typedef void (^VPermissionRequestCompletionHandler)(BOOL granted, VPermissionState state, NSError *error);

/**
 Abstract base class for requesting certain iOS permissions.
 
 Subclasses must take care of returning status and
 requesting access to the specific permission.
 */
@interface VPermission : NSObject <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Determines whether the initial prompt is shown before the system prompt
 */
@property (nonatomic, assign) BOOL shouldShowInitialPrompt;

/**
 Prompts the user for a certain permission if necessary. If the user has already
 granted access to this permission or denied the system prompt, the completion 
 handler is called right away. If not, it will present an initial prompt before
 showing the system prompt.
 
 @param viewController The view controller that the initial permission prompt should
 be presented over.
 @param completion A completion block that will be called as soon as the status of the
 permission has been determined.
 */
- (void)requestPermissionInViewController:(UIViewController *)viewController
                    withCompletionHandler:(VPermissionRequestCompletionHandler)completion;
/**
 Subclasses should override this and return the status of the specific permission
 */
- (VPermissionState)permissionState;

/**
 Subclasses should override this to display a custom message on the permissions alert view
 */
- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Subclasses should override this and prompt for permission appropriately
 */
- (void)requestSystemPermission:(VPermissionRequestCompletionHandler)completion;

@end
