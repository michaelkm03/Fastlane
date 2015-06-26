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
#import "VCreateSheetViewController.h"

// Tracking
#import "VTrackingManager.h"

static NSString * const kCreateSheetKey = @"createSheet";

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
    NSDictionary *addedDependencies = @{kAnimateFromTopKey : @(self.showsCreationSheetFromTop)};
    VCreateSheetViewController *createSheet = [self.dependencyManager templateValueOfType:[VCreateSheetViewController class] forKey:kCreateSheetKey withAddedDependencies:addedDependencies];
    
    if (createSheet != nil)
    {
        [createSheet setCompletionHandler:^(VCreateSheetViewController *createSheetViewController, VCreateSheetItemIdentifier chosenItemIdentifier)
         {
             [createSheetViewController dismissViewControllerAnimated:YES completion:^
              {
                  [self openWorkspaceWithItemIdentifier:chosenItemIdentifier];
              }];
             
         }];
        [self.viewControllerToPresentOn presentViewController:createSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:NSLocalizedString(@"GenericFailMessage", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self.viewControllerToPresentOn presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openWorkspaceWithItemIdentifier:(VCreateSheetItemIdentifier)identifier
{
    switch (identifier)
    {
        case VCreateSheetItemIdentifierImage:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
            [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateImage];
            break;
        case VCreateSheetItemIdentifierVideo:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
            [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo];
            break;
        case VCreateSheetItemIdentifierText:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateTextOnlyPostSelected];
            [self presentTextOnlyWorkspace];
            break;
        case VCreateSheetItemIdentifierGIF:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateGIFPostSelected];
            [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo
                                     initialImageEditState:VImageToolControllerInitialImageEditStateText
                                  andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateGIF];
            
            break;
        case VCreateSheetItemIdentifierPoll:
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
            break;
        }
        default:
            break;
    }
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
