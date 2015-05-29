//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

@import WebKit;

#import "VTOSViewController.h"
#import "VObjectManager+Websites.h"

@implementation VTOSViewController

+ (VTOSViewController *)termsOfServiceViewController
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings"
                                                         bundle:bundleForClass];
    VTOSViewController *termsOfServiceVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VTOSViewController class])];
    termsOfServiceVC.title = NSLocalizedString(@"ToSText", @"");
    return termsOfServiceVC;
}

+ (UIViewController *)presentableTermsOfServiceViewController
{
    VTOSViewController *tosViewController = [self termsOfServiceViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tosViewController];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:tosViewController action:@selector(pressedBack)];
    tosViewController.navigationItem.leftBarButtonItem = dismissButton;
    return navigationController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem.leftBarButtonItem == nil)
    {
        //Need to create a fake "back" button so that we can get off of this screen
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButton", @"") style:UIBarButtonItemStylePlain target:self action:@selector(pressedBack)];
        [backButton setTintColor:[UIColor blackColor]];
        [self.navigationItem setLeftBarButtonItem:backButton];

    }
    
    self.shouldShowLoadingState = YES;
    
    [[VObjectManager sharedManager] fetchToSWithCompletionBlock:^(NSOperation *completion, NSString *htmlString, NSError *error)
    {
        if ( !error )
        {
            [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.victorious.com/"]];
        }
        else
        {
            [self setFailureWithError:error];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)pressedBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
