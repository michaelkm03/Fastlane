//
//  VCameraPermissionsController.m
//  victorious
//
//  Created by Michael Sena on 7/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCameraPermissionsController.h"

@import AVFoundation;

@interface VCameraPermissionsController ()

@property (nonatomic, weak) UIViewController *viewControllerToPresentOn;

@end

@implementation VCameraPermissionsController

- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewController
{
    self = [super init];
    if (self != nil)
    {
        _viewControllerToPresentOn = viewController;
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)requestPermissionWithPermission:(VPermission *)permission
                             completion:(void (^)(BOOL deniedPrePrompt, VPermissionState state))completion
{
    BOOL shouldShowPreSystemPermission = ([permission permissionState] != VPermissionStateSystemDenied);
    void (^permissionHandler)(BOOL granted, VPermissionState state, NSError *error) = ^void(BOOL granted, VPermissionState state, NSError *error)
    {
        completion(!granted, state);
        if (state == VPermissionStateSystemDenied)
        {
            [self notifyUserOfFailedCameraPermission];
        }
    };
    
    // Request camera permission
    if (shouldShowPreSystemPermission)
    {
        [permission requestPermissionInViewController:self.viewControllerToPresentOn
                                withCompletionHandler:permissionHandler];
    }
    else
    {
        [permission requestSystemPermissionWithCompletion:permissionHandler];
    }
}


- (void)notifyUserOfFailedCameraPermission
{
    NSString *errorMessage;
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusRestricted)
    {
        errorMessage = NSLocalizedString(@"AccessCameraRestricted", @"");
    }
    else
    {
        errorMessage = NSLocalizedString(@"AccessCameraDenied", @"");
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self.viewControllerToPresentOn presentViewController:alertController animated:YES completion:nil];
}

@end
