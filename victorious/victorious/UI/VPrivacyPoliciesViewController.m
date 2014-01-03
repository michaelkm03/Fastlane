//
//  VPrivacyPoliciesViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VPrivacyPoliciesViewController.h"
#import "VThemeManager.h"

@interface VPrivacyPoliciesViewController ()    <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *privacyPoliciesWebView;
@end

@implementation VPrivacyPoliciesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.privacyPoliciesWebView.delegate    =   self;
    
    NSURL*  privacyPoliciesURL  =   [[VThemeManager sharedThemeManager] themedURLForKeyPath:kVChannelURLPrivacy];
    [self.privacyPoliciesWebView loadRequest:[NSURLRequest requestWithURL:privacyPoliciesURL]];
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
    NSString* errorString = @"<html><center><font size=+5 color='red'>Privacy Policies</font></center></html>";
    [self.privacyPoliciesWebView loadHTMLString:errorString baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.privacyPoliciesWebView stopLoading];
    
    self.privacyPoliciesWebView.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
