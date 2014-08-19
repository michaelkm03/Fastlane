//
//  VTOSViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VTOSViewController.h"

#import "VObjectManager+Websites.h"

@interface VTOSViewController ()    <UIWebViewDelegate>
@end

@implementation VTOSViewController

- (void)awakeFromNib
{
    self.wantsStatusBar = YES;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activitiyIndicator startAnimating];
    [[VObjectManager sharedManager] fetchToSWithCompletionBlock:^(NSOperation *completion, NSString *htmlString, NSError *error) {
        [self.activitiyIndicator stopAnimating];
        if (error) {
            [self webView:self.webView didFailLoadWithError:error];
            return;
        }
        
        [self.webView loadHTMLString:htmlString
                             baseURL:nil];
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
