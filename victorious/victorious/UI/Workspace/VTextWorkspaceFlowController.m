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

@interface VTextWorkspaceFlowController() <UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *flowNavigationController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

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
        
        VWorkspaceViewController *workspaceViewController = (VWorkspaceViewController *)[self.dependencyManager viewControllerForKey:VDependencyManagerTextWorkspaceKey];
#warning Testing with random text
        workspaceViewController.text = [self randomSampleText];
        workspaceViewController.continueText = NSLocalizedString( @"Next", @"" );
        [self.flowNavigationController pushViewController:workspaceViewController animated:NO];
    }
    return self;
}

- (NSString *)randomSampleText
{
    NSArray *randomText = @[ @"Here is my sample text!  222 ",
                             @"Here is my sample text that should span onto two lines. 2 2 2",
                             @"Here is my sample text that is quite long and is intended to span onto at least three lines so we can see how it looks." ];
    return randomText[ arc4random() % randomText.count ];
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
