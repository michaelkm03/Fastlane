//
//  VGIFCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "victorious-Swift.h"

#import "VGIFCreationFlowController.h"

// Capture
#import "VAssetCollectionGridViewController.h"
#import "VVideoAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VVideoCameraViewController.h"

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

@interface VGIFCreationFlowController () <GIFSearchViewControllerDelegate, VVideoCameraViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) GIFSearchViewController *gifSearchViewController;
@property (nonatomic, strong) VAssetCollectionGridViewController *gridViewController;

@end

@implementation VGIFCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        [self setContext:VCameraContextVideoContentCreation];
        _dependencyManager = dependencyManager;
        
        _gridViewController = [self gridViewControllerWithDependencyManager:dependencyManager];
        _gridViewController.delegate = self;
        
        _gifSearchViewController = [GIFSearchViewController gifSearchWithDependencyManager:dependencyManager];
        _gifSearchViewController.delegate = self;
    }
    return self;
}

- (UIViewController *)initialViewController
{
    return self.gifSearchViewController;
}

- (VAssetCollectionGridViewController *)gridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [dependencyManager templateValueOfType:[VAssetCollectionGridViewController class]
                                           forKey:kImageVideoLibrary
                            withAddedDependencies:@{VAssetCollectionGridViewControllerMediaType:@(PHAssetMediaTypeVideo)}];
}

- (VWorkspaceViewController *)workspaceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [dependencyManager templateValueOfType:[VWorkspaceViewController class]
                                           forKey:kGifWorkspaceKey
                            withAddedDependencies:@{VVideoToolControllerInitalVideoEditStateKey:@(VVideoToolControllerInitialVideoEditStateGIF)}];;
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
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                         andSelectionBlock:^void()
                                             {
                                                 __strong typeof(welf) strongSelf = welf;
                                                 [strongSelf showCamera];
                                             }];
    VAlternateCaptureOption *galleryOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Gallery", nil)
                                                                                       icon:[UIImage imageNamed:@"contententry_galleryicon"]
                                                                          andSelectionBlock:^void()
                                              {
                                                  __strong typeof(welf) strongSelf = welf;
                                                  [strongSelf pushViewController:strongSelf.gridViewController animated:YES];
                                              }];
    
    return @[ cameraOption, galleryOption ];
}

- (void)showCamera
{
    // Camera
    VVideoCameraViewController *videoCamera = [VVideoCameraViewController videoCameraWithDependencyManager:self.dependencyManager
                                                                                             cameraContext:self.context];
    videoCamera.delegate = self;
    [self pushViewController:videoCamera animated:YES];
}

#pragma mark - GIFSearchViewControllerDelegate

- (void)GIFSearchResultSelected:(SelectedGIFSearchResult *)result
{
    self.source = VCreationFlowSourceSearch;
    self.publishParameters.width = result.width;
    self.publishParameters.height = result.height;
    self.publishParameters.assetRemoteId = result.remoteID;
    [self captureFinishedWithMediaURL:result.mediaURL previewImage:result.previewImage shouldSkipTrimmer:YES];
}

#pragma mark - VVideoCameraViewControllerDelegate

- (void)videoCameraViewController:(VVideoCameraViewController *)videoCamera
           capturedVideoAtFileURL:(NSURL *)url
                     previewImage:(UIImage *)previewImage
{
    // We only care if it's the top of the stack
    if ([self.viewControllers lastObject] == videoCamera)
    {
        [self captureFinishedWithMediaURL:url
                             previewImage:previewImage];
    }
}

@end
