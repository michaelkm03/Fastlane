//
//  VCreationFlowPresenter.m
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowPresenter.h"

// Dependencies
#import "VDependencyManager.h"
#import "VCreationFlowShim.h"

// API
#import "VObjectManager+Users.h"

// Creation UI
#import "VCreationFlowController.h"

// Authorization
#import "VAuthorizedAction.h"

// Action sheet
#import "VAlertController.h"
#import "VCreateSheetViewController.h"

// Tracking
#import "VTrackingManager.h"

static NSString * const kCreateSheetKey = @"createSheet";
static NSString * const kCreationFlowKey = @"createFlow";
static NSString * const kImageCreationFlowKey = @"imageCreateFlow";
static NSString * const kGIFCreationFlowKey = @"gifCreateFlow";
static NSString * const kVideoCreateFlow = @"videoCreateFlow";
static NSString * const kPollCreateFlow = @"pollCreateFlow";
static NSString * const kTextCreateFlow = @"textCreateFlow";

@interface VCreationFlowPresenter () <VCreationFlowControllerDelegate>

@end

@implementation VCreationFlowPresenter

- (void)present
{
    VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                         dependencyManager:self.dependencyManager];
    [authorizedAction performFromViewController:self.viewControllerToPresentOn
                                        context:VAuthorizationContextCreatePost
                                     completion:^(BOOL authorized)
     {
         if (authorized)
         {
             [self authorizedPresent];
         }
     }];
}

- (void)authorizedPresent
{
    NSDictionary *addedDependencies = @{kAnimateFromTopKey : @(self.showsCreationSheetFromTop)};

    VCreateSheetViewController *createSheet = [self.dependencyManager templateValueOfType:[VCreateSheetViewController class] forKey:kCreateSheetKey withAddedDependencies:addedDependencies];
    
    if (createSheet != nil)
    {
        [createSheet setCompletionHandler:^(VCreateSheetViewController *createSheetViewController, VCreationType chosenItemIdentifier)
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

- (void)openWorkspaceWithItemIdentifier:(VCreationType)identifier
{
    switch (identifier)
    {
        case VCreationTypeImage:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
            [self presentCreateFlowWithKey:kImageCreationFlowKey];
            break;
        case VCreationTypeVideo:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
            [self presentCreateFlowWithKey:kVideoCreateFlow];
            break;
        case VCreationTypeText:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateTextOnlyPostSelected];
            [self presentCreateFlowWithKey:kTextCreateFlow];
            break;
        case VCreationTypeGIF:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateGIFPostSelected];
            [self presentCreateFlowWithKey:kGIFCreationFlowKey];
            break;
        case VCreationTypePoll:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
            [self presentCreateFlowWithKey:kPollCreateFlow];
            break;
        case VCreationTypeUnknown:
            break;
    }
}

- (void)presentCreateFlowWithKey:(NSString *)key
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCreatePost forSessionParameterWithKey:VTrackingKeyContext];
    
    VCreationFlowController *flowController = [self.dependencyManager templateValueOfType:[VCreationFlowController class]
                                                                                   forKey:key];
    flowController.creationFlowDelegate = self;
    [self.viewControllerToPresentOn presentViewController:flowController
                                                 animated:YES
                                               completion:nil];
}

#pragma mark - VCreationFlowController

- (void)creationFLowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerToPresentOn dismissViewControllerAnimated:YES completion:nil];
}

@end
