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

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *flowNavigationController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VWorkspaceViewController *textWorkspaceViewController;
@property (nonatomic, strong) VEditTextToolViewController *textToolViewController;

@end

@implementation VTextWorkspaceFlowController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self )
    {
        _dependencyManager = dependencyManager;
        _flowNavigationController = [[UINavigationController alloc] init];
        _flowNavigationController.navigationBarHidden = YES;
        //_flowNavigationController.delegate = self;
        
        _textWorkspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerEditTextWorkspaceKey];
        __weak typeof(self) welf = self;
        _textWorkspaceViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL)
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
        _textWorkspaceViewController.showCloseButton = YES;
        _textWorkspaceViewController.continueText = @"Publish";
        
        _textToolViewController = [VEditTextToolViewController newWithDependencyManager:dependencyManager];
        NSDictionary *textWorkspace = [dependencyManager templateValueOfType:[NSDictionary class] forKey:@"editTextWorkspace"];
        
        VDependencyManager *workspaceDependency = [dependencyManager childDependencyManagerWithAddedConfiguration:textWorkspace];
        NSArray *workspaceTools = [workspaceDependency workspaceTools];
        VTextToolController *toolController = [[VTextToolController alloc] initWithTools:workspaceTools];
        toolController.text = [self randomSampleText];
        toolController.delegate = _textWorkspaceViewController;
        
        //toolController.dependencyManager = _textWorkspaceViewController.dependencyManager;
        _textWorkspaceViewController.toolController = toolController;
        
        [toolController.tools enumerateObjectsUsingBlock:^(id<VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
         {
             if ( [tool respondsToSelector:@selector(setSharedCanvasToolViewController:)] )
             {
                 [tool setSharedCanvasToolViewController:_textToolViewController];
             }
        }];
        
        
        
        [self.flowNavigationController pushViewController:_textWorkspaceViewController animated:NO];
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

@end
