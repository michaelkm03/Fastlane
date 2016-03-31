//
//  VCreationFlowPresenter.m
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowPresenter.h"
#import "VDependencyManager.h"
#import "VCreationFlowController.h"
#import "VCreateSheetViewController.h"
#import "VTrackingManager.h"
#import "victorious-Swift.h"

static NSString * const kCreateSheetKey = @"createSheet";
static NSString * const kCreationFlowKey = @"createFlow";
static NSString * const kImageCreationFlowKey = @"imageCreateFlow";
static NSString * const kGIFCreationFlowKey = @"gifCreateFlow";
static NSString * const kVideoCreateFlow = @"videoCreateFlow";
static NSString * const kPollCreateFlow = @"pollCreateFlow";
static NSString * const kTextCreateFlow = @"textCreateFlow";
static NSString * const kLibraryCreateFlow = @"libraryCreateFlow";
static NSString * const kMixedMediaCameraFlow = @"mixedMediaCameraFlow";
static NSString * const kNativeCameraFlow = @"nativeCameraFlow";

@interface VCreationFlowPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;

@end

@implementation VCreationFlowPresenter

- (id)initWithDependencymanager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencymanager:dependencyManager];
    self.shouldShowPublishScreenForFlowController = YES;
    return self;
}

- (void)presentWorkspaceOnViewController:(UIViewController *)originViewController creationType:(VCreationFlowType)creationType
{
    self.viewControllerPresentedOn = originViewController;
    
    switch (creationType)
    {
        case VCreationFlowTypeImage:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateImagePostSelected];
            [self presentCreateFlowWithKey:kImageCreationFlowKey];
            break;
        case VCreationFlowTypeVideo:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateVideoPostSelected];
            [self presentCreateFlowWithKey:kVideoCreateFlow];
            break;
        case VCreationFlowTypeText:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateTextOnlyPostSelected];
            [self presentCreateFlowWithKey:kTextCreateFlow];
            break;
        case VCreationFlowTypeGIF:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateGIFPostSelected];
            [self presentCreateFlowWithKey:kGIFCreationFlowKey];
            break;
        case VCreationFlowTypePoll:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreatePollSelected];
            [self presentCreateFlowWithKey:kPollCreateFlow];
            break;
        case VCreationFlowTypeLibrary:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateFromLibrarySelected];
            [self presentCreateFlowWithKey:kLibraryCreateFlow];
            break;
        case VCreationFlowTypeMixedMediaCamera:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateFromMixedMediaCameraSelected];
            [self presentCreateFlowWithKey:kMixedMediaCameraFlow];
            break;
        case VCreationFlowTypeNativeCamera:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateFromNativeCameraSelected];
            [self presentCreateFlowWithKey:kNativeCameraFlow];
            break;
        case VCreationFlowTypeUnknown:
            break;
    }
}

- (void)presentCreateFlowWithKey:(NSString *)key
{
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCreatePost forSessionParameterWithKey:VTrackingKeyContext];
    
    Class type = [VCreationFlowController class];
    VCreationFlowController *flowController = [self.dependencyManager templateValueOfType:type forKey:key];
    flowController.creationFlowDelegate = self;
    [self.viewControllerPresentedOn presentViewController:flowController animated:YES completion:nil];
}

#pragma mark - VCreationFlowController

- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
}

@end
