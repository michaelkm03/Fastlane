//
//  VAbstractImageVideoCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractImageVideoCreationFlowController.h"

// Subclass
#import "VVideoCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetCollectionGridViewController.h"
#import "VAssetDownloader.h"
#import "UIAlertController+VSimpleAlert.h"
#import "VVideoCameraViewController.h"

// Animator Support
#import "VScaleAnimator.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"

// Publishing
#import "VPublishParameters.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;
#import <MBProgressHUD/MBProgressHUD.h>

#import "victorious-Swift.h"

// Sources
static NSString * const kCreationFlowSourceLibrary = @"library";
static NSString * const kCreationFlowSourceCamera = @"camera";
static NSString * const kCreationFlowSourceSearch = @"search";

@interface VAbstractImageVideoCreationFlowController () <VAssetCollectionGridViewControllerDelegate, VScaleAnimatorSource>

@property (nonatomic, strong) NSArray *cachedAssetCollections;

@property (nonatomic, strong) VCaptureContainerViewController *captureContainerViewController;
@property (nonatomic, strong, readwrite) VAssetCollectionGridViewController *gridViewController;
@property (nonatomic, strong) VAssetDownloader *downloader;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

// These come from the workspace not capture
@property (nonatomic, strong) NSURL *capturedMediaURL;
@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

// Remixing
@property (nonatomic, strong) NSNumber *parentNodeID;
@property (nonatomic, strong) NSString *parentSequenceID;

@end

@implementation VAbstractImageVideoCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _captureContainerViewController = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        
        _gridViewController = [self gridViewControllerWithDependencyManager:dependencyManager];
        _gridViewController.delegate = self;
    }
    return self;
}

- (UIViewController *)initialViewController
{
    return self.gridViewController;
}

#pragma mark -  Public Methods

- (void)remixWithPreviewImage:(UIImage *)previewImage
                     mediaURL:(NSURL *)mediaURL
                 parentNodeID:(NSNumber *)parentNodeID
             parentSequenceID:(NSString *)parentSequenceID
{
    self.parentNodeID = parentNodeID;
    self.parentSequenceID = parentSequenceID;
    [self prepareWorkspaceWithMediaURL:mediaURL andPreviewImage:previewImage];
    [self addCloseButtonToViewController:self.workspaceViewController];
    self.viewControllers = @[self.workspaceViewController];
}

- (void)prepareInitialEditStateWithWorkspace:(VWorkspaceViewController *)workspace
{
    //Itentionally empty
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.viewControllers.count == 0)
    {
        [self.captureContainerViewController setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:self.captureContainerViewController];
        [self setViewControllers:@[self.captureContainerViewController]];
    }
    
    [self.captureContainerViewController setContainedViewController:[self initialViewController]];
    
    // We need to be the delegate for the publish animation, and the gesture delegate for the pop to work
    self.delegate = self;
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

#pragma mark - Private Methods

- (NSString *)sourceStringForSourceType:(VCreationFlowSource)source
{
    switch (self.source)
    {
        case VCreationFlowSourceCamera:
            return kCreationFlowSourceCamera;
        case VCreationFlowSourceLibrary:
            return kCreationFlowSourceLibrary;
        case VCreationFlowSourceSearch:
            return kCreationFlowSourceSearch;
    }
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
    _workspaceViewController.creationFlowController = self;
    _workspaceViewController.adjustsCanvasViewFrameOnKeyboardAppearance = YES;
    _workspaceViewController.continueText = [self shouldShowPublishText] ? NSLocalizedString(@"Publish", @"") : NSLocalizedString(@"Next", @"");
    
    __weak typeof(self) welf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        [welf workspaceFinished:finished withPreviewImage:previewImage mediaURL:renderedMediaURL];
    };
}

- (void)workspaceFinished:(BOOL)finished withPreviewImage:(UIImage *)previewImage mediaURL:(NSURL *)mediaURL
{
    if (finished)
    {
        self.renderedMediaURL = mediaURL;
        self.previewImage = previewImage;
        [self afterEditingFinishedUseCapturedMediaURL:NO];
    }
    else
    {
        [self popViewControllerAnimated:YES];
    }
}

- (void)afterEditingFinishedUseCapturedMediaURL:(BOOL)shouldUseCapturedMediaURL
{
    // Configure parameters
    NSURL *mediaURL = shouldUseCapturedMediaURL ? self.capturedMediaURL : self.renderedMediaURL;
    self.publishParameters.previewImage = self.previewImage;
    self.publishParameters.mediaToUploadURL = mediaURL;
    [self configurePublishParameters:self.publishParameters
                       withWorkspace:self.workspaceViewController];
    
    if ([self.creationFlowDelegate respondsToSelector:@selector(shouldShowPublishScreenForFlowController)])
    {
        if ( [self.creationFlowDelegate shouldShowPublishScreenForFlowController])
        {
            [self toPublishScreenWithRenderedMediaURL:mediaURL
                                         previewImage:self.previewImage
                                        fromWorkspace:self.workspaceViewController];
        }
        else
        {
            [self.creationFlowDelegate creationFlowController:self
                                     finishedWithPreviewImage:self.previewImage
                                             capturedMediaURL:mediaURL];
        }
    }
    else
    {
        [self toPublishScreenWithRenderedMediaURL:mediaURL
                                     previewImage:self.previewImage
                                    fromWorkspace:self.workspaceViewController];
    }
}

- (void)cleanupCapturedFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.capturedMediaURL
                                              error:nil];
}

- (void)cleanupRenderedFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.renderedMediaURL
                                              error:nil];
}

- (void)captureFinishedWithMediaURL:(NSURL *)mediaURL
                       previewImage:(UIImage *)previewImage
{
    [self captureFinishedWithMediaURL:mediaURL previewImage:previewImage shouldSkipTrimmer:NO];
}

- (void)captureFinishedWithMediaURL:(NSURL *)mediaURL
                       previewImage:(UIImage *)previewImage
                  shouldSkipTrimmer:(BOOL)shouldSkipTrimmerForContext
{
    self.capturedMediaURL = mediaURL;
    self.previewImage = previewImage;
    
    // If the user has permission to skip the trimmmer (API Driven)
    // Go straight to publish do not pass go, do not collect $200
    if ( shouldSkipTrimmerForContext || [self shouldSkipTrimmerForVideoLength] )
    {
        [self afterEditingFinishedUseCapturedMediaURL:YES];
        
        // Since we're skipping the video camera clear the state
        if ([self.topViewController isKindOfClass:[VVideoCameraViewController class]])
        {
            VVideoCameraViewController *videoCamera = (VVideoCameraViewController *)self.topViewController;
            [videoCamera clearCaptureState];
        }
    }
    else if ( mediaURL == nil && previewImage == nil )
    {
        [self showAlertForBadMediaFileSelected];
        return;
    }
    else
    {
        [self prepareWorkspaceWithMediaURL:mediaURL
                           andPreviewImage:previewImage];
        BOOL shouldSkipWorkspace = self.workspaceViewController.toolController.tools.count == 0 && [self mediaType] == MediaTypeImage;
        if (shouldSkipWorkspace) {
            [self workspaceFinished:YES withPreviewImage:previewImage mediaURL:mediaURL];
            return;
        }
        
        if ([self.workspaceViewController isKindOfClass:[NativeWorkspaceViewController class]])
        {
            //The navive workspace view controller must be
            //presented to avoid layout animation issues
            [self presentViewController:self.workspaceViewController animated:YES completion:nil];
        }
        else
        {
            [self showViewController:self.workspaceViewController sender:nil];
        }
    }
}

- (BOOL)shouldSkipTrimmerForVideoLength
{
    return NO;
}

- (void)showAlertForBadMediaFileSelected
{
    [self v_showAlertWithTitle:nil message:NSLocalizedString(@"GenericFailMessage", @"") completion:^
    {
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // Cleanup as we enter or exit different states
    if (viewController == self.captureContainerViewController)
    {
        [self cleanupCapturedFile];
    }
}

#pragma mark - VAssetCollectionGridViewControllerDelegate

- (void)gridViewController:(VAssetCollectionGridViewController *)gridViewController
             selectedAsset:(PHAsset *)asset
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    self.downloader = [self downloaderWithAsset:asset];
    __weak typeof(self) welf = self;
    [self.downloader downloadWithProgress:^(BOOL accurateProgress, double progress, NSString *progressText)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             hudForView.mode =  accurateProgress ? MBProgressHUDModeAnnularDeterminate : MBProgressHUDModeIndeterminate;
             hudForView.progress = progress;
             hudForView.label.text = progressText;
         });
     }
                               completion:^(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage)
     {
         __strong typeof(welf) strongSelf = welf;
         [hudForView hideAnimated:YES];
         if (error == nil)
         {
             strongSelf.source = VCreationFlowSourceLibrary;
             // We need to set this so that local videos preserve aspect ratio.
             if (asset.mediaType == PHAssetMediaTypeVideo)
             {
                 strongSelf.publishParameters.width = asset.pixelWidth;
                 strongSelf.publishParameters.height = asset.pixelHeight;
             }
             [strongSelf captureFinishedWithMediaURL:downloadedFileURL
                                        previewImage:previewImage];
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

#pragma mark - VScaleAnimatorSource

- (CGFloat)startingScaleForAnimator:(VScaleAnimator *)animator
                             inView:(UIView *)animationContainerView
{
    UIViewController *topViewController = [self.viewControllers lastObject];
    return CGRectGetHeight(topViewController.navigationItem.titleView.bounds) / CGRectGetHeight(animationContainerView.bounds);
}

- (CGPoint)startingCenterForAnimator:(VScaleAnimator *)animator
                              inView:(UIView *)animationContainerView
{
    UIViewController *topViewController = [self.viewControllers lastObject];
    return [animationContainerView convertPoint:topViewController.navigationItem.titleView.center
                                       fromView:topViewController.navigationItem.titleView.superview];
}

@end
