//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractImageVideoCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetCollectionGridViewController.h"
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"
#import "VAssetCollectionListViewController.h"
#import "VAssetDownloader.h"
#import "UIAlertController+VSimpleAlert.h"
#import "VCollectionListPresentationController.h"
#import "VFromTopViewControllerAnimator.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"

// Publishing
#import "VPublishPresenter.h"
#import "VPublishViewController.h"
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;
#import <MBProgressHUD/MBProgressHUD.h>

// Keys
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";

@interface VAbstractImageVideoCreationFlowController () <UINavigationControllerDelegate, VAssetCollectionGridViewControllerDelegate>

@property (nonatomic, strong) NSArray *cachedAssetCollections;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VCaptureContainerViewController *captureContainerViewController;
@property (nonatomic, strong) VAssetCollectionListViewController *listViewController;
@property (nonatomic, strong) VAssetCollectionGridViewController *gridViewController;
//@property (nonatomic, strong) VFromTopViewControllerAnimator *listAnimator;
@property (nonatomic, strong) VAssetDownloader *downloader;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishPresenter *publishPresenter;

// These come from the workspace not capture
@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VAbstractImageVideoCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        
        self.captureContainerViewController = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        [self.captureContainerViewController setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:self.captureContainerViewController];
        [self setViewControllers:@[self.captureContainerViewController]];
        
        _listViewController = [self collectionListViewController];
        _gridViewController = [self gridViewControllerWithDependencyManager:dependencyManager];
        _gridViewController.delegate = self;
        [self.captureContainerViewController setContainedViewController:_gridViewController];
    }
    return self;
}

#pragma mark -  Public Methods

- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL
{
    [self setupWorkspace];
    [self prepareWorkspaceWithMediaURL:mediaURL andPreviewImage:previewImage];
    [self addCloseButtonToViewController:self.workspaceViewController];
    self.viewControllers = @[self.workspaceViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // We need to be the delegate for the publish animation, and the gesture delegate for the pop to work
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

#pragma mark - Private Methods

- (void)presentAssetFoldersList
{
    // Present alternate folder
    __weak typeof(self) welf = self;
    self.listViewController.collectionSelectionHandler = ^void(PHAssetCollection *assetCollection)
    {
        welf.gridViewController.collectionToDisplay = assetCollection;
    };
    [self presentViewController:self.listViewController animated:YES completion:nil];
}

- (NSArray *)alternateCaptureOptions
{
    __weak typeof(self) welf = self;
    void (^cameraSelectionBlock)() = ^void()
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf showCamera];
    };
    
    void (^searchSelectionBlock)() = ^void()
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf showSearch];
    };
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                         andSelectionBlock:cameraSelectionBlock];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_searchbaricon"]
                                                                         andSelectionBlock:searchSelectionBlock];
    return @[cameraOption, searchOption];
}

- (void)showCamera
{
    // Camera
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerWithContext:self.context
                                                                                       dependencyManager:self.dependencyManager
                                                                                           resultHanlder:^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
                                                   {
                                                       if (finished)
                                                       {
                                                           [self prepareWorkspaceWithMediaURL:capturedMediaURL
                                                                              andPreviewImage:previewImage];
                                                           [self pushViewController:self.workspaceViewController animated:YES];
                                                       }
                                                       
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    // Wrapped in nav
    UINavigationController *cameraNavController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:cameraNavController animated:YES completion:nil];

}

- (void)showSearch
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSelectImageSearch];
    
    // Image search
    VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewController];
    imageSearchViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            [self prepareWorkspaceWithMediaURL:capturedMediaURL andPreviewImage:previewImage];
            [self pushViewController:self.workspaceViewController animated:YES];
        }
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    };
    [self presentViewController:imageSearchViewController
                       animated:YES
                     completion:nil];
}

- (void)prepareWorkspaceWithMediaURL:(NSURL *)mediaURL
                     andPreviewImage:(UIImage *)previewImage
{
    [self setupWorkspace];
    self.workspaceViewController.previewImage = previewImage;
    self.workspaceViewController.mediaURL = mediaURL;
    [self prepareInitialEditStateWithWorkspace:self.workspaceViewController];
}

- (void)setupWorkspace
{
    _workspaceViewController = [self workspaceViewControllerWithDependencyManager:self.dependencyManager];
    _workspaceViewController.adjustsCanvasViewFrameOnKeyboardAppearance = YES;
    _workspaceViewController.continueText = [self shouldShowPublishText] ? NSLocalizedString(@"Publish", @"") : NSLocalizedString(@"Next", @"");
    _workspaceViewController.continueButtonEnabled = YES;
    _workspaceViewController.previewImage = self.previewImage;
    _workspaceViewController.mediaURL = self.renderedMediaURL;
    
    __weak typeof(self) welf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        __strong typeof(welf) strongSelf = welf;
        if (finished)
        {
            strongSelf.renderedMediaURL = renderedMediaURL;
            strongSelf.previewImage = previewImage;
            [strongSelf afterEditingFinished];
        }
        else
        {
            [strongSelf popViewControllerAnimated:YES];
        }
    };
}

- (void)setupPublishPresenter
{
    self.publishPresenter = [[VPublishPresenter alloc] initWithDependencymanager:self.dependencyManager];

    __weak typeof(self) welf = self;
    self.publishPresenter.completion = ^void(BOOL published)
    {
        __strong typeof(welf) strongSelf = welf;
        if (published)
        {
            strongSelf.delegate = nil;
            strongSelf.interactivePopGestureRecognizer.delegate = nil;
            strongSelf.publishPresenter = nil;
            [strongSelf cleanupCapturedFile];
            [strongSelf cleanupRenderedFile];

            // We're done!
            [strongSelf.creationFlowDelegate creationFlowController:strongSelf
                                           finishedWithPreviewImage:strongSelf.previewImage
                                                   capturedMediaURL:strongSelf.renderedMediaURL];
        }
    };
}

- (void)afterEditingFinished
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        if ( [self.creationFlowDelegate shouldShowPublishScreenForFlowController])
        {
            [self toPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                         previewImage:self.previewImage
                                        fromWorkspace:self.workspaceViewController];
        }
        else
        {
            [self.creationFlowDelegate creationFlowController:self
                                     finishedWithPreviewImage:self.previewImage
                                             capturedMediaURL:self.renderedMediaURL];
        }
    }
    else
    {
        [self toPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                     previewImage:self.previewImage
                                    fromWorkspace:self.workspaceViewController];
    }
}

- (void)toPublishScreenWithRenderedMediaURL:(NSURL *)renderedMediaURL
                               previewImage:(UIImage *)previewImage
                              fromWorkspace:(VWorkspaceViewController *)workspace
{
    // Setup presenter
    [self setupPublishPresenter];
    
    // Configure parameters
    VPublishParameters *publishParameters = [[VPublishParameters alloc] init];
    publishParameters.mediaToUploadURL = renderedMediaURL;
    publishParameters.previewImage = previewImage;
    [self configurePublishParameters:publishParameters
                       withWorkspace:workspace];
    self.publishPresenter.publishParameters = publishParameters;

    [self.publishPresenter presentOnViewController:self];
}

- (void)cleanupCapturedFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.workspaceViewController.mediaURL
                                              error:nil];
}

- (void)cleanupRenderedFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.renderedMediaURL
                                              error:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Cleanup as we enter or exit different states
    if (viewController == self.captureContainerViewController)
    {
        [self cleanupCapturedFile];
    }
    if ([viewController isKindOfClass:[VWorkspaceViewController class]])
    {
        [self cleanupRenderedFile];
    }
}

#pragma mark - VAssetCollectionGridViewControllerDelegate

- (void)gridViewControllerWantsToViewAlternateCollections:(VAssetCollectionGridViewController *)gridViewController
{
    [self presentAssetFoldersList];
}

- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
             selectedAsset:(PHAsset *)asset
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudForView.mode = MBProgressHUDModeAnnularDeterminate;
    self.downloader = [self downloaderWithAsset:asset];
    __weak typeof(self) welf = self;
    [self.downloader downloadWithProgress:^(double progress, NSString *progressText)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             hudForView.progress = progress;
         });
     }
                               completion:^(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage)
     {
         __strong typeof(welf) strongSelf = welf;
         [hudForView hide:YES];
         if (error == nil)
         {
             [strongSelf prepareWorkspaceWithMediaURL:downloadedFileURL
                                      andPreviewImage:previewImage];
             [strongSelf pushViewController:strongSelf.workspaceViewController
                                   animated:YES];
         }
         else
         {
             UIAlertController *alert = [UIAlertController simpleAlertControllerWithTitle:NSLocalizedString(@"LibraryCaptureFailed", nil)
                                                                                  message:error.localizedDescription
                                                                     andCancelButtonTitle:NSLocalizedString(@"OK", nil)];
             [strongSelf presentViewController:alert animated:YES completion:nil];
         }
     }];
}

- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
       authorizationStatus:(BOOL)authorizedStatus
{
    __weak typeof(self) welf = self;
    [self.listViewController fetchDefaultCollectionWithCompletion:^(PHAssetCollection *collection)
     {
         __strong typeof(welf) strongSelf = welf;
         strongSelf.gridViewController.collectionToDisplay = collection;
     }];
}

@end
