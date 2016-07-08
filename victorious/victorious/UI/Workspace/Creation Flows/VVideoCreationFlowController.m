//
//  VVideoCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCreationFlowController.h"
#import "VAssetCollectionGridViewController.h"
#import "VVideoAssetDownloader.h"
#import "VAlternateCaptureOption.h"
#import "VVideoCameraViewController.h"
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"
#import "VPublishParameters.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"

@import Photos;

// Keys
NSString * const VVideoCreationFlowControllerKey = @"videoCreateFlow";
static NSString * const kVideoWorkspaceKey = @"videoWorkspace";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";

static Float64 const kMaxVideoLengthForEditing = 15.0f;

@interface VVideoCreationFlowController () <VVideoCameraViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VVideoCameraViewController *videoCameraViewController;
@property (nonatomic, assign) Float64 currentVideoLength;

@end

@implementation VVideoCreationFlowController

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
    return [dependencyManager templateValueOfType:[VWorkspaceViewController class]
                                           forKey:kVideoWorkspaceKey
                            withAddedDependencies:@{VVideoToolControllerInitalVideoEditStateKey:@(VVideoToolControllerInitialVideoEditStateVideo)}];
}

- (void)configurePublishParameters:(VPublishParameters *)publishParameters
                     withWorkspace:(VWorkspaceViewController *)workspace
{
    VVideoToolController *videoToolController = (VVideoToolController *)workspace.toolController;
    publishParameters.didTrim = videoToolController.didTrim;
    publishParameters.isGIF = NO;
    publishParameters.isVideo = YES;
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
    [self pushViewController:self.videoCameraViewController
                    animated:YES];
}

- (VVideoCameraViewController *)videoCameraViewController
{
    if (_videoCameraViewController == nil)
    {
        _videoCameraViewController = [VVideoCameraViewController videoCameraWithDependencyManager:self.dependencyManager
                                                                                    cameraContext:self.context];
        _videoCameraViewController.delegate = self;
    }
    
    return _videoCameraViewController;
}

- (BOOL)shouldSkipTrimmerForVideoLength
{
    if ([VCurrentUser user].isCreator.boolValue)
    {
        return self.currentVideoLength > kMaxVideoLengthForEditing;
    }
    else
    {
        return NO;
    }
}

- (MediaType)mediaType
{
    return MediaTypeVideo;
}

#pragma mark - VAssetCollectionGridViewControllerDelegate

- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController selectedAsset:(PHAsset *)asset
{
    [super gridViewController:gridViewController selectedAsset:asset];
    self.currentVideoLength = asset.duration;
}

#pragma mark - VVideoCameraViewControllerDelegate

- (void)videoCameraViewController:(VVideoCameraViewController *)videoCamera
           capturedVideoAtFileURL:(NSURL *)url
                     previewImage:(UIImage *)previewImage
{
    // We only care if it's the top of the stack.
    if ([self.viewControllers lastObject] == videoCamera)
    {
        self.source = VCreationFlowSourceCamera;
        self.currentVideoLength = videoCamera.totalTimeRecorded;
        [self captureFinishedWithMediaURL:url
                             previewImage:previewImage];
    }
}

@end
