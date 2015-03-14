//
//  VTextWorkspaceFlowController.m
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextWorkspaceFlowController.h"
#import "VDependencyManager.h"
#import "VWorkspaceViewController.h"

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

@property (nonatomic, assign) NSInteger currentWorkspaceIndex;
@property (nonatomic, strong) NSArray *workspaceViewControllers;

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
        
        VWorkspaceViewController *enterTextWorkspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerEnterTextWorkspaceKey];
        enterTextWorkspaceViewController.text = [self randomSampleText];
        enterTextWorkspaceViewController.continueText = NSLocalizedString( @"Next", @"" );
        enterTextWorkspaceViewController.showCloseButton = YES;
        enterTextWorkspaceViewController.delegate = self;
        
        VWorkspaceViewController *editTextWorkspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerEditTextWorkspaceKey];
        editTextWorkspaceViewController.text = [self randomSampleText];
        editTextWorkspaceViewController.continueText = NSLocalizedString( @"Publish", @"" );
        editTextWorkspaceViewController.delegate = self;
        
        self.workspaceViewControllers = @[ enterTextWorkspaceViewController, editTextWorkspaceViewController ];
        
        self.currentWorkspaceIndex = -1;
        
        [self showNextWorkspace];
    }
    return self;
}

- (NSString *)randomSampleText
{
    return @"Here is my sample text that is quite long and is intended to span onto at least three lines so we can see how it looks.";
}

#pragma mark - Nvigation/State management

- (void)showNextWorkspace
{
    if ( self.currentWorkspaceIndex + 1 < (NSInteger)self.workspaceViewControllers.count )
    {
        self.currentWorkspaceIndex++;
        VWorkspaceViewController *workspaceToShow = self.workspaceViewControllers[ self.currentWorkspaceIndex ];
        [self.flowNavigationController pushViewController:workspaceToShow animated:NO];
    }
    else
    {
        // Publish
        NSLog( @"Publish" );
    }
}

- (void)showPreviousWorkspace
{
    if ( self.currentWorkspaceIndex - 1 >= (NSInteger)0 )
    {
        self.currentWorkspaceIndex--;
        VWorkspaceViewController *workspaceToShow = self.workspaceViewControllers[ self.currentWorkspaceIndex ];
        [self.flowNavigationController popToViewController:workspaceToShow animated:NO];
    }
    else
    {
        [self.flowNavigationController dismissViewControllerAnimated:YES completion:nil];
    }
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
    [self showNextWorkspace];
}

- (void)workspaceDidClose:(VWorkspaceViewController *)workspaceViewController
{
    [self showPreviousWorkspace];
}

@end
