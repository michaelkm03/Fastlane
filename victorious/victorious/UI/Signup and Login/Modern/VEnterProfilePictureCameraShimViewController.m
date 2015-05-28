//
//  VEnterProfilePictureCameraShimViewController.m
//  victorious
//
//  Created by Michael Sena on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEnterProfilePictureCameraShimViewController.h"

#import "VLoginFlowControllerResponder.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspace.h"

// Camera + Workspace
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"

@interface VEnterProfilePictureCameraShimViewController () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) UIViewController *viewControllerCameraPresentedFrom;

@end

@implementation VEnterProfilePictureCameraShimViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VEnterProfilePictureCameraShimViewController *enterProfileViewController = [[VEnterProfilePictureCameraShimViewController alloc] initWithNibName:nil bundle:nil];
    enterProfileViewController.dependencyManager = dependencyManager;
    return enterProfileViewController;
}

- (void)showCameraOnViewController:(UIViewController *)viewController
{
    NSDictionary *addedDependencies = @{ VImageToolControllerInitialImageEditStateKey : @(VImageToolControllerInitialImageEditStateFilter),
                                         VWorkspaceFlowControllerContextKey : @(VWorkspaceFlowControllerContextProfileImage) };
    VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager workspaceFlowControllerWithAddedDependencies:addedDependencies];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = NO;
    self.viewControllerCameraPresentedFrom = viewController;
    [viewController presentViewController:workspaceFlowController.flowRootViewController
                                 animated:YES
                               completion:nil];
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    id <VLoginFlowControllerResponder> flowController = [self.viewControllerCameraPresentedFrom targetForAction:@selector(setProfilePictureFilePath:)
                                                                                                     withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for setting the profile picture!");
    }
    [flowController setProfilePictureFilePath:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    id <VLoginFlowControllerResponder> flowController = [self.viewControllerCameraPresentedFrom targetForAction:@selector(setProfilePictureFilePath:)
                                                                                                     withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for setting the profile picture!");
    }
    [flowController setProfilePictureFilePath:capturedMediaURL];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

@end
