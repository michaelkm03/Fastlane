//
//  VWorkspaceFlowController.m
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceFlowController.h"

#import "VDependencyManager.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VWorkspaceViewController.h"
#import "VPublishViewController.h"

// Models
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"

NSString * const VWorkspaceFlowControllerInitialCaptureStateKey = @"initialCaptureStateKey";
NSString * const VWorkspaceFlowControllerSequenceToRemixKey = @"sequenceToRemixKey";

typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerState)
{
    VWorkspaceFlowControllerStateCapture,
    VWorkspaceFlowControllerStateEdit,
    VWorkspaceFlowControllerStatePublish
};

@interface VWorkspaceFlowController ()

@property (nonatomic, assign) VWorkspaceFlowControllerState state;

@property (nonatomic, strong) NSURL *capturedMediaURL;
@property (nonatomic, strong) NSURL *renderedMeidaURL;

@property (nonatomic, strong) UINavigationController *flowNavigationController;

@property (nonatomic, strong) VDependencyManager *workspaceDependencyManager;

@end

@implementation VWorkspaceFlowController

@synthesize completion = _completion;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _workspaceDependencyManager = dependencyManager;
        _state = VWorkspaceFlowControllerStateCapture;
        _flowNavigationController = [[UINavigationController alloc] init];
        
#warning Check if sequence to remix is here
        
        VWorkspaceFlowControllerInitialCaptureState initialCaptureState = VWorkspaceFlowControllerInitialCaptureStateImage;
        NSNumber *initialCaptureStateValue = [dependencyManager numberForKey:VWorkspaceFlowControllerInitialCaptureStateKey];
        initialCaptureState = (initialCaptureStateValue != nil) ? [initialCaptureStateValue integerValue] : initialCaptureState;
        
        VCameraViewController *cameraViewController;
        switch (initialCaptureState)
        {
            case VWorkspaceFlowControllerInitialCaptureStateImage:
                cameraViewController = [VCameraViewController cameraViewControllerStartingWithStillCapture];
                break;
            case VWorkspaceFlowControllerInitialCaptureStateVideo:
                cameraViewController = [VCameraViewController cameraViewControllerStartingWithVideoCapture];
                break;
        }
        cameraViewController.shouldSkipPreview = YES;
        cameraViewController.completionBlock = [self mediaCaptureCompletion];
        [_flowNavigationController pushViewController:cameraViewController
                                             animated:NO];
    
    }
    return self;
}

//
//+ (instancetype)workspaceFlowControllerWithSequenceRemix:(VSequence *)sequence
//{
//    VWorkspaceFlowController *flowController = [[self alloc] init];
//    
//    if (sequence.isImage)
//    {
//        flowController.capturedMediaURL = [[[sequence firstNode] imageAsset] dataURL];
//        [flowController transitionFromState:flowController.state
//                                    toState:VWorkspaceFlowControllerStateEdit];
//    }
//    else if (sequence.isVideo)
//    {
//        flowController.capturedMediaURL = [[[sequence firstNode] mp4Asset] dataURL];
//        [flowController transitionFromState:flowController.state
//                                    toState:VWorkspaceFlowControllerStateEdit];
//    }
//    
//    return flowController;
//}

- (void)transitionFromState:(VWorkspaceFlowControllerState)oldState
                    toState:(VWorkspaceFlowControllerState)newState
{
    __weak typeof(self) welf = self;
    
    if ((oldState == VWorkspaceFlowControllerStateCapture) && (newState == VWorkspaceFlowControllerStateEdit))
    {
        NSAssert((self.capturedMediaURL != nil), @"We need a captured media url to begin editing!");
        
        VWorkspaceViewController *workspaceViewController = (VWorkspaceViewController *)[self.workspaceDependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
        workspaceViewController.mediaURL = self.capturedMediaURL;
        workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
        {
            if (finished)
            {
                welf.renderedMeidaURL = renderedMediaURL;
                [welf transitionFromState:welf.state
                                  toState:VWorkspaceFlowControllerStatePublish];
            }
            else
            {
                welf.capturedMediaURL = nil;
                [welf transitionFromState:welf.state
                                  toState:VWorkspaceFlowControllerStateCapture];
            }
        };
        [self.flowNavigationController pushViewController:workspaceViewController
                                                 animated:YES];
    }
    else if ((oldState == VWorkspaceFlowControllerStateEdit) && (newState == VWorkspaceFlowControllerStateCapture))
    {
        [self.flowNavigationController popViewControllerAnimated:YES];
    }
    else if ((oldState == VWorkspaceFlowControllerStateEdit) && (newState == VWorkspaceFlowControllerStatePublish))
    {
        NSAssert((self.renderedMeidaURL != nil), @"We need a rendered media url to begin publishing!");
        
        VPublishViewController *publishViewController = [[VPublishViewController alloc] initWithNibName:nil
                                                                                                 bundle:nil];
        publishViewController.mediaToUploadURL = self.renderedMeidaURL;
        publishViewController.completion = ^void(BOOL published)
        {
            if (published)
            {
                if (welf.completion)
                {
                    welf.completion(YES);
                }
            }
            else
            {
                welf.renderedMeidaURL = nil;
                [welf transitionFromState:welf.state
                                  toState:VWorkspaceFlowControllerStateEdit];
            }
        };
        [self.flowNavigationController pushViewController:publishViewController
                                                 animated:YES];
    }
    else if ((oldState == VWorkspaceFlowControllerStatePublish) && (newState == VWorkspaceFlowControllerStateEdit))
    {
        [self.flowNavigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSAssert(false, @"Not a valid transition");
    }
    self.state = newState;
}

#pragma mark - VFlowController

- (UIViewController *)rootViewControllerOfFlow
{
    return self.flowNavigationController;
}

#pragma mark - Private Methods

- (VMediaCaptureCompletion)mediaCaptureCompletion
{
    __weak typeof(self) welf = self;
    return ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        welf.capturedMediaURL = capturedMediaURL;
        [welf transitionFromState:welf.state
                          toState:VWorkspaceFlowControllerStateEdit];
    };
}

@end
