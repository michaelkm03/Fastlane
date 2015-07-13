//
//  VVideoCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCreationFlowController.h"

// Capture
#import "VCaptureContainerViewController.h"
#import "VAlternateCaptureOption.h"
#import "VAssetCollectionGridViewController.h"
#import "VAssetCollectionListViewController.h"

// Workspace
#import "VWorkspaceViewController.h"
#import "VVideoToolController.h"
#import "VPublishViewController.h"

// Publishing
#import "VPublishParameters.h"

// Animators
#import "VPublishBlurOverAnimator.h"

// Views + Helpers
#import "UIAlertController+VSimpleAlert.h"

// Dependencies
#import "VDependencyManager.h"

static NSString * const kVideoWorkspaceKey = @"videoWorkspace";

@interface VVideoCreationFlowController () <UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VAssetCollectionListViewController *listViewController;
@property (nonatomic, strong) VAssetCollectionGridViewController *gridViewController;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;

@property (nonatomic, strong) VPublishViewController *publishViewContorller;
@property (nonatomic, strong) VPublishBlurOverAnimator *publishAnimator;

@property (nonatomic, strong) NSURL *renderedMediaURL;
@property (nonatomic, strong) UIImage *previewImage;

@end

@implementation VVideoCreationFlowController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        
        VCaptureContainerViewController *captureContainer = [VCaptureContainerViewController captureContainerWithDependencyManager:dependencyManager];
        [captureContainer setAlternateCaptureOptions:[self alternateCaptureOptions]];
        [self addCloseButtonToViewController:captureContainer];
        [self setViewControllers:@[captureContainer]];
        
        _listViewController = [VAssetCollectionListViewController assetCollectionListViewControllerWithMediaType:PHAssetMediaTypeVideo];
        _gridViewController = [VAssetCollectionGridViewController assetGridViewControllerWithDependencyManager:dependencyManager
                                                                                                     mediaType:PHAssetMediaTypeVideo];
        [captureContainer setContainedViewController:_gridViewController];
    }
    return self;
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
#warning download the asset
#warning  move this to a helper method
//        if (capturedMediaURL != nil)
//        {
//            [welf setupWorkspace];
//            self.workspaceViewController.mediaURL = capturedMediaURL;
//            self.workspaceViewController.previewImage = previewImage;
//            
//            VVideoToolController *toolController = (VVideoToolController *)welf.workspaceViewController.toolController;
//            [toolController setDefaultVideoTool:VVideoToolControllerInitialVideoEditStateGIF];
//            
//            [self pushViewController:self.workspaceViewController animated:YES];
//        }
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    self.listViewController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popoverPresentation = self.listViewController.popoverPresentationController;
    popoverPresentation.delegate = self;
    CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                             CGRectGetHeight(self.view.bounds) - 200.0f);
    self.listViewController.preferredContentSize = preferredContentSize;
    UIViewController *topViewContorller = [self.viewControllers firstObject];
    popoverPresentation.sourceView = topViewContorller.navigationItem.titleView;
    popoverPresentation.sourceRect = CGRectMake(CGRectGetMidX(popoverPresentation.sourceView.bounds),
                                                CGRectGetMaxY(popoverPresentation.sourceView.bounds) + CGRectGetHeight(popoverPresentation.sourceView.bounds),
                                                0.0f,
                                                CGRectGetHeight(popoverPresentation.sourceView.bounds));
    
    [self presentViewController:self.listViewController animated:YES completion:nil];
}

- (NSArray *)alternateCaptureOptions
{
    VAlternateCaptureOption *cameraOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:^
                                             {
                                                 // Camera
                                             }];
    VAlternateCaptureOption *searchOption = [[VAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                                      icon:[UIImage imageNamed:@""]
                                                                         andSelectionBlock:^
                                             {
                                                 // Search
                                             }];
    return @[cameraOption, searchOption];
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

- (void)setupWorkspace
{
    _workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:kVideoWorkspaceKey];
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
    
    //    VVideoToolController *videoToolController = (VVideoToolController *)workspace.toolController;
    publishParameters.isGIF = NO;
    publishParameters.isVideo = YES;
    
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
