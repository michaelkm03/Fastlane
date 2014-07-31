//
//  VWebContentViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebContentViewController.h"
#import "VThemeManager.h"

@interface VWebContentViewController ()
@property (weak, nonatomic) IBOutlet UIWebView* webView;
@end

@implementation VWebContentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
    
    self.webView.delegate    =   self;
    if (self.htmlString)
    {
        [self.webView loadHTMLString:self.htmlString baseURL:nil];
    }
    else if (self.urlKeyPath)
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.urlKeyPath]];
    }
}

- (void)setHtmlString:(NSString *)htmlString
{
    if ([_htmlString isEqualToString:htmlString])
        return;
    
    _htmlString = htmlString;
    [self.webView loadHTMLString:_htmlString baseURL:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // report the error inside the webview
    NSString* errorString = @"<html><center><font size=+5 color='red'>Failed To Load Page</font></center></html>";
    [self.webView loadHTMLString:errorString baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    
    self.webView.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end


