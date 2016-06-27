//
//  VGIFCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "victorious-Swift.h"
#import "VGIFCreationFlowController.h"
#import "VAssetCollectionGridViewController.h"
#import "VVideoAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VVideoCameraViewController.h"
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"
#import "VPublishParameters.h"
#import "VDependencyManager.h"

@import Photos;

NSString * const VGIFCreationFlowControllerKey = @"gifCreateFlow";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";
static NSString * const kGifWorkspaceKey = @"gifWorkspace";

@interface VGIFCreationFlowController () <MediaSearchDelegate, VVideoCameraViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) MediaSearchViewController *mediaSearchViewController;

@end

@implementation VGIFCreationFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        [self setContext:VCameraContextVideoContentCreation];
        _dependencyManager = dependencyManager;
		
		id<MediaSearchDataSource> dataSource = [[GIFSearchDataSource alloc] init];
        _mediaSearchViewController = [MediaSearchViewController mediaSearchViewControllerWithDataSource:dataSource
                                                                                      dependencyManager:dependencyManager];
        _mediaSearchViewController.delegate = self;
    }
    return self;
}

- (UIViewController *)initialViewController
{
    return self.mediaSearchViewController;
}

- (MediaType)mediaType
{
    return MediaTypeVideo;
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
    
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    VVideoCameraViewController *videoCamera = [VVideoCameraViewController videoCameraWithDependencyManager:self.dependencyManager
                                                                                             cameraContext:self.context];
    videoCamera.delegate = self;
    if ( videoCamera != nil )
    {
        VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                          icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                             andSelectionBlock:^void()
                                                 {
                                                     __strong typeof(welf) strongSelf = welf;
                                                     [strongSelf showCamera];
                                                 }];
        [options addObject:cameraOption];
    }
    
    if ( self.gridViewController != nil )
    {
        VAlternateCaptureOption *galleryOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Gallery", nil)
                                                                                           icon:[UIImage imageNamed:@"contententry_galleryicon"]
                                                                              andSelectionBlock:^void()
                                                  {
                                                      __strong typeof(welf) strongSelf = welf;
                                                      [strongSelf pushViewController:strongSelf.gridViewController animated:YES];
                                                  }];
        [options addObject:galleryOption];
    }
    
    return [options copy];
}

- (void)showCamera
{
    // Camera
    VVideoCameraViewController *videoCamera = [VVideoCameraViewController videoCameraWithDependencyManager:self.dependencyManager
                                                                                             cameraContext:self.context];
    videoCamera.delegate = self;
    [self pushViewController:videoCamera animated:YES];
}

#pragma mark - MediaSearchDelegate

- (void)mediaSearchResultSelected:(id<MediaSearchResult>)result
{
    self.source = VCreationFlowSourceSearch;
    self.publishParameters.width = result.assetSize.width;
    self.publishParameters.height = result.assetSize.height;
    self.publishParameters.assetRemoteId = result.remoteID;
    self.publishParameters.source = @"giphy";
    [self captureFinishedWithMediaURL:result.exportMediaURL
                         previewImage:result.exportPreviewImage shouldSkipTrimmer:YES];
}

#pragma mark - VVideoCameraViewControllerDelegate

- (void)videoCameraViewController:(VVideoCameraViewController *)videoCamera
           capturedVideoAtFileURL:(NSURL *)url
                     previewImage:(UIImage *)previewImage
{
    // We only care if it's the top of the stack
    if ([self.viewControllers lastObject] == videoCamera)
    {
        self.source = VCreationFlowSourceCamera;
        self.publishParameters.assetRemoteId = nil;
        [self captureFinishedWithMediaURL:url
                             previewImage:previewImage];
    }
}

@end
