//
//  VCameraPermissionsController.h
//  victorious
//
//  Created by Michael Sena on 7/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPermission.h"

/**
 *  Simple helper object for cameraVCs.
 */
@interface VCameraPermissionsController : NSObject

/**
 *  Designated initializer.
 *
 *  @param viewController Parameter is required.
 */
- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Requests permisssions for the passed in permission object.
 *  Completion called after user has responded to the prompts. 
 *  Will be called on the main thread.
 */
- (void)requestPermissionWithPermission:(VPermission *)permission
                             completion:(void (^)(BOOL deniedPrePrompt, VPermissionState state))completion;

@end
