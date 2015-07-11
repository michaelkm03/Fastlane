//
//  VForcedWorkspaceContainerViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VForcedWorkspaceContainerViewController.h"

@interface VForcedWorkspaceContainerViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation VForcedWorkspaceContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.textWorkspaceViewController];
    [self.containerView addSubview:self.textWorkspaceViewController.view];
    self.textWorkspaceViewController.view.frame = self.containerView.frame;
    [self.textWorkspaceViewController didMoveToParentViewController:self];
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
