//
//  VWebContentViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebContentViewController.h"
#import "VThemeManager.h"

@interface VWebContentViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView* webView;
@end

@implementation VWebContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate    =   self;
    
    NSURL*  webContentURL  =   [[VThemeManager sharedThemeManager] themedURLForKey:self.urlKeyPath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:webContentURL]];
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

@end


