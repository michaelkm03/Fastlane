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
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"
#import "VAssetDownloader.h"
#import "UIAlertController+VSimpleAlert.h"

// Animator Support
#import "VScaleAnimator.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VImageToolController.h"

// Publishing
#import "VPublishPresenter.h"
#import "VPublishViewController.h"
#import "VPublishParameters.h"

// API driven behavior
#import "VUser+Fetcher.h"
#import "VObjectManager.h"

// Dependencies
#import "VDependencyManager.h"

@import Photos;
#import <MBProgressHUD/MBProgressHUD.h>

@interface VAbstractImageVideoCreationFlowController () <UINavigationControllerDelegate, VAssetCollectionGridViewControllerDelegate, VScaleAnimatorSource>

@property (nonatomic, strong) NSArray *cachedAssetCollections;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VCaptureContainerViewController *captureContainerViewController;
@property (nonatomic, strong) VAssetCollectionGridViewController *gridViewController;
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
    self.publishPresenter.publishActionHandler = ^void(BOOL published)
    {
        __strong typeof(welf) strongSelf = welf;
        if (published)
        {
            // Because of a bug in how presentations work we ened to grab a screenshot of the publish screen
            // before we ened up being dismissed. The bug has to do with multi-level presentations if you
            // present A -> B -> C then dismiss from A, C is cleared and you only see B animate away.
            [strongSelf.view addSubview:[strongSelf.presentedViewController.view snapshotViewAfterScreenUpdates:YES]];
            
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
        else
        {
            [strongSelf dismissViewControllerAnimated:YES
                                           completion:nil];
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

// Only call me when you know rendered mediaURL is no longer valid and any calling classes havne't been provided this URL
- (void)cleanupRenderedFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.renderedMediaURL
                                              error:nil];
}

- (void)captureFinishedWithMediaURL:(NSURL *)mediaURL
                       previewImage:(UIImage *)previewImage
{
    // If the user has permission to skip the trimmmer (API Driven)
    // Go straight to publish do not pass go, do not collect $200
    if ([[[VObjectManager sharedManager] mainUser] shouldSkipTrimmer] && [self isKindOfClass:[VVideoCreationFlowController class]])
    {
        self.renderedMediaURL = mediaURL;
        self.previewImage = previewImage;
        [self afterEditingFinished];
    }
    else
    {
        [self prepareWorkspaceWithMediaURL:mediaURL
                           andPreviewImage:previewImage];
        [self pushViewController:self.workspaceViewController animated:YES];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
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
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.downloader = [self downloaderWithAsset:asset];
    __weak typeof(self) welf = self;
    [self.downloader downloadWithProgress:^(BOOL accurateProgress, double progress, NSString *progressText)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             hudForView.mode =  accurateProgress ? MBProgressHUDModeAnnularDeterminate : MBProgressHUDModeIndeterminate;
             hudForView.progress = progress;
             hudForView.labelText = progressText;
         });
     }
                               completion:^(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage)
     {
         __strong typeof(welf) strongSelf = welf;
         [hudForView hide:YES];
         if (error == nil)
         {
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
