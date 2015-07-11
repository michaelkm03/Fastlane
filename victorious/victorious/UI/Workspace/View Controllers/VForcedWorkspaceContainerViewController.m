//
//  VForcedWorkspaceContainerViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VForcedWorkspaceContainerViewController.h"
#import "VTextWorkspaceFlowController.h"

@interface VForcedWorkspaceContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) VDependencyManager *dependencyManager;

@end

@implementation VForcedWorkspaceContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VTextWorkspaceFlowController *flow = [VTextWorkspaceFlowController textWorkspaceFlowControllerWithDependencyManager:self.dependencyManager];
    
    [self addChildViewController:flow.flowRootViewController];
    [self.containerView addSubview:flow.flowRootViewController.view];
    flow.flowRootViewController.view.frame = self.containerView.frame;
    [flow.flowRootViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentedViewController == nil)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.presentedViewController == nil)
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

@end
