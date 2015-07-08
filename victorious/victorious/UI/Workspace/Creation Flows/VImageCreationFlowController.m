//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetGridViewController.h"
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"
#import "VPublishViewController.h"

// Publishing
#import "VPublishParameters.h"

// Animators
#import "VPublishBlurOverAnimator.h"

// Dependencies
#import "VDependencyManager.h"
#import "VMediaSource.h"

// Keys
NSString * const VCreationFLowCaptureScreenKey = @"captureScreen";
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";

@interface VImageCreationFlowController () <UINavigationControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishViewController *publishViewContorller;
@property (nonatomic, strong) VPublishBlurOverAnimator *publishAnimator;

@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VImageCreationFlowController

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
        
        VAssetGridViewController *gridViewController = [VAssetGridViewController assetGridViewController];
        
        [captureContainer setContainedViewController:gridViewController];
        [self addCompleitonHandlerToMediaSource:gridViewController];
        [self setupPublishScreen];
    }
    return self;
}

#pragma mark -  Public Methods

- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL
{
    [self setupWorkspace];
    self.workspaceViewController.mediaURL = mediaURL;
    self.workspaceViewController.previewImage = previewImage;
    [self addCloseButtonToViewController:self.workspaceViewController];
    self.viewControllers = @[self.workspaceViewController];
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
    void (^cameraSelectionBlock)() = ^void()
    {
        // Camera
        VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotosWithDependencyManager:self.dependencyManager];
        cameraViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMeidaURL)
        {
            if (finished)
            {
                [self pushWorkspaceWithMediaURL:capturedMeidaURL
                                andPreviewImage:previewImage];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        // Wrapped in nav
        UINavigationController *cameraNavController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
        [self presentViewController:cameraNavController animated:YES completion:nil];
    };
    
    void (^searchSelectionBlock)() = ^void()
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSelectImageSearch];
        
        // Image search
        VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewController];
        imageSearchViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
        {
            if (finished)
            {
                [self pushWorkspaceWithMediaURL:capturedMediaURL andPreviewImage:previewImage];
            }
            
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        [self presentViewController:imageSearchViewController
                           animated:YES
                         completion:nil];
    };
    
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:cameraSelectionBlock];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:searchSelectionBlock];
    return @[cameraOption, searchOption];
}

- (void)pushWorkspaceWithMediaURL:(NSURL *)mediaURL
                  andPreviewImage:(UIImage *)previewImage
{
    [self setupWorkspace];
    self.workspaceViewController.previewImage = previewImage;
    self.workspaceViewController.mediaURL = mediaURL;
    VImageToolController *toolController = (VImageToolController *)self.workspaceViewController.toolController;
    [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
    [self pushViewController:self.workspaceViewController animated:YES];
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

            VImageToolController *toolController = (VImageToolController *)welf.workspaceViewController.toolController;
            [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];

            [self pushViewController:self.workspaceViewController animated:YES];
        }
        else
        {
#warning Add some error handling here
        }
    };
}

- (void)setupWorkspace
{
    _workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
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

    VImageToolController *imageToolController = (VImageToolController *)workspace.toolController;
    publishParameters.embeddedText = imageToolController.embeddedText;
    publishParameters.textToolType = imageToolController.textToolType;
    publishParameters.filterName = imageToolController.filterName;
    publishParameters.didCrop = imageToolController.didCrop;
    publishParameters.isVideo = NO;

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
