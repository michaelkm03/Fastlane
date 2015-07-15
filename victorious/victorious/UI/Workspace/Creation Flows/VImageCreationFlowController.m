//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowController.h"

// Capture
#import "VAssetCollectionListViewController.h"
#import "VAssetCollectionGridViewController.h"
#import "VImageAssetDownloader.h"

// Edit
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"

// Publish
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

static NSString * const kImageVideoLibrary = @"imageVideoLibrary";

@implementation VImageCreationFlowController

- (VAssetCollectionListViewController *)collectionListViewController
{
    return [VAssetCollectionListViewController assetCollectionListViewControllerWithMediaType:PHAssetMediaTypeImage];
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
    [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
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

@end
