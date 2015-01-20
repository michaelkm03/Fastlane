//
//  VWorkspaceFlowController.m
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceFlowController.h"

// Dependency
#import "VDependencyManager.h"

// Constants
#import "VConstants.h"

// Tools
#import "VToolController.h"

// Category
#import "NSURL+MediaType.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VWorkspaceViewController.h"
#import "VPublishViewController.h"

// Models
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VPublishParameters.h"

// Animators
#import "VPublishBlurOverAnimator.h"

NSString * const VWorkspaceFlowControllerInitialCaptureStateKey = @"initialCaptureStateKey";
NSString * const VWorkspaceFlowControllerSequenceToRemixKey = @"sequenceToRemixKey";

typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerState)
{
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

@property (nonatomic, assign) VImageToolControllerInitialImageEditState initialImageEditState;
@property (nonatomic, assign) VVideoToolControllerInitialVideoEditState initialVideoEditState;

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
        _state = VWorkspaceFlowControllerStateCapture;
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.navigationBarHidden = YES;
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
            [self setupCapture];
        }
        
        _initialImageEditState = VImageToolControllerInitialImageEditStateCrop;
        NSNumber *initalImageEditStateValue = [dependencyManager numberForKey:VImageToolControllerInitialImageEditStateKey];
        if (initalImageEditStateValue != nil)
        {
            _initialImageEditState = [initalImageEditStateValue integerValue];
        }
        
        _initialVideoEditState = VVideoToolControllerInitialVideoEditStateVideo;
        NSNumber *initialVideoEditStateValue = [dependencyManager numberForKey:VVideoToolControllerInitalVideoEditStateKey];
        if (initialVideoEditStateValue != nil)
        {
            _initialVideoEditState = [initialVideoEditStateValue integerValue];
        }
    }
    return self;
}

- (void)transitionFromState:(VWorkspaceFlowControllerState)oldState
                    toState:(VWorkspaceFlowControllerState)newState
{
    __weak typeof(self) welf = self;
    
    if ((oldState == VWorkspaceFlowControllerStateCapture) && (newState == VWorkspaceFlowControllerStateEdit))
    {
        [self toEditState];
    }
    else if ((oldState == VWorkspaceFlowControllerStateEdit) && (newState == VWorkspaceFlowControllerStateCapture))
    {
        BOOL isRemix = [[self.flowNavigationController.viewControllers firstObject] isKindOfClass:[VWorkspaceViewController class]];
        if (isRemix)
        {
            if (self.completion)
            {
                self.completion(NO);
            }
            else
            {
                NSAssert(false, @"VWorkspaceFlowController requires a completion block!");
            }
        }
        else
        {
            [self.flowNavigationController popViewControllerAnimated:YES];
        }
    }
    else if ((oldState == VWorkspaceFlowControllerStateEdit) && (newState == VWorkspaceFlowControllerStatePublish))
    {
        NSAssert((self.renderedMeidaURL != nil), @"We need a rendered media url to begin publishing!");
        
        VPublishParameters *publishParameters = [[VPublishParameters alloc] init];
        publishParameters.mediaToUploadURL = self.renderedMeidaURL;
        
        VPublishViewController *publishViewController = [VPublishViewController newWithDependencyManager:self.dependencyManager];
        publishViewController.publishParameters = publishParameters;
        publishParameters.previewImage = self.previewImage;
        if ([[self.flowNavigationController topViewController] isKindOfClass:[VWorkspaceViewController class]])
        {
            VWorkspaceViewController *workspace = (VWorkspaceViewController *)[self.flowNavigationController topViewController];
            if ([workspace.toolController isKindOfClass:[VVideoToolController class]])
            {
                VVideoToolController *videoToolController = (VVideoToolController *)workspace.toolController;
                publishParameters.isGIF = videoToolController.isGIF;
                publishParameters.didTrim = videoToolController.didTrim;
            }
            else if ([workspace.toolController isKindOfClass:[VImageToolController class]])
            {
                VImageToolController *imageToolController = (VImageToolController *)workspace.toolController;
                publishParameters.embeddedText = imageToolController.embeddedText;
                publishParameters.textToolType = imageToolController.textToolType;
                publishParameters.filterName = imageToolController.filterName;
            }
        }
        VSequence *sequenceToRemix = [self.dependencyManager templateValueOfType:[VSequence class]
                                                                          forKey:VWorkspaceFlowControllerSequenceToRemixKey];
        if (sequenceToRemix)
        {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            publishParameters.parentSequenceID = [formatter numberFromString:sequenceToRemix.remoteId];
            publishParameters.parentNodeID = [sequenceToRemix firstNode].remoteId;
        }
        publishViewController.completion = ^void(BOOL published)
        {
            if (published)
            {
                if (welf.completion)
                {
                    welf.completion(YES);
                }
                else
                {
                    NSAssert(false, @"VWorkspaceFlowController requires a completion block!");
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

- (void)setupCapture
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

- (VMediaCaptureCompletion)mediaCaptureCompletion
{
    __weak typeof(self) welf = self;
    return ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            welf.capturedMediaURL = capturedMediaURL;
            [welf transitionFromState:welf.state
                              toState:VWorkspaceFlowControllerStateEdit];
        }
        else
        {
            if (welf.completion)
            {
                welf.completion(NO);
            }
            else
            {
                NSAssert(false, @"VWorkspaceFlowController requires a completion block!");
            }
        }
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

- (void)toEditState
{
    NSAssert((self.capturedMediaURL != nil), @"We need a captured media url to begin editing!");
    
    __weak typeof(self) welf = self;
    VWorkspaceViewController *workspaceViewController;
    if ([self.capturedMediaURL v_hasImageExtension])
    {
        workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
        workspaceViewController.mediaURL = self.capturedMediaURL;
        ((VImageToolController *)workspaceViewController.toolController).defaultImageTool = self.initialImageEditState;
    }
    else if ([self.capturedMediaURL v_hasVideoExtension])
    {
        workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerVideoWorkspaceKey];
        workspaceViewController.mediaURL = self.capturedMediaURL;
        ((VVideoToolController *)workspaceViewController.toolController).defaultVideoTool = self.initialVideoEditState;
    }
    else
    {
        NSAssert(false, @"Media type not supported!");
    }
    
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
