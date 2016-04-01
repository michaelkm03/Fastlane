//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import WebKit;

#import "VTOSViewController.h"
#import "victorious-swift.h"

@implementation VTOSViewController

+ (VTOSViewController *)termsOfServiceViewController
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings"
                                                         bundle:bundleForClass];
    VTOSViewController *termsOfServiceVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VTOSViewController class])];
    termsOfServiceVC.title = NSLocalizedString(@"Terms of Service", @"");
    return termsOfServiceVC;
}

+ (UIViewController *)presentableTermsOfServiceViewController
{
    VTOSViewController *tosViewController = [self termsOfServiceViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tosViewController];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:tosViewController action:@selector(pressedBack)];
    tosViewController.navigationItem.leftBarButtonItem = dismissButton;
    return navigationController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldShowLoadingState = YES;
    
    [self loadTermsOfService];
}

- (void)pressedBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
