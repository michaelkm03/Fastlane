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
#import "VEditTextToolViewController.h"
#import "VWorkspaceTool.h"

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *flowNavigationController;
@property (nonatomic, strong) VWorkspaceViewController *textWorkspaceViewController;
@property (nonatomic, strong) VEditTextToolViewController *textToolViewController;

@end

@implementation VTextWorkspaceFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self )
    {
        // 1. Create the text workspace
        _textWorkspaceViewController = [self createTextWorkspaceWithDependencyManager:dependencyManager];
        
        // 2. Create the worksapce canvas
        _textToolViewController = [VEditTextToolViewController newWithDependencyManager:dependencyManager];
        
        // 3. Create the tool controller using workspace as delegate
        _textWorkspaceViewController.toolController = [self createToolControllerWithDependencyManager:dependencyManager delegate:_textWorkspaceViewController];
        
        // 4. Add tools to the tool controller
        [_textWorkspaceViewController.toolController.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
         {
             if ( [tool respondsToSelector:@selector(setSharedCanvasToolViewController:)] )
             {
                 [tool setSharedCanvasToolViewController:_textToolViewController];
             }
         }];
        
        // 5. Create the nav controller and present the workspace
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.navigationBarHidden = YES;
        [_flowNavigationController pushViewController:_textWorkspaceViewController animated:NO];
    }
    return self;
}

- (VTextToolController *)createToolControllerWithDependencyManager:(VDependencyManager *)dependencyManager delegate:(id<VToolControllerDelegate>)delegate
{
    NSDictionary *textWorkspace = [dependencyManager templateValueOfType:[NSDictionary class] forKey:@"editTextWorkspace"];
    VDependencyManager *workspaceDependency = [dependencyManager childDependencyManagerWithAddedConfiguration:textWorkspace];
    NSArray *workspaceTools = [workspaceDependency workspaceTools];
    VTextToolController *toolController = [[VTextToolController alloc] initWithTools:workspaceTools];
    toolController.delegate = delegate;
    return toolController;
}

- (VWorkspaceViewController *)createTextWorkspaceWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VWorkspaceViewController *workspace = (VWorkspaceViewController *)[dependencyManager viewControllerForKey:VDependencyManagerEditTextWorkspaceKey];
    __weak typeof(self) welf = self;
    workspace.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
    {
        if ( !finished )
        {
            [welf.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            NSLog( @"PUBLISH" );
        }
    };
    workspace.showCloseButton = YES;
    workspace.continueText = @"Publish";
    return workspace;
}

#pragma mark - Property Accessors

- (UIViewController *)flowRootViewController
{
    return self.flowNavigationController;
}

@end
