//
//  VImageCreationFlowStrategy.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageCreationFlowStrategy.h"

// Dependencies
#import "VDependencyManager.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VImageVideoLibraryViewController.h"
#import "VWorkspaceViewController.h"
#import "VPublishViewController.h"

// ToolController
#import "VImageToolController.h"

static NSString * const kImageVideoLibraryKey = @"imageVideoLibrary";
static NSString * const kCameraScreenKey = @"cameraScreen";

@interface VImageCreationFlowStrategy ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VCameraViewController *cameraViewController;
@property (nonatomic, strong) VImageVideoLibraryViewController *imageVideoLibraryViewController;
@property (nonatomic, strong) VWorkspaceViewController *workspaceViewController;
@property (nonatomic, strong) VPublishViewController *publishViewController;

@end

@implementation VImageCreationFlowStrategy

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        [self setupCamera];
        [self setupWorkspace];
        [self setupPublishScreen];
    }
    return self;
}

#pragma mark - Overrides

- (UIViewController *)rootViewControllerForCreationFlow
{
    return [self libraryViewController];
}

#pragma mark - Properties

- (VImageVideoLibraryViewController *)libraryViewController
{
    self.imageVideoLibraryViewController = [self.dependencyManager templateValueOfType:[VImageVideoLibraryViewController class] forKey:kImageVideoLibraryKey];
    
    __weak VImageCreationFlowStrategy *weakSelf = self;
    self.imageVideoLibraryViewController.userSelectedCamera = ^void()
    {
        [weakSelf.flowNavigationController presentViewController:weakSelf.cameraViewController
                                                        animated:YES
                                                      completion:nil];
    };
    
    self.imageVideoLibraryViewController.userSelectedSearch = ^void()
    {
        
    };
    
    return self.imageVideoLibraryViewController;
}

#pragma mark - Private Methods

- (void)setupCamera
{
    _cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotosWithDependencyManager:self.dependencyManager];
    __weak VImageCreationFlowStrategy *weakSelf = self;
    _cameraViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            weakSelf.workspaceViewController.previewImage = previewImage;
            weakSelf.workspaceViewController.mediaURL = capturedMediaURL;
            VImageToolController *toolController = (VImageToolController *)weakSelf.workspaceViewController.toolController;
            [toolController setDefaultImageTool:VImageToolControllerInitialImageEditStateText];
            [weakSelf.flowNavigationController pushViewController:weakSelf.workspaceViewController animated:YES];
        }
        [weakSelf.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
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
    
    __weak VImageCreationFlowStrategy *weakSelf = self;
    _workspaceViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        if (finished)
        {
            [weakSelf.flowNavigationController pushViewController:weakSelf.publishViewController animated:YES];
        }
        else
        {
            [weakSelf.flowNavigationController popViewControllerAnimated:YES];
        }
    };
}

- (void)setupPublishScreen
{
    _publishViewController = [self.dependencyManager newPublishViewController];
    __weak VImageCreationFlowStrategy *weakSelf = self;
    _publishViewController.completion = ^void(BOOL published)
    {
        if (published)
        {
            // We're done!
        }
        else
        {
            [weakSelf.flowNavigationController popViewControllerAnimated:YES];
        }
    };
}

@end
