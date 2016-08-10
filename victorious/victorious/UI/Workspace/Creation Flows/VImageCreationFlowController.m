//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "victorious-Swift.h"
#import "VImageCreationFlowController.h"
#import "VAssetCollectionGridViewController.h"
#import "VImageAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VImageCameraViewController.h"
#import "VCameraToWorkspaceAnimator.h"
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"
#import "VPublishParameters.h"
#import "VDependencyManager.h"
#import "VAppInfo.h"

// Keys
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";
NSString * const VImageCreationFlowControllerDefaultSearchTermKey = @"defaultSearchTerm";

@interface VImageCreationFlowController () <VImageCameraViewControllerDelegate>

@end

@implementation VImageCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        [self setContext:VCameraContextImageContentCreation];
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
    if (defaultTool == nil || [shouldDisableText boolValue])
    {
        [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateFilter];
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
	VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
																					  icon:[UIImage imageNamed:@"contententry_cameraicon"]
																		 andSelectionBlock:^void()
											 {
												 __strong typeof(welf) strongSelf = welf;
												 [strongSelf showCamera];
											 }];
	return @[cameraOption];
}

- (MediaType)mediaType
{
    return MediaTypeImage;
}

- (void)showCamera
{
    // Camera
    VImageCameraViewController *cameraViewController = [VImageCameraViewController imageCameraWithDependencyManager:self.dependencyManager
                                                                                                      cameraContext:self.context];
    cameraViewController.delegate = self;
    [self pushViewController:cameraViewController animated:YES];
}

#pragma mark - MediaSearchDelegate

- (void)mediaSearchResultSelected:(id<MediaSearchResult>)result
{
	[self captureFinishedWithMediaURL:result.exportMediaURL
						 previewImage:result.exportPreviewImage];
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
