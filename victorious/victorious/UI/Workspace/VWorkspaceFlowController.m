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

// Animators
#import "VPublishBlurOverAnimator.h"

NSString * const VWorkspaceFlowControllerInitialCaptureStateKey = @"initialCaptureStateKey";
NSString * const VWorkspaceFlowControllerSequenceToRemixKey = @"sequenceToRemixKey";

typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerState)
{
    VWorkspaceFlowControllerStateUninitialized,
    VWorkspaceFlowControllerStateCapture,
    VWorkspaceFlowControllerStateEdit,
    VWorkspaceFlowControllerStatePublish
};

@interface VWorkspaceFlowController () <UINavigationControllerDelegate>

@property (nonatomic, assign) VWorkspaceFlowControllerState state;

@property (nonatomic, strong) NSURL *capturedMediaURL;
@property (nonatomic, strong) NSURL *renderedMeidaURL;

@property (nonatomic, strong) UIImage *previewImage;

@property (nonatomic, strong) UINavigationController *flowNavigationController;

@property (nonatomic, strong) VPublishBlurOverAnimator *transitionAnimator;

@end

@implementation VWorkspaceFlowController

@synthesize completion = _completion;
@synthesize dependencyManager = _dependencyManager;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        _state = VWorkspaceFlowControllerStateUninitialized;
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.delegate = self;
        _transitionAnimator = [[VPublishBlurOverAnimator alloc] init];
        
        VSequence *sequenceToRemix = [dependencyManager templateValueOfType:[VSequence class] forKey:VWorkspaceFlowControllerSequenceToRemixKey];
        if (sequenceToRemix != nil)
        {
            [self extractCapturedMediaURLwithSequenceToRemix:sequenceToRemix];
            [self transitionFromState:_state
                              toState:VWorkspaceFlowControllerStateEdit];
        }
        else
        {
            [self transitionFromState:_state
                              toState:VWorkspaceFlowControllerStateCapture];
        }
    }
    return self;
}

- (void)transitionFromState:(VWorkspaceFlowControllerState)oldState
                    toState:(VWorkspaceFlowControllerState)newState
{
    __weak typeof(self) welf = self;
    
    if ((oldState == VWorkspaceFlowControllerStateUninitialized) && (newState == VWorkspaceFlowControllerStateCapture))
    {
        VWorkspaceFlowControllerInitialCaptureState initialCaptureState = VWorkspaceFlowControllerInitialCaptureStateImage;
        NSNumber *initialCaptureStateValue = [self.dependencyManager numberForKey:VWorkspaceFlowControllerInitialCaptureStateKey];
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
    else if ((oldState == VWorkspaceFlowControllerStateCapture) && (newState == VWorkspaceFlowControllerStateEdit))
    {
        NSAssert((self.capturedMediaURL != nil), @"We need a captured media url to begin editing!");
        
        VWorkspaceViewController *workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
        workspaceViewController.mediaURL = self.capturedMediaURL;
        workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
        {
            if (finished)
            {
                welf.renderedMeidaURL = renderedMediaURL;
                welf.previewImage = previewImage;
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
        
        VPublishViewController *publishViewController = [VPublishViewController newWithDependencyManager:self.dependencyManager];
        publishViewController.mediaToUploadURL = self.renderedMeidaURL;
        publishViewController.previewImage = self.previewImage;
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
        welf.previewImage = nil;
    }
    else
    {
        NSAssert(false, @"Not a valid transition");
    }
    self.state = newState;
}

#pragma mark - VFlowController

- (UIViewController *)flowRootViewController
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

- (void)extractCapturedMediaURLwithSequenceToRemix:(VSequence *)sequence
{
    if (sequence.isImage)
    {
        self.capturedMediaURL = [[[sequence firstNode] imageAsset] dataURL];
    }
    else if (sequence.isVideo)
    {
        self.capturedMediaURL = [[[sequence firstNode] mp4Asset] dataURL] ;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (![fromVC isKindOfClass:[VPublishViewController class]] && ![toVC isKindOfClass:[VPublishViewController class]])
    {
        return nil;
    }
    
    self.transitionAnimator.presenting = (operation == UINavigationControllerOperationPush) ? YES : NO;
    return self.transitionAnimator;
}

@end
