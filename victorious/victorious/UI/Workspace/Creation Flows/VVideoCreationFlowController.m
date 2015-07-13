//
//  VVideoCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetCollectionGridViewController.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"
#import "VPublishViewController.h"

// Publishing
#import "VPublishParameters.h"

// Animators
#import "VPublishBlurOverAnimator.h"

// Views + Helpers
#import "UIAlertController+VSimpleAlert.h"

// Dependencies
#import "VDependencyManager.h"
#import "VMediaSource.h"

static NSString * const kVideoWorkspaceKey = @"videoWorkspace";

@interface VVideoCreationFlowController () <UINavigationControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishViewController *publishViewContorller;
@property (nonatomic, strong) VPublishBlurOverAnimator *publishAnimator;

@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VVideoCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        
        VCaptureContainerViewController *captureContainer = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        [captureContainer setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:captureContainer];
        [self setViewControllers:@[captureContainer]];
        
        VAssetCollectionGridViewController *gridViewController = [VAssetCollectionGridViewController assetGridViewControllerWithDependencyManager:dependencyManager];
        [captureContainer setContainedViewController:gridViewController];
        [self addCompleitonHandlerToMediaSource:gridViewController];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Methods

- (NSArray *)alternateCaptureOptions
{
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:^
                                             {
                                                 // Camera
                                             }];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:^
                                             {
                                                 // Search
                                             }];
    return @[cameraOption, searchOption];
}

- (void)addCompleitonHandlerToMediaSource:(id<VMediaSource>)mediaSource
{
    __weak typeof(self) welf = self;
    mediaSource.handler = ^void(UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (capturedMediaURL != nil)
        {
            [welf setupWorkspace];
            self.workspaceViewController.mediaURL = capturedMediaURL;
            self.workspaceViewController.previewImage = previewImage;
            
            VVideoToolController *toolController = (VVideoToolController *)welf.workspaceViewController.toolController;
            [toolController setDefaultVideoTool:VVideoToolControllerInitialVideoEditStateGIF];
            
            [self pushViewController:self.workspaceViewController animated:YES];
        }
    };
}

- (void)setupPublishScreen
{
    _publishAnimator = [[VPublishBlurOverAnimator alloc] init];
    _publishViewContorller = [self.dependencyManager newPublishViewController];
    
    __weak typeof(self) welf = self;
    _publishViewContorller.completion = ^void(BOOL published)
    {
        if (published)
        {
            welf.delegate = nil;
            // We're done!
            [welf.creationFlowDelegate creationFLowController:welf
                                     finishedWithPreviewImage:welf.previewImage
                                             capturedMediaURL:welf.renderedMediaURL];
        }
        else
        {
            // Cancelled
            [welf popViewControllerAnimated:YES];
        }
    };
}

- (void)setupWorkspace
{
    _workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:kVideoWorkspaceKey];
    _workspaceViewController.adjustsCanvasViewFrameOnKeyboardAppearance = YES;
    _workspaceViewController.continueText = [self localizedEditingFinishedText];
    _workspaceViewController.continueButtonEnabled = YES;
    _workspaceViewController.previewImage = self.previewImage;
    _workspaceViewController.mediaURL = self.renderedMediaURL;
    
    __weak typeof(self) welf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        if (finished)
        {
            welf.renderedMediaURL = renderedMediaURL;
            welf.previewImage = previewImage;
            [welf afterEditingFinished];
        }
        else
        {
            [welf popViewControllerAnimated:YES];
        }
    };
}


- (void)afterEditingFinished
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        if ( [self.creationFlowDelegate shouldShowPublishScreenForFlowController])
        {
            [self pushPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                           previewImage:self.previewImage
                                          fromWorkspace:self.workspaceViewController];
        }
        else
        {
            [self.creationFlowDelegate creationFLowController:self
                                     finishedWithPreviewImage:self.previewImage
                                             capturedMediaURL:self.renderedMediaURL];
        }
    }
    else
    {
        [self pushPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                       previewImage:self.previewImage
                                      fromWorkspace:self.workspaceViewController];
    }
}

- (void)pushPublishScreenWithRenderedMediaURL:(NSURL *)renderedMediaURL
                                 previewImage:(UIImage *)previewImage
                                fromWorkspace:(VWorkspaceViewController *)workspace
{
    VPublishParameters *publishParameters = [[VPublishParameters alloc] init];
    publishParameters.mediaToUploadURL = renderedMediaURL;
    publishParameters.previewImage = previewImage;
    
    //    VVideoToolController *videoToolController = (VVideoToolController *)workspace.toolController;
    publishParameters.isGIF = NO;
    publishParameters.isVideo = YES;
    
    self.publishViewContorller.publishParameters = publishParameters;
    [self pushViewController:self.publishViewContorller animated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:[VPublishViewController class]] || [fromVC isKindOfClass:[VPublishViewController class]])
    {
        BOOL pushing = (operation == UINavigationControllerOperationPush);
        self.publishAnimator.presenting = pushing;
        
        return self.publishAnimator;
    }
    return nil;
}

@end
