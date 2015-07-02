//
//  VImageCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowController.h"

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

// Keys
NSString * const VCreationFLowCaptureScreenKey = @"captureScreen";
NSString * const VImageCreationFlowControllerKey = @"imageCreateFlow";

@interface VImageCreationFlowController () <UINavigationControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

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
        
        UIViewController<VMediaSource> *viewController = [dependencyManager templateValueConformingToProtocol:@protocol(VMediaSource)
                                                                                         forKey:VCreationFLowCaptureScreenKey
                                                                          withAddedDependencies:nil];
        [self addCompleitonHandlerToMediaSource:viewController];
        [self addCloseButtonToViewController:viewController];
        [self pushViewController:viewController animated:YES];
        
        [self setupPublishScreen];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Target/Action

- (void)selectedCancel:(UIBarButtonItem *)cancelButton
{
    self.delegate = nil;
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private Methods

- (void)addCompleitonHandlerToMediaSource:(id<VMediaSource>)mediaSource
{
    __weak typeof(self) welf = self;
    mediaSource.handler = ^void(UIImage *previewImage, NSURL *capturedMediaURL)
    {
#warning Remove me
        NSData *dataWithURL = [NSData dataWithContentsOfURL:capturedMediaURL];
        UIImage *imageFromData = [UIImage imageWithData:dataWithURL];
        
        if (capturedMediaURL != nil)
        {
            [welf setupWorkspace];

            welf.workspaceViewController.previewImage = previewImage;
            welf.workspaceViewController.mediaURL = capturedMediaURL;
            VImageToolController *toolController = (VImageToolController *)welf.workspaceViewController.toolController;
            [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
            [welf pushViewController:welf.workspaceViewController animated:YES];
        }
        else
        {

        }
    };
}

- (void)setupWorkspace
{
    _workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerImageWorkspaceKey];
    _workspaceViewController.disablesInpectorOnKeyboardAppearance = YES;
    _workspaceViewController.disablesNavigationItemsOnKeyboardAppearance = YES;
    _workspaceViewController.adjustsCanvasViewFrameOnKeyboardAppearance = YES;
    _workspaceViewController.continueText = NSLocalizedString(@"Publish", @"");
    _workspaceViewController.continueButtonEnabled = YES;

    __weak typeof(self) welf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        if (finished)
        {
            welf.renderedMediaURL = renderedMediaURL;
            welf.previewImage = previewImage;
            [welf pushPublishScreenWithRenderedMediaURL:renderedMediaURL
                                               previewImage:previewImage
                                              fromWorkspace:welf.workspaceViewController];
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

#pragma mark Navigation Item Configuration

- (void)addCloseButtonToViewController:(UIViewController *)viewController
{
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(selectedCancel:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;
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

//                [navigationController setNavigationBarHidden:pushing animated:YES];
        self.publishAnimator.presenting = pushing;

        return self.publishAnimator;
    }
    return nil;
}

@end


#warning REMOVE ME Image Strategy work from earlier REMOVE ME
//
////
////  VImageCreationFlowStrategy.m
////  victorious
////
////  Created by Michael Sena on 6/24/15.
////  Copyright (c) 2015 Victorious. All rights reserved.
////
//
//#import "VImageCreationFlowStrategy.h"
//
//// Dependencies
//#import "VDependencyManager.h"
//
//// Publishing
//#import "VPublishParameters.h"
//
//// ViewControllers
//#import "VCameraViewController.h"
//#import "VImageVideoLibraryViewController.h"
//#import "VWorkspaceViewController.h"
//#import "VPublishViewController.h"
//
//// ToolController
//#import "VImageToolController.h"
//
//// Animators
//#import "VPublishBlurOverAnimator.h"
//
//static NSString * const kImageVideoLibraryKey = @"imageVideoLibrary";
//static NSString * const kCameraScreenKey = @"cameraScreen";
//
//@interface VImageCreationFlowStrategy ()
//
//@property (nonatomic, strong) VDependencyManager *dependencyManager;
//@property (nonatomic, strong) VCameraViewController *cameraViewController;
//@property (nonatomic, strong) VImageVideoLibraryViewController *imageVideoLibraryViewController;
//@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;
//
//@property (nonatomic, strong) VPublishViewController *publishViewController;
//@property (nonatomic, strong) VPublishBlurOverAnimator *publishPushAnimator;
//
//// Creation Results
//@property (nonatomic, strong) UIImage *previewImage;
//@property (nonatomic, strong) NSURL *renderedMediaURL;
//
//@end
//
//@implementation VImageCreationFlowStrategy
//
//- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
//{
//    self = [super init];
//    if (self != nil)
//    {
//        _dependencyManager = dependencyManager;
//        [self setupCamera];
//        [self setupWorkspace];
//        [self setupPublishScreen];
//    }
//    return self;
//}
//
//#pragma mark - Overrides
//
//- (UIViewController *)rootViewControllerForCreationFlow
//{
//    return [self libraryViewController];
//}
//
//#pragma mark - Properties
//
//- (VImageVideoLibraryViewController *)libraryViewController
//{
//    self.imageVideoLibraryViewController = [self.dependencyManager templateValueOfType:[VImageVideoLibraryViewController class] forKey:kImageVideoLibraryKey];
//    
//    VImageLibraryAlternateCaptureOption *cameraCaptureOption = [[VImageLibraryAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Camera", nil)
//                                                                                                                     icon:[UIImage imageNamed:@"PostCamera"]
//                                                                                                        andSelectionBlock:^
//                                                                {
//                                                                    // Goto Camera
//                                                                }];
//    VImageLibraryAlternateCaptureOption *searchCpatureOption = [[VImageLibraryAlternateCaptureOption alloc] initWithTitle:NSLocalizedString(@"Search", nil)
//                                                                                                                     icon:[UIImage imageNamed:@"D_search_small_icon"]
//                                                                                                        andSelectionBlock:^
//                                                                {
//                                                                    // Go to Search
//                                                                }];
//    
//    self.imageVideoLibraryViewController.alternateCaptureOptions = @[cameraCaptureOption, searchCpatureOption];
//    return self.imageVideoLibraryViewController;
//}
//
//#pragma mark - Private Methods
//
//- (void)setupCamera
//{
//    _cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotosWithDependencyManager:self.dependencyManager];
//    __weak VImageCreationFlowStrategy *weakSelf = self;
//    _cameraViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
//    {
//        if (finished)
//        {
//            [weakSelf setupWorkspace];
//            weakSelf.workspaceViewController.previewImage = previewImage;
//            weakSelf.workspaceViewController.mediaURL = capturedMediaURL;
//            VImageToolController *toolController = (VImageToolController *)weakSelf.workspaceViewController.toolController;
//            [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
//            [weakSelf.flowNavigationController dismissViewControllerAnimated:YES completion:^
//             {
//                 [weakSelf.flowNavigationController pushViewController:weakSelf.workspaceViewController animated:YES];
//             }];
//        }
//        else
//        {
//            [weakSelf.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
//        }
//    };
//}
////
//- (void)setupPublishScreen
//{
//    _publishPushAnimator = [[VPublishBlurOverAnimator alloc] init];
//    _publishViewController = [self.dependencyManager newPublishViewController];
//    __weak VImageCreationFlowStrategy *weakSelf = self;
//    _publishViewController.completion = ^void(BOOL published)
//    {
//        if (published)
//        {
//            // We're done!
//            [weakSelf.delegate creationFlowStrategy:weakSelf
//                           finishedWithPreviewImage:weakSelf.previewImage
//                                   capturedMediaURL:weakSelf.renderedMediaURL];
//        }
//        else
//        {
//            [weakSelf.flowNavigationController popViewControllerAnimated:YES];
//        }
//    };
//}
//
//- (void)pushPublishScreenWithRenderedMediaURL:(NSURL *)renderedMediaURL
//                                 previewImage:(UIImage *)previewImage
//                                fromWorkspace:(VWorkspaceViewController *)workspace
//{
//    VPublishParameters *publishParameters = [[VPublishParameters alloc] init];
//    publishParameters.mediaToUploadURL = renderedMediaURL;
//    publishParameters.previewImage = previewImage;
//    
//    VImageToolController *imageToolController = (VImageToolController *)workspace.toolController;
//    publishParameters.embeddedText = imageToolController.embeddedText;
//    publishParameters.textToolType = imageToolController.textToolType;
//    publishParameters.filterName = imageToolController.filterName;
//    publishParameters.didCrop = imageToolController.didCrop;
//    publishParameters.isVideo = NO;
//    
//    self.publishViewController.publishParameters = publishParameters;
//    [self.flowNavigationController pushViewController:self.publishViewController animated:YES];
//}
//
//#pragma mark - UINavigationControllerDelegate
//
//- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                fromViewController:(UIViewController *)fromVC
//                                                  toViewController:(UIViewController *)toVC
//{
//    if ([toVC isKindOfClass:[VPublishViewController class]] || [fromVC isKindOfClass:[VPublishViewController class]])
//    {
//        BOOL pushing = (operation == UINavigationControllerOperationPush);
//        
//        //        [navigationController setNavigationBarHidden:pushing animated:YES];
//        self.publishPushAnimator.presenting = pushing;
//        
//        return self.publishPushAnimator;
//    }
//    return nil;
//}
//
//@end
