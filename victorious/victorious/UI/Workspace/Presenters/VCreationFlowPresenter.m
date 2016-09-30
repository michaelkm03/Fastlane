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
#import "VTrackingManager.h"
#import "victorious-Swift.h"

static NSString * const kCreationFlowKey = @"createFlow";
static NSString * const kImageCreationFlowKey = @"imageCreateFlow";
static NSString * const kGIFCreationFlowKey = @"gifCreateFlow";
static NSString * const kVideoCreateFlow = @"videoCreateFlow";
static NSString * const kPollCreateFlow = @"pollCreateFlow";
static NSString * const kTextCreateFlow = @"textCreateFlow";
static NSString * const kLibraryCreateFlow = @"libraryCreateFlow";
static NSString * const kMixedMediaCameraCreateFlow = @"mixedMediaCameraCreateFlow";
static NSString * const kNativeCameraCreateFlow = @"nativeCameraCreateFlow";

@interface VCreationFlowPresenter () <VCreationFlowControllerDelegate>

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;
@property (nonatomic, strong) VCreationFlowController *currentCreationFlow;

@end

@implementation VCreationFlowPresenter

- (id)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    self.shouldShowPublishScreenForFlowController = YES;
    self.creationFlowControllerDelegate = self;
    return self;
}

- (void)presentWorkspaceOnViewController:(UIViewController *)originViewController creationFlowType:(VCreationFlowType)creationFlowType
{
    self.viewControllerPresentedOn = originViewController;
    
    switch (creationFlowType)
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
            [self presentCreateFlowWithKey:kMixedMediaCameraCreateFlow];
            break;
        case VCreationFlowTypeNativeCamera:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateFromNativeCameraSelected];
            [self presentCreateFlowWithKey:kNativeCameraCreateFlow];
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
    flowController.creationFlowDelegate = self.creationFlowControllerDelegate;
    if (flowController == nil)
    {
        NSAssert(NO, @"Failed to present the desired workspace flow");
        return;
    }
    [self.viewControllerPresentedOn presentViewController:flowController.rootFlowController animated:YES completion:nil];
    self.currentCreationFlow = flowController;
}

- (void)dismissCurrentFlowController
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
    self.currentCreationFlow = nil;
}

#pragma mark - VCreationFlowController

- (void)creationFlowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self dismissCurrentFlowController];
}

- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController
{
    [self.viewControllerPresentedOn dismissViewControllerAnimated:YES completion:nil];
    self.currentCreationFlow = nil;
}

+ (VWorkspaceViewController *)preferredWorkspaceForMediaType:(MediaType)mediaType fromDependencyManager:(VDependencyManager *)dependencyManager
{
    VWorkspaceViewController *workspace = nil;
    switch (mediaType)
    {
        case MediaTypeImage:
            workspace = (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
            break;
            
        case MediaTypeVideo:
            workspace = (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerNativeWorkspaceKey];
            if ( workspace == nil )
            {
                //Fall back to video workspace
                workspace = (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerVideoWorkspaceKey];
            }
            break;
            
        default:
            break;
    }
    
    return workspace;
}

@end
