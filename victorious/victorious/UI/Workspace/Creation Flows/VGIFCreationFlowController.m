//
//  VGIFCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFCreationFlowController.h"

// Capture
#import "VAssetCollectionGridViewController.h"
#import "VVideoAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VCameraViewController.h"

// Edit
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"

// Publish
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;

NSString * const VGIFCreationFlowControllerKey = @"gifCreateFlow";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";
static NSString * const kGifWorkspaceKey = @"gifWorkspace";

@interface VGIFCreationFlowController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VGIFCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        [self setContext:VCameraContextVideoContentCreation];
    }
    return self;
}

- (VAssetCollectionGridViewController *)gridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [dependencyManager templateValueOfType:[VAssetCollectionGridViewController class]
                                           forKey:kImageVideoLibrary
                            withAddedDependencies:@{VAssetCollectionGridViewControllerMediaType:@(PHAssetMediaTypeVideo)}];
}

- (VWorkspaceViewController *)workspaceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VWorkspaceViewController *gifWorkspace = [dependencyManager templateValueOfType:[VWorkspaceViewController class]
                                                                             forKey:kGifWorkspaceKey
                                                              withAddedDependencies:@{VVideoToolControllerInitalVideoEditStateKey:@(VVideoToolControllerInitialVideoEditStateGIF)}];

    return gifWorkspace;
}

- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace
{
    // do nothing for videos
}

- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace
{
    VVideoToolController *videoToolController = (VVideoToolController *)workspace.toolController;
    publishParameters.didTrim = videoToolController.didTrim;
    publishParameters.isGIF = YES;
}

- (VAssetDownloader *)downloaderWithAsset:(PHAsset *)asset
{
    return [[VVideoAssetDownloader alloc] initWithAsset:asset];
}


- (NSArray *)alternateCaptureOptions
{
    __weak typeof(self) welf = self;
    void (^cameraSelectionBlock)() = ^void()
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf showCamera];
    };
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                         andSelectionBlock:cameraSelectionBlock];
    
    return @[cameraOption];
}

- (void)showCamera
{
    // Camera
    __weak typeof(self) welf = self;
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerWithContext:self.context
                                                                                       dependencyManager:self.dependencyManager
                                                                                           resultHanlder:^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
                                                   {
                                                       __strong typeof(welf) strongSelf = welf;
                                                       if (finished)
                                                       {
                                                           [strongSelf captureFinishedWithMediaURL:capturedMediaURL
                                                                                      previewImage:previewImage];
                                                       }
                                                       
                                                       [strongSelf dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    // Wrapped in nav
    UINavigationController *cameraNavController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:cameraNavController animated:YES completion:nil];
}

@end
