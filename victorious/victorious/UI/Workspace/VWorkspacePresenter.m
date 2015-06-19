//
//  VWorkspacePresenter.m
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspacePresenter.h"

#import "VDependencyManager+VWorkspace.h"
#import "VObjectManager+Users.h"

// Creation UI
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VVideoToolController.h"
#import "VCreatePollViewController.h"
#import "VTextWorkspaceFlowController.h"

// Action sheet
#import "VAlertController.h"

// Tracking
#import "VTrackingManager.h"

@interface VWorkspacePresenter () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UIViewController *viewControllerToPresentOn;

@end

@implementation VWorkspacePresenter

+ (instancetype)workspacePresenterWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencyManager:(VDependencyManager *)dependencyManager
{
    VWorkspacePresenter *workspacePresenter = [[self alloc] init];
    workspacePresenter.dependencyManager = dependencyManager;
    workspacePresenter.viewControllerToPresentOn = viewControllerToPresentOn;
    return workspacePresenter;
}

- (void)present
{
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
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Text Post", @"Create a text post action button.")
                                                    handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateTextOnlyPostSelected];
                                   
                                   [self presentTextOnlyWorkspace];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Poll", @"") handler:^(VAlertAction *action)
                               {
                                   [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
                                   VCreatePollViewController *createViewController = [VCreatePollViewController newWithDependencyManager:self.dependencyManager];
                                   __weak typeof(self) welf = self;
                                   createViewController.completionHandler = ^void(VCreatePollViewControllerResult result)
                                   {
                                       [welf.viewControllerToPresentOn dismissViewControllerAnimated:YES
                                                                completion:nil];
                                   };
                                   UINavigationController *wrapperNavStack = [[UINavigationController alloc] initWithRootViewController:createViewController];
                                   [self.viewControllerToPresentOn presentViewController:wrapperNavStack animated:YES completion:nil];
                               }]];
    [alertControler presentInViewController:self.viewControllerToPresentOn animated:YES completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
                           initialImageEditState:(VImageToolControllerInitialImageEditState)initialImageEdit
                        andInitialVideoEditState:(VVideoToolControllerInitialVideoEditState)initialVideoEdit
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCreatePost forSessionParameterWithKey:VTrackingKeyContext];
    
    VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager workspaceFlowControllerWithAddedDependencies:@{
        VWorkspaceFlowControllerInitialCaptureStateKey: @(initialCaptureState),
        VImageToolControllerInitialImageEditStateKey: @(initialImageEdit),
        VVideoToolControllerInitalVideoEditStateKey: @(initialVideoEdit) }];
    workspaceFlowController.delegate = self;
    
    [self.viewControllerToPresentOn presentViewController:workspaceFlowController.flowRootViewController
                                                 animated:YES
                                               completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
{
    [self presentCreateFlowWithInitialCaptureState:initialCaptureState
                             initialImageEditState:VImageToolControllerInitialImageEditStateFilter
                          andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateVideo];
    
    
}

- (void)presentTextOnlyWorkspace
{
    VTextWorkspaceFlowController *textWorkspaceController = [VTextWorkspaceFlowController textWorkspaceFlowControllerWithDependencyManager:self.dependencyManager];
    [self.viewControllerToPresentOn presentViewController:textWorkspaceController.flowRootViewController animated:YES completion:nil];
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
}

@end
