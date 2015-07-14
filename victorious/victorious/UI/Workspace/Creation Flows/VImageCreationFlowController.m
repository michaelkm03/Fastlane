//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetCollectionGridViewController.h"
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"
#import "VAssetCollectionListViewController.h"
#import "VImageAssetDownlaoder.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"
#import "VPublishViewController.h"

// Publishing
#import "VPublishParameters.h"

// Animators
#import "VPublishBlurOverAnimator.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;
#import <MBProgressHUD/MBProgressHUD.h>

// Keys
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";
static NSString * const kImageVideoLibrary = @"imageVideoLibrary";

@interface VImageCreationFlowController () <UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSArray *cachedAssetCollections;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VAssetCollectionListViewController *listViewController;
@property (nonatomic, strong) VAssetCollectionGridViewController *gridViewController;
@property (nonatomic, strong) VImageAssetDownlaoder *downloader;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishViewController *publishViewContorller;
@property (nonatomic, strong) VPublishBlurOverAnimator *publishAnimator;

// These come from the workspace not capture
@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VImageCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        
        _context = VCameraContextContentCreation;
        VCaptureContainerViewController *captureContainer = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        [captureContainer setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:captureContainer];
        [self setViewControllers:@[captureContainer]];
        
        _listViewController = [VAssetCollectionListViewController assetCollectionListViewControllerWithMediaType:PHAssetMediaTypeImage];
        _gridViewController = [self.dependencyManager templateValueOfType:[VAssetCollectionGridViewController class]
                                                                   forKey:kImageVideoLibrary
                                                    withAddedDependencies:@{VAssetCollectionGridViewControllerMediaType:@(PHAssetMediaTypeImage)}];
        _gridViewController.collectionToDisplay = [self defaultCollection];
        [captureContainer setContainedViewController:_gridViewController];
        [self setupPublishScreen];
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
    
    // Present the collections list when the user selects the folder button
    __weak typeof(self) welf = self;
    self.gridViewController.alternateFolderSelectionHandler = ^()
    {
        [welf presentAssetFoldersList];
    };
    self.gridViewController.assetSelectionHandler = ^(PHAsset *selectedAsset)
    {
        MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:welf.view animated:YES];
        hudForView.mode = MBProgressHUDModeAnnularDeterminate;
        welf.downloader = [[VImageAssetDownlaoder alloc] initWithImageAsset:selectedAsset];
        [welf.downloader downloadWithProgress:^(double progress)
         {
             hudForView.progress = progress;
         }
                                   completion:^(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage)
         {
             [hudForView hide:YES];
             [welf prepareWorkspaceWithMediaURL:downloadedFileURL
                             andPreviewImage:previewImage];
             [welf pushViewController:welf.workspaceViewController
                             animated:YES];
         }];
    };
    
    // On authorization is called immediately if we have already determined authorization status
    __weak VAssetCollectionListViewController *weakListViewController = _listViewController;
    __weak VAssetCollectionGridViewController *weakGridViewController = _gridViewController;
    _gridViewController.onAuthorizationHandler = ^void(BOOL authorized)
    {
        [weakListViewController fetchDefaultCollectionWithCompletion:^(PHAssetCollection *collection)
         {
             weakGridViewController.collectionToDisplay = collection;
         }];
    };
}

#pragma mark - Private Methods

- (PHAssetCollection *)defaultCollection
{
    return nil;
}

- (void)presentAssetFoldersList
{
    // Present alternate folder
    __weak typeof(self) welf = self;
    self.listViewController.collectionSelectionHandler = ^void(PHAssetCollection *assetCollection)
    {
        welf.gridViewController.collectionToDisplay = assetCollection;
    };
    self.listViewController.modalPresentationStyle = UIModalPresentationPopover;

    UIPopoverPresentationController *popoverPresentation = self.listViewController.popoverPresentationController;
    popoverPresentation.delegate = self;
    CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                             CGRectGetHeight(self.view.bounds) - 200.0f);
    self.listViewController.preferredContentSize = preferredContentSize;
    popoverPresentation.sourceView = self.navigationBar;
    popoverPresentation.sourceRect = CGRectMake(CGRectGetMidX(self.navigationBar.bounds),
                                                CGRectGetMaxY(self.navigationBar.bounds),
                                                0.0f, 0.0f);

    [self presentViewController:self.listViewController animated:YES completion:nil];
}

- (NSArray *)alternateCaptureOptions
{
    void (^cameraSelectionBlock)() = ^void()
    {
        // Camera
        VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotosWithDependencyManager:self.dependencyManager];
        [cameraViewController hideSearchAndAlbumButtons];
        cameraViewController.context = self.context;
        cameraViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMeidaURL)
        {
            if (finished)
            {
                [self prepareWorkspaceWithMediaURL:capturedMeidaURL
                                   andPreviewImage:previewImage];
                [self pushViewController:self.workspaceViewController animated:YES];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        // Wrapped in nav
        UINavigationController *cameraNavController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
        [self presentViewController:cameraNavController animated:YES completion:nil];
    };
    
    void (^searchSelectionBlock)() = ^void()
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
    };
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_cameraicon"]
                                                                         andSelectionBlock:cameraSelectionBlock];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@"contententry_searchbaricon"]
                                                                         andSelectionBlock:searchSelectionBlock];
    return @[cameraOption, searchOption];
}

- (void)prepareWorkspaceWithMediaURL:(NSURL *)mediaURL
                     andPreviewImage:(UIImage *)previewImage
{
    [self setupWorkspace];
    self.workspaceViewController.previewImage = previewImage;
    self.workspaceViewController.mediaURL = mediaURL;
    VImageToolController *toolController = (VImageToolController *)self.workspaceViewController.toolController;
    [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
}

- (void)setupWorkspace
{
    _workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
    _workspaceViewController.adjustsCanvasViewFrameOnKeyboardAppearance = YES;
    _workspaceViewController.continueText = [self localizedEditingFinishedText];
    _workspaceViewController.continueButtonEnabled = YES;
    _workspaceViewController.previewImage = self.previewImage;
    _workspaceViewController.mediaURL = self.renderedMediaURL;
    
    __weak typeof(self) welf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        if (finished)
        {
            welf.renderedMediaURL = renderedMediaURL;
            welf.previewImage = previewImage;
            [welf afterEditingFinished];
        }
        else
        {
            [welf popViewControllerAnimated:YES];
        }
    };
}

- (void)setupPublishScreen
{
    _publishAnimator = [[VPublishBlurOverAnimator alloc] init];
    _publishViewContorller = [self.dependencyManager newPublishViewController];

    __weak typeof(self) welf = self;
    _publishViewContorller.completion = ^void(BOOL published)
    {
        if (published)
        {
            welf.delegate = nil;
            // We're done!
            [welf.creationFlowDelegate creationFLowController:welf
                                     finishedWithPreviewImage:welf.previewImage
                                             capturedMediaURL:welf.renderedMediaURL];
        }
        else
        {
            // Cancelled
            [welf popViewControllerAnimated:YES];
        }
    };
}

- (void)afterEditingFinished
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        if ( [self.creationFlowDelegate shouldShowPublishScreenForFlowController])
        {
            [self pushPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                           previewImage:self.previewImage
                                          fromWorkspace:self.workspaceViewController];
        }
        else
        {
            [self.creationFlowDelegate creationFLowController:self
                                     finishedWithPreviewImage:self.previewImage
                                             capturedMediaURL:self.renderedMediaURL];
        }
    }
    else
    {
        [self pushPublishScreenWithRenderedMediaURL:self.renderedMediaURL
                                       previewImage:self.previewImage
                                      fromWorkspace:self.workspaceViewController];
    }
}

- (void)pushPublishScreenWithRenderedMediaURL:(NSURL *)renderedMediaURL
                                 previewImage:(UIImage *)previewImage
                                fromWorkspace:(VWorkspaceViewController *)workspace
{
    VPublishParameters *publishParameters = [[VPublishParameters alloc] init];
    publishParameters.mediaToUploadURL = renderedMediaURL;
    publishParameters.previewImage = previewImage;

    VImageToolController *imageToolController = (VImageToolController *)workspace.toolController;
    publishParameters.embeddedText = imageToolController.embeddedText;
    publishParameters.textToolType = imageToolController.textToolType;
    publishParameters.filterName = imageToolController.filterName;
    publishParameters.didCrop = imageToolController.didCrop;
    publishParameters.isVideo = NO;

    self.publishViewContorller.publishParameters = publishParameters;
    [self pushViewController:self.publishViewContorller animated:YES];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([toVC isKindOfClass:[VPublishViewController class]] || [fromVC isKindOfClass:[VPublishViewController class]])
    {
        BOOL pushing = (operation == UINavigationControllerOperationPush);
        self.publishAnimator.presenting = pushing;
        
        return self.publishAnimator;
    }
    return nil;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

@end
