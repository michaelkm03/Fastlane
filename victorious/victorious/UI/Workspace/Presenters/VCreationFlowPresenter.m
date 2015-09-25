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
#import "victorious-Swift.h"

static NSString * const kCreateSheetKey = @"createSheet";
static NSString * const kCreationFlowKey = @"createFlow";
static NSString * const kImageCreationFlowKey = @"imageCreateFlow";
static NSString * const kGIFCreationFlowKey = @"gifCreateFlow";
static NSString * const kVideoCreateFlow = @"videoCreateFlow";
static NSString * const kPollCreateFlow = @"pollCreateFlow";
static NSString * const kTextCreateFlow = @"textCreateFlow";

@interface VCreationFlowPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;

@end

@implementation VCreationFlowPresenter

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    self.viewControllerPresentedOn = viewControllerToPresentOn;
    VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                         dependencyManager:self.dependencyManager];
    __weak typeof(self) welf = self;
    [authorizedAction performFromViewController:viewControllerToPresentOn
                                        context:VAuthorizationContextCreatePost
                                     completion:^(BOOL authorized)
     {
         __strong typeof(welf) strongSelf = welf;
         if (authorized)
         {
             [strongSelf authorizedPresent];
         }
     }];
}

- (void)authorizedPresent
{
    NSDictionary *addedDependencies = @{kAnimateFromTopKey : @(self.showsCreationSheetFromTop)};

    VCreateSheetViewController *createSheet = [self.dependencyManager templateValueOfType:[VCreateSheetViewController class] forKey:kCreateSheetKey withAddedDependencies:addedDependencies];
    
    if (createSheet != nil)
    {
        __weak typeof(self) welf = self;
        [createSheet setCompletionHandler:^(VCreateSheetViewController *createSheetViewController, VCreationType chosenItemIdentifier)
         {
             __strong typeof(welf) strongSelf = welf;
             [createSheetViewController dismissViewControllerAnimated:YES completion:^
              {
                  [strongSelf openWorkspaceWithItemIdentifier:chosenItemIdentifier];
              }];
             
         }];
        [self.viewControllerPresentedOn presentViewController:createSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:NSLocalizedString(@"GenericFailMessage", @"")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self.viewControllerPresentedOn presentViewController:alert animated:YES completion:nil];
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
    [self.viewControllerPresentedOn presentViewController:flowController
                                                 animated:YES
                                               completion:nil];
}

#pragma mark - VCreationFlowController

- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
}

@end
