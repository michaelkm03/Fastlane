//
//  VAboutUsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VAboutUsViewController.h"
#import "VThemeManager.h"

@interface VAboutUsViewController ()    <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *aboutUsWebView;
@end

@implementation VAboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.aboutUsWebView.delegate    =   self;
    
    NSURL*  aboutUsURL  =   [[VThemeManager sharedThemeManager] themedURLForKeyPath:kVSettingsAboutUsURL];
    [self.aboutUsWebView loadRequest:[NSURLRequest requestWithURL:aboutUsURL]];
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
    NSString* errorString = @"<html><center><font size=+5 color='red'>About Page</font></center></html>";
    [self.aboutUsWebView loadHTMLString:errorString baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.aboutUsWebView stopLoading];

    self.aboutUsWebView.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
