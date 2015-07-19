//
//  VImageCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"
#import "VCreationTypes.h"

@interface VAbstractImageVideoCreationFlowController : VCreationFlowController

/**
 *  To force this image creation flow controller into remixing mode provide it with a previewImage 
 *  and mediaURL to use for remixing.
 */
- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL;

/**
 *  The context for image creation. Defualts to contentCreation.
 */
@property (nonatomic, assign) VCameraContext context;

/**
 *  To prgoress from capturing to editing call this method. Useful for subclasses to call for alternate capture options.
 */
- (void)captureFinishedWithMediaURL:(NSURL *)mediaURL
                       previewImage:(UIImage *)previewImage;

@end

@class VAssetCollectionListViewController;
@class VAssetCollectionGridViewController;
@class VWorkspaceViewController;
@class VPublishParameters;
@class VAssetDownloader;
@class PHAsset;

/**
 *  Methods in this category must be overridden by subclasses.
 */
@interface VAbstractImageVideoCreationFlowController (Subclassing)

/**
 *  Provide a gridViewController to display the currently selected asset collection with.
 */
- (VAssetCollectionGridViewController *)gridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Provide a properly configured workspace to the parent class.
 */
- (VWorkspaceViewController *)workspaceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Do any work to prepare the workspace for editing (Such as selecting a default tool).
 */
- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace;

/**
 *  Using the workspace, configure the publish paramaters based on the actions taken.
 */
- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace;

/**
 *  Provide the superclass with a downloader to grab the asset from the photos framework.
 */
- (VAssetDownloader *)downloaderWithAsset:(PHAsset *)asset;

/**
 *  Must return an array (or empty array) of VAlternateCaptureOptions.
 */
- (NSArray *)alternateCaptureOptions;

@end
