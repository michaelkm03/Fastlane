//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowController.h"

// Capture
#import "VAssetCollectionGridViewController.h"
#import "VImageAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VImageCameraViewController.h"
#import "VImageSearchViewController.h"

// Animator
#import "VCameraToWorkspaceAnimator.h"

// Edit
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"

// Publish
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

// Keys
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";

@interface VImageCreationFlowController () <VImageCameraViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VImageCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        [self setContext:VCameraContextImageContentCreation];
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (VAssetCollectionGridViewController *)gridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [dependencyManager templateValueOfType:[VAssetCollectionGridViewController class]
                                           forKey:kImageVideoLibrary
                            withAddedDependencies:@{VAssetCollectionGridViewControllerMediaType:@(PHAssetMediaTypeImage)}];
}

- (VWorkspaceViewController *)workspaceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
}

- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace
{
    VImageToolController *toolController = (VImageToolController *)workspace.toolController;
    NSNumber *shouldDisableText = [self.dependencyManager numberForKey:VImageToolControllerShouldDisableTextOverlayKey];
    NSNumber *defaultTool = [self.dependencyManager numberForKey:VImageToolControllerInitialImageEditStateKey];
    
    // Disable text
    if ([shouldDisableText boolValue])
    {
        toolController.disableTextOverlay = YES;
    }
    
    // Configure default tool
    if (defaultTool == nil && [shouldDisableText boolValue])
    {
        [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateFilter];
    }
    else if (defaultTool == nil)
    {
        [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
    }
    else
    {
        [toolController setDefaultImageTool:[defaultTool integerValue]];
    }
}

- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace
{
    VImageToolController *imageToolController = (VImageToolController *)workspace.toolController;
    publishParameters.embeddedText = imageToolController.embeddedText;
    publishParameters.textToolType = imageToolController.textToolType;
    publishParameters.filterName = imageToolController.filterName;
    publishParameters.didCrop = imageToolController.didCrop;
    publishParameters.isVideo = NO;
}

- (VAssetDownloader *)downloaderWithAsset:(PHAsset *)asset
{
    return [[VImageAssetDownloader alloc] initWithAsset:asset];
}

- (NSArray *)alternateCaptureOptions
{
    __weak typeof(self) welf = self;
    void (^cameraSelectionBlock)() = ^void()
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf showCamera];
    };
    
    void (^searchSelectionBlock)() = ^void()
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf showSearch];
    };
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                         andSelectionBlock:cameraSelectionBlock];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_searchbaricon"]
                                                                         andSelectionBlock:searchSelectionBlock];
    return @[cameraOption, searchOption];
}

- (void)showCamera
{
    // Camera
    VImageCameraViewController *cameraViewController = [VImageCameraViewController imageCameraWithDependencyManager:self.dependencyManager
                                                                                                      cameraContext:self.context];
    cameraViewController.delegate = self;
    [self pushViewController:cameraViewController animated:YES];
}

- (void)showSearch
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSelectImageSearch];
    
    // Image search
    VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewControllerWithDependencyManager:self.dependencyManager];
    __weak typeof(self) welf = self;
    imageSearchViewController.imageSelectionHandler = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        __strong typeof(welf) strongSelf = welf;
        if (finished)
        {
            strongSelf.source = VCreationFlowSourceSearch;
            [strongSelf captureFinishedWithMediaURL:capturedMediaURL
                                       previewImage:previewImage];
        }
    };
    [self pushViewController:imageSearchViewController
                    animated:YES];
}

#pragma mark - VImageCameraViewControllerDelegate

- (void)imageCameraViewController:(VImageCameraViewController *)imageCamera
        capturedImageWithMediaURL:(NSURL *)mediaURL
                     previewImage:(UIImage *)previewImage
{
    // We only care if image camera is still top of the stack
    if ([self.viewControllers lastObject] == imageCamera)
    {
        self.source = VCreationFlowSourceCamera;
        [self captureFinishedWithMediaURL:mediaURL
                             previewImage:previewImage];
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ([fromVC isKindOfClass:[VImageCameraViewController class]] && [toVC isKindOfClass:[VWorkspaceViewController class]])
    {
        return [[VCameraToWorkspaceAnimator alloc] init];
    }
    
    if ([[self superclass] instancesRespondToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [super navigationController:navigationController
           animationControllerForOperation:operation
                        fromViewController:fromVC
                          toViewController:toVC];
    }
    
    return nil;
}

@end
