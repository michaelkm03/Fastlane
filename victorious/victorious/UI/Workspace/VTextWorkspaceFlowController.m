//
//  VTextWorkspaceFlowController.m
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextWorkspaceFlowController.h"
#import "VDependencyManager+VWorkspaceTool.h"
#import "VWorkspaceViewController.h"
#import "VTextToolController.h"
#import "VRootViewController.h"
#import "VTextCanvasToolViewController.h"
#import "VWorkspaceTool.h"
#import "NSDictionary+VJSONLogging.h"
#import "VEditableTextPostViewController.h"
#import "VTextListener.h"
#import "VCameraViewController.h"
#import "VImageSearchViewController.h"

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate, VTextListener, VTextCanvasToolDelegate>

@property (nonatomic, strong) UINavigationController *flowNavigationController;
@property (nonatomic, strong) VWorkspaceViewController *textWorkspaceViewController;
@property (nonatomic, strong) VTextCanvasToolViewController *textCanvasToolViewController;
@property (nonatomic, strong) VTextToolController *textToolController;

@property (nonatomic, strong) UIViewController *mediaCaptureViewController;
@property (nonatomic, strong, readwrite) UIImage *previewImage;

@end

@implementation VTextWorkspaceFlowController

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VDependencyManager *dependencyManagerToUse = dependencyManager ?: [[VRootViewController rootViewController] dependencyManager];
    return [dependencyManagerToUse templateValueOfType:[VTextWorkspaceFlowController class] forKey:VDependencyManagerTextWorkspaceFlowKey];
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self )
    {
        // Create the text workspace
        _textWorkspaceViewController = [self createTextWorkspaceWithDependencyManager:dependencyManager];
        
        // Create the worksapce canvas
        _textCanvasToolViewController = [VTextCanvasToolViewController newWithDependencyManager:dependencyManager];
        _textCanvasToolViewController.delegate = self;
        
        // Create the tool controller and set up delegates
        _textToolController = [self createToolControllerWithDependencyManager:dependencyManager];
        _textToolController.textListener = self;
        _textToolController.delegate = _textWorkspaceViewController;
        _textWorkspaceViewController.toolController = _textToolController;
        _textWorkspaceViewController.disablesInpectorOnKeyboardAppearance = YES;
        
        // Add tools to the tool controller
        [_textWorkspaceViewController.toolController.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
         {
             if ( [tool respondsToSelector:@selector(setSharedCanvasToolViewController:)] )
             {
                 [tool setSharedCanvasToolViewController:_textCanvasToolViewController];
             }
         }];
        
        // Create the nav controller and present the workspace
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.navigationBarHidden = YES;
        [_flowNavigationController pushViewController:_textWorkspaceViewController animated:NO];
    }
    return self;
}

- (VTextToolController *)createToolControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSDictionary *textWorkspace = [dependencyManager templateValueOfType:[NSDictionary class] forKey:@"editTextWorkspace"];
    VDependencyManager *workspaceDependency = [dependencyManager childDependencyManagerWithAddedConfiguration:textWorkspace];
    NSArray *workspaceTools = [workspaceDependency workspaceTools];
    VTextToolController *toolController = [[VTextToolController alloc] initWithTools:workspaceTools];
    return toolController;
}

- (VWorkspaceViewController *)createTextWorkspaceWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VWorkspaceViewController *workspace = (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerEditTextWorkspaceKey];
    workspace.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        [self.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
    };
    workspace.showCloseButton = YES;
    workspace.continueText = NSLocalizedString( @"Publish", @"Label for button that will publish content." );
    workspace.activityText = NSLocalizedString( @"Publishing...", @"Label indicating that content is being published." );
    workspace.confirmCancelMessage = NSLocalizedString( @"This will discard any content added to your post", @"" );
    workspace.shouldConfirmCancels = YES;
    return workspace;
}

#pragma mark - Property Accessors

- (UIViewController *)flowRootViewController
{
    return self.flowNavigationController;
}

#pragma mark - VTextListener

- (void)textDidUpdate:(NSString *)text
{
    BOOL enabled = self.textCanvasToolViewController.textPostViewController.textOutput.length > 0;
    [self.textWorkspaceViewController.continueButton setEnabled:enabled];
}

#pragma mark - VTextCanvasToolDelegate

- (void)textCanvasToolDidSelectCamera:(VTextCanvasToolViewController *)textCanvasToolViewController
{
    self.mediaCaptureViewController = [self createCameraViewController];
    [self.flowNavigationController presentViewController:self.mediaCaptureViewController animated:YES completion:nil];
}

- (void)textCanvasToolDidSelectImageSearch:(VTextCanvasToolViewController *)textCanvasToolViewController
{
    self.mediaCaptureViewController = [self createImageSearchViewController];
    [self.flowNavigationController presentViewController:self.mediaCaptureViewController animated:YES completion:nil];
}

#pragma mark - Choosing background image

- (UIViewController *)createCameraViewController
{
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotos];
    cameraViewController.shouldSkipPreview = YES;
    __weak typeof(self) welf = self;
    cameraViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [welf didCaptureMediaWithUR:capturedMediaURL previewImage:previewImage];
    };
    return cameraViewController;
}

- (UIViewController *)createImageSearchViewController
{
    VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewController];
    __weak typeof(self) welf = self;
    imageSearchViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [welf didCaptureMediaWithUR:capturedMediaURL previewImage:previewImage];
    };
    return imageSearchViewController;
}

- (void)didCaptureMediaWithUR:(NSURL *)capturedMediaURL previewImage:(UIImage *)previewImage
{
    if ( capturedMediaURL != nil && previewImage != nil )
    {
        self.textToolController.capturedMediaURL = capturedMediaURL;
        [self.textCanvasToolViewController imageSelected:previewImage];
    }
    
    [self.mediaCaptureViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
