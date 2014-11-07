//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VTOSViewController.h"
#import "VObjectManager+Websites.h"

@implementation VTOSViewController

- (void)awakeFromNib
{
    self.wantsStatusBar = YES;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldShowLoadingState = YES;
    
    [[VObjectManager sharedManager] fetchToSWithCompletionBlock:^(NSOperation *completion, NSString *htmlString, NSError *error)
    {
        if ( !error )
        {
            [self.webView loadHTMLString:htmlString baseURL:nil];
        }
        else
        {
            [self setFailureWithError:error];
        }
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return !self.wantsStatusBar;
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
