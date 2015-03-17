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

typedef NS_ENUM( NSInteger, VTextWorkspaceFlowStateType)
{
    VTextWorkspaceFlowStateTypeNone = -1,
    VTextWorkspaceFlowStateTypeEnter,
    VTextWorkspaceFlowStateTypeEdit,
    VTextWorkspaceFlowStateTypePublish
};

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate, VWorkspaceDelegate>

@property (nonatomic, strong) UINavigationController *flowNavigationController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VWorkspaceViewController *editTextWorkspaceViewController;
@property (nonatomic, strong) VEditTextToolViewController *editTextToolViewController;

@end

@implementation VTextWorkspaceFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self )
    {
        VDependencyManager *globalDependencyManager = [[VRootViewController rootViewController] dependencyManager];
        NSDictionary *dictionary = [globalDependencyManager templateValueOfType:[NSDictionary class] forKey:@"workspaceFlowText"];
        _dependencyManager = [globalDependencyManager childDependencyManagerWithAddedConfiguration:dictionary];
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.navigationBarHidden = YES;
        //_flowNavigationController.delegate = self;
        
        _editTextWorkspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerEditTextWorkspaceKey];
        _editTextWorkspaceViewController.continueText = NSLocalizedString( @"Publish", @"" );
        _editTextWorkspaceViewController.showCloseButton = YES;
        _editTextWorkspaceViewController.delegate = self;
        
        _editTextToolViewController = [VEditTextToolViewController newWithDependencyManager:dependencyManager];
        NSDictionary *editTextWorkspace = [dependencyManager templateValueOfType:[NSDictionary class] forKey:@"editTextWorkspace"];
        VDependencyManager *workspaceDependency = [dependencyManager childDependencyManagerWithAddedConfiguration:editTextWorkspace];
        NSArray *workspaceTools = [workspaceDependency workspaceTools];
        VTextToolController *toolController = [[VTextToolController alloc] initWithTools:workspaceTools];
        toolController.delegate = _editTextWorkspaceViewController;
        toolController.text = [self randomSampleText];
        toolController.dependencyManager = _editTextWorkspaceViewController.dependencyManager;
        _editTextWorkspaceViewController.toolController = toolController;
        
        [toolController.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
         {
             if ( [tool respondsToSelector:@selector(setSharedCanvasToolViewController:)] )
             {
                 [tool setSharedCanvasToolViewController:_editTextToolViewController];
             }
        }];
        
        [self.flowNavigationController pushViewController:_editTextWorkspaceViewController animated:NO];
    }
    return self;
}

- (NSString *)randomSampleText
{
    return @"Here is my sample text that is quite long and is intended to span onto at least three lines so we can see how it looks.";
}

#pragma mark - Property Accessors

- (UIViewController *)flowRootViewController
{
    return self.flowNavigationController;
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    return nil;
}

#pragma mark - VWorkspaceDelegate

- (void)workspaceDidPublish:(VWorkspaceViewController *)workspaceViewController
{
    NSLog( @"Publish" );
}

- (void)workspaceDidClose:(VWorkspaceViewController *)workspaceViewController
{
    [self.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
