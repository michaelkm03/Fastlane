//
//  UIViewController+VContentCreationActionSheet.m
//  victorious
//
//  Created by Michael Sena on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIViewController+VContentCreationActionSheet.h"

#import "VObjectManager+Users.h"

// Creation UI
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VCreatePollViewController.h"

// Action sheet
#import "VAlertController.h"

// Tracking
#import "VTrackingManager.h"

// Login
#import "VAuthorizationViewControllerFactory.h"
#import "VRootViewController.h"

@implementation UIViewController (VContentCreationActionSheet)

- (void)showContentTypeSelection
{
    UIViewController *loginViewController = [VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]];
    if (loginViewController != nil)
    {
        [[VRootViewController rootViewController] presentViewController:loginViewController animated:YES completion:nil];
        return;
    }
    
    VAlertController *alertControler = [VAlertController actionSheetWithTitle:nil message:nil];
    [alertControler addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString(@"CancelButton", @"Cancel button") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateCancelSelected];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Video Post", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create an Image Post", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateImage];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a GIF", @"Create a gif action button.")
                                                    handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateGIFPostSelected];
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo
                                                            initialImageEditState:VImageToolControllerInitialImageEditStateText
                                                         andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateGIF];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Poll", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
                                   VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                   UINavigationController *wrapperNavStack = [[UINavigationController alloc] initWithRootViewController:createViewController];
                                   [self presentViewController:wrapperNavStack animated:YES completion:nil];
                               }]];
    [alertControler presentInViewController:self animated:YES completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
                           initialImageEditState:(VImageToolControllerInitialImageEditState)initialImageEdit
                        andInitialVideoEditState:(VVideoToolControllerInitialVideoEditState)initialVideoEdit
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCreatePost forSessionParameterWithKey:VTrackingKeyContext];
    
    VWorkspaceFlowController *workspaceFlowController = [VWorkspaceFlowController workspaceFlowControllerWithoutADependencyMangerWithInjection:@{VWorkspaceFlowControllerInitialCaptureStateKey:@(initialCaptureState),
                                                                                                                                                 VImageToolControllerInitialImageEditStateKey:@(initialImageEdit),
                                                                                                                                                 VVideoToolControllerInitalVideoEditStateKey:@(initialVideoEdit)}];
    workspaceFlowController.videoEnabled = YES;
    workspaceFlowController.delegate = self;
    
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
{
    [self presentCreateFlowWithInitialCaptureState:initialCaptureState
                             initialImageEditState:VImageToolControllerInitialImageEditStateText
                          andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateVideo];
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VLoginRequest

- (NSString *)localizedExplanation
{
    return NSLocalizedString(@"User wants to create content", @"");
}

@end
