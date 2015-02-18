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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [self.navigationController viewControllers].count == 1 )
    {
        //Need to create a fake "back" button so that we can get off of this screen
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(pressedBack)];
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
