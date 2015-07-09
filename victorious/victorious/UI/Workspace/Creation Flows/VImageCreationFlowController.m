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
#import "VAssetGridViewController.h"
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"
#import "VAssetCollectionListViewController.h"

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
#import "VMediaSource.h"

@import Photos;

// Keys
NSString * const VCreationFLowCaptureScreenKey = @"captureScreen";
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";

@interface VImageCreationFlowController () <UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSArray *cachedAssetCollections;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VAssetGridViewController *gridViewController;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishViewController *publishViewContorller;
@property (nonatomic, strong) VPublishBlurOverAnimator *publishAnimator;

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
        
        _context = VWorkspaceFlowControllerContextContentCreation;
        VCaptureContainerViewController *captureContainer = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        [captureContainer setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:captureContainer];
        [self setViewControllers:@[captureContainer]];
        
        self.gridViewController = [VAssetGridViewController assetGridViewController];
        self.gridViewController.collectionToDisplay = [self defaultCollection];
        [captureContainer setContainedViewController:self.gridViewController];
        [self addCompleitonHandlerToMediaSource:self.gridViewController];
        [self setupPublishScreen];
    }
    return self;
}

#pragma mark -  Public Methods

- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL
{
    [self setupWorkspace];
    self.workspaceViewController.mediaURL = mediaURL;
    self.workspaceViewController.previewImage = previewImage;
    [self addCloseButtonToViewController:self.workspaceViewController];
    self.viewControllers = @[self.workspaceViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    __weak typeof(self) welf = self;
    self.gridViewController.alternateFolderSelectionHandler = ^()
    {
        [welf presentAssetFoldersList];
    };
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private Methods

- (PHAssetCollection *)defaultCollection
{
    return [[self assetCollections] firstObject];
}

- (void)presentAssetFoldersList
{
    // Present alternate folder
    VAssetCollectionListViewController *listVC = [VAssetCollectionListViewController assetCollectionListViewController];
    listVC.collectionSelectionHandler = ^void(PHAssetCollection *assetCollection)
    {
        self.gridViewController.collectionToDisplay = assetCollection;
    };
    listVC.assetCollections = [self assetCollections];
    listVC.modalPresentationStyle = UIModalPresentationPopover;

    UIPopoverPresentationController *popoverPresentation = listVC.popoverPresentationController;
    popoverPresentation.delegate = self;
    CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                             CGRectGetHeight(self.view.bounds) - 200.0f);
    listVC.preferredContentSize = preferredContentSize;
    UIViewController *topViewContorller = [self.viewControllers firstObject];
    popoverPresentation.sourceView = topViewContorller.navigationItem.titleView;
    popoverPresentation.sourceRect = CGRectMake(CGRectGetMidX(popoverPresentation.sourceView.bounds),
                                                CGRectGetMaxY(popoverPresentation.sourceView.bounds) + CGRectGetHeight(popoverPresentation.sourceView.bounds),
                                                0.0f,
                                                CGRectGetHeight(popoverPresentation.sourceView.bounds));

    [self presentViewController:listVC animated:YES completion:nil];
}

- (NSArray *)assetCollections
{
    if (self.cachedAssetCollections != nil)
    {
        return self.cachedAssetCollections;
    }
    
#warning cleanup this fetching and sorting. Pretty un-optimized
    
    // Fetch all albums
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:fetchOptions];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny
                                                                         options:fetchOptions];
    
    // Figure out Photos media type based on our media type
    PHAssetMediaType mediaType = PHAssetMediaTypeImage;
    PHFetchOptions *mediaTypeOptions = [[PHFetchOptions alloc] init];
    mediaTypeOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", mediaType];
    
    // Add collections to array if collection contains at least 1 asset of media type
    NSMutableArray *assetCollections = [[NSMutableArray alloc] init];
    for (PHAssetCollection *collection in smartAlbums)
    {
        PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                             options:mediaTypeOptions];
        if (albumMediaTypeResults.count > 0)
        {
            [assetCollections addObject:collection];
        }
    }
    for (PHAssetCollection *collection in userAlbums)
    {
        PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                             options:mediaTypeOptions];
        if (albumMediaTypeResults.count > 0)
        {
            [assetCollections addObject:collection];
        }
    }
    
    // Sort by count and store for later use
    self.cachedAssetCollections = [assetCollections sortedArrayUsingComparator:^NSComparisonResult(PHAssetCollection *collection1, PHAssetCollection *collection2)
                                   {
                                       PHFetchResult *albumMediaTypeResults1 = [PHAsset fetchAssetsInAssetCollection:collection1
                                                                                                             options:mediaTypeOptions];
                                       PHFetchResult *albumMediaTypeResults2 = [PHAsset fetchAssetsInAssetCollection:collection2
                                                                                                             options:mediaTypeOptions];
                                       if (albumMediaTypeResults1.count > albumMediaTypeResults2.count)
                                       {
                                           return NSOrderedAscending;
                                       }
                                       else if (albumMediaTypeResults2.count > albumMediaTypeResults1.count)
                                       {
                                           return NSOrderedDescending;
                                       }
                                       else
                                       {
                                           return NSOrderedSame;
                                       }
                                   }];
    return self.cachedAssetCollections;
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
                [self pushWorkspaceWithMediaURL:capturedMeidaURL
                                andPreviewImage:previewImage];
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
                [self pushWorkspaceWithMediaURL:capturedMediaURL andPreviewImage:previewImage];
            }
            
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        [self presentViewController:imageSearchViewController
                           animated:YES
                         completion:nil];
    };
    
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:cameraSelectionBlock];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:searchSelectionBlock];
    return @[cameraOption, searchOption];
}

- (void)pushWorkspaceWithMediaURL:(NSURL *)mediaURL
                  andPreviewImage:(UIImage *)previewImage
{
    [self setupWorkspace];
    self.workspaceViewController.previewImage = previewImage;
    self.workspaceViewController.mediaURL = mediaURL;
    VImageToolController *toolController = (VImageToolController *)self.workspaceViewController.toolController;
    [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
    [self pushViewController:self.workspaceViewController animated:YES];
}

- (void)addCompleitonHandlerToMediaSource:(id<VMediaSource>)mediaSource
{
    __weak typeof(self) welf = self;
    mediaSource.handler = ^void(UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (capturedMediaURL != nil)
        {
            [welf setupWorkspace];
            self.workspaceViewController.mediaURL = capturedMediaURL;
            self.workspaceViewController.previewImage = previewImage;

            VImageToolController *toolController = (VImageToolController *)welf.workspaceViewController.toolController;
            [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
            
            [self pushViewController:self.workspaceViewController animated:YES];
        }
    };
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
