//
//  VWorkspaceViewController.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWorkspaceViewController.h"

// Dependency Management
#import "VDependencyManager+VWorkspaceTool.h"

// Views
#import <MBProgressHUD/MBProgressHUD.h>

@interface VWorkspaceViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSArray *tools;

@end

@implementation VWorkspaceViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VWorkspaceViewController *workspaceViewController = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    workspaceViewController.dependencyManager = dependencyManager;
    workspaceViewController.tools = [dependencyManager topLevelWorkspaceTools];
    return workspaceViewController;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - IBActions

- (IBAction)close:(id)sender
{
    self.completionBlock(NO, nil);
}

- (IBAction)publish:(id)sender
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view
                                                     animated:YES];
    hudForView.labelText = @"Publishing...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [MBProgressHUD hideHUDForView:self.view
                             animated:YES];
        self.completionBlock(YES, nil);
    });
}

@end
