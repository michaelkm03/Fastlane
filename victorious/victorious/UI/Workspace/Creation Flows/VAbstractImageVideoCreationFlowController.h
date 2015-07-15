//
//  VImageCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"
#import "VCameraContext.h"

extern NSString * const VImageCreationFlowControllerKey;

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
@property (nonatomic, assign) VWorkspaceFlowControllerContext context;

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

- (VAssetCollectionListViewController *)listViewController;

- (VAssetCollectionGridViewController *)gridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

- (VWorkspaceViewController *)workspaceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace;

- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace;

- (VAssetDownloader *)downloaderWithAsset:(PHAsset *)asset;

@end
