//
//  VAbstractImageVideoCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowController.h"
#import "VCreationTypes.h"
#import "VAssetCollectionGridViewController.h"

/*
 *  The media type that the CreationFlowController contains.
 */
typedef NS_ENUM (NSUInteger, MediaType) {
    MediaTypeImage,
    MediaTypeVideo,
    MediaTypeUnknown,
};

@interface VAbstractImageVideoCreationFlowController : VCreationFlowController <VAssetCollectionGridViewControllerDelegate, UINavigationControllerDelegate>

/**
 *  To force this image creation flow controller into remixing mode provide it with a previewImage 
 *  and mediaURL to use for remixing.
 */
- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL
                 parentNodeID:(NSNumber *)parentNodeID
             parentSequenceID:(NSString *)parentSequenceID;

/**
 *  The context for image creation. Defualts to contentCreation.
 */
@property (nonatomic, assign) VCameraContext context;

- (MediaType)mediaType; /// < returns MediaTypeUnknown. Subclasses should override

/**
 *  To progress from capturing to editing call this method. Useful for subclasses to call for alternate capture options.
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
 *  Do any work to prepare the workspace for editing (Such as selecting a default tool). Default implementation does nothing.
 */
- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace;

/**
 *  Using the workspace, configure the publish paramaters based on the actions taken.
 *  Does not skip the trimmer by default.
 */
- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace;

/**
 *  Using the workspace, configure the publish paramaters based on the actions taken.
 */
- (void)captureFinishedWithMediaURL:(NSURL *)mediaURL
                       previewImage:(UIImage *)previewImage
                  shouldSkipTrimmer:(BOOL)shouldSkipTrimmerForContext;

/**
 *  Provide the superclass with a downloader to grab the asset from the photos framework.
 */
- (VAssetDownloader *)downloaderWithAsset:(PHAsset *)asset;

/**
 *  Must return an array (or empty array) of VAlternateCaptureOptions.
 */
- (NSArray<VAlternateCaptureOption *> *)alternateCaptureOptions;

- (UIViewController *)initialViewController;

/**
 *  Determines whether trimmer should be skipped based on the length of current video. Default to NO.
 */
- (BOOL)shouldSkipTrimmerForVideoLength;

@property (nonatomic, strong, readonly) VAssetCollectionGridViewController *gridViewController;

@property (nonatomic, assign) BOOL shouldShowPublishScreen;

@property (nonatomic, strong, readonly) NSURL *capturedMediaURL;

- (void)toPublishScreenWithRenderedMediaURL:(NSURL *)renderedMediaURL
                               previewImage:(UIImage *)previewImage
                              fromWorkspace:(VWorkspaceViewController *)workspace;

- (void)setupPublishPresenter;

@end
