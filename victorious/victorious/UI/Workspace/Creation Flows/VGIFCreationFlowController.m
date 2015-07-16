//
//  VGIFCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFCreationFlowController.h"

// Capture
#import "VAssetCollectionListViewController.h"
#import "VAssetCollectionGridViewController.h"
#import "VVideoAssetDownloader.h"

// Edit
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"

// Publish
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;

static NSString * const kImageVideoLibrary = @"imageVideoLibrary";
static NSString * const kGifWorkspaceKey = @"gifWorkspace";

@implementation VGIFCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        [self setContext:VCameraContextVideoContentCreation];
    }
    return self;
}

- (VAssetCollectionListViewController *)collectionListViewController
{
    return [VAssetCollectionListViewController assetCollectionListViewControllerWithMediaType:PHAssetMediaTypeVideo];
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

@end
