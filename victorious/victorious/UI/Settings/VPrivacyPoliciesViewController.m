//
//  VPrivacyPoliciesViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VPrivacyPoliciesViewController.h"
#import "VDependencyManager.h"
#import "victorious-swift.h"

@implementation VPrivacyPoliciesViewController

+ (UIViewController *)presentableTermsOfServiceViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VPrivacyPoliciesViewController *tosViewController = [[self alloc] initWithNibName:nil bundle:nil];
    tosViewController.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tosViewController];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:tosViewController action:@selector(cancel)];
    tosViewController.navigationItem.leftBarButtonItem = dismissButton;
    tosViewController.dependencyManager = dependencyManager;
    tosViewController.title = NSLocalizedString(@"Privacy Policy", nil);
    return navigationController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldShowLoadingState = YES;
    
    [self loadPrivacyPolicy];
}

#pragma mark - Actions

- (void)cancel
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
