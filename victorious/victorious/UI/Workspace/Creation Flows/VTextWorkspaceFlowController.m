//
//  VTextWorkspaceFlowController.m
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextWorkspaceFlowController.h"
#import "VDependencyManager+VWorkspace.h"
#import "VWorkspaceViewController.h"
#import "VTextToolController.h"
#import "VRootViewController.h"
#import "VTextCanvasToolViewController.h"
#import "VWorkspaceTool.h"
#import "NSDictionary+VJSONLogging.h"
#import "VEditableTextPostViewController.h"
#import "VTextListener.h"
#import "VImageSearchViewController.h"
#import "VMediaAttachmentPresenter.h"

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate, VTextListener, VTextCanvasToolDelegate>

@property (nonatomic, strong) VWorkspaceViewController *textWorkspaceViewController;
@property (nonatomic, strong) VTextCanvasToolViewController *textCanvasToolViewController;
@property (nonatomic, strong) VTextToolController *textToolController;
@property (nonatomic, strong) VMediaAttachmentPresenter *attachmentPresenter;

@property (nonatomic, strong) UIViewController *mediaCaptureViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VTextWorkspaceFlowController

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert(dependencyManager != nil, @"Workspace flow controller needs a dependency manager");
    VDependencyManager *dependencyManagerToUse = dependencyManager;
    return [dependencyManagerToUse templateValueOfType:[VTextWorkspaceFlowController class] forKey:VDependencyManagerTextWorkspaceFlowKey];
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self )
    {
        // Create the text workspace
        _textWorkspaceViewController = [self createTextWorkspaceWithDependencyManager:dependencyManager];
        
        // Create the workspace canvas
        _textCanvasToolViewController = [VTextCanvasToolViewController newWithDependencyManager:dependencyManager];
        _textCanvasToolViewController.delegate = self;
        
        // Create the tool controller and set up delegates
        _textToolController = [self createToolControllerWithDependencyManager:dependencyManager];
        _textToolController.textListener = self;
        _textToolController.delegate = _textWorkspaceViewController;
        _textWorkspaceViewController.toolController = _textToolController;
        _textWorkspaceViewController.disablesInpectorOnKeyboardAppearance = YES;
        
        // Set our dependency manager
        _dependencyManager = dependencyManager;
        
        // Add tools to the tool controller
        [_textWorkspaceViewController.toolController.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
         {
             if ( [tool respondsToSelector:@selector(setSharedCanvasToolViewController:)] )
             {
                 [tool setSharedCanvasToolViewController:_textCanvasToolViewController];
             }
         }];
        
        // Add the close button and push the workspace
        [self addCloseButtonToViewController:_textWorkspaceViewController];
        [self pushViewController:_textWorkspaceViewController animated:NO];
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
        [self.creationFlowDelegate creationFLowController:self
                                 finishedWithPreviewImage:previewImage
                                         capturedMediaURL:renderedMediaURL];
    };
    workspace.continueText = NSLocalizedString( @"Publish", @"Label for button that will publish content." );
    workspace.activityText = NSLocalizedString( @"Publishing...", @"Label indicating that content is being published." );
    workspace.confirmCancelMessage = NSLocalizedString( @"This will discard any content added to your post", @"" );
    workspace.shouldConfirmCancels = YES;
    return workspace;
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
    [self presentCameraViewController];
}

- (void)textCanvasToolDidSelectImageSearch:(VTextCanvasToolViewController *)textCanvasToolViewController
{
    self.mediaCaptureViewController = [self createImageSearchViewController];
    [self presentViewController:self.mediaCaptureViewController animated:YES completion:nil];
}

- (void)textCanvasToolDidSelectClearImage:(VTextCanvasToolViewController *)textCanvasToolViewController
{
    textCanvasToolViewController.shouldProvideClearOption = NO;
    [self.textToolController setMediaURL:nil previewImage:nil];
}

#pragma mark - Choosing background image

- (void)presentCameraViewController
{
    self.attachmentPresenter = [[VMediaAttachmentPresenter alloc] initWithViewControllerToPresentOn:self
                                                                                  dependencymanager:self.dependencyManager];
    self.attachmentPresenter.attachmentTypes = VMediaAttachmentTypeImage;
    __weak typeof(self) welf = self;
    self.attachmentPresenter.completion = ^void(BOOL success, UIImage *previewImage, NSURL *mediaURL)
    {
        [welf dismissViewControllerAnimated:YES
                                 completion:nil];
        [welf didCaptureMediaWithURL:mediaURL previewImage:previewImage];
    };
    [self.attachmentPresenter present];
}

- (UIViewController *)createImageSearchViewController
{
    VImageSearchViewController *imageSearchViewController = [VImageSearchViewController newImageSearchViewController];
    __weak typeof(self) welf = self;
    imageSearchViewController.completionBlock = ^void(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [welf didCaptureMediaWithURL:capturedMediaURL previewImage:previewImage];
    };
    return imageSearchViewController;
}

- (void)didCaptureMediaWithURL:(NSURL *)capturedMediaURL previewImage:(UIImage *)previewImage
{
    if ( capturedMediaURL != nil && previewImage != nil )
    {
        [self.textToolController setMediaURL:capturedMediaURL previewImage:previewImage];
        self.textCanvasToolViewController.shouldProvideClearOption = YES;
    }
    
    [self.mediaCaptureViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
