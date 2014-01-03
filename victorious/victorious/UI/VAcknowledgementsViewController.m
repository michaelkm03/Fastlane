//
//  VAcknowledgementsViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

#import "VAcknowledgementsViewController.h"
#import "VThemeManager.h"

@interface VAcknowledgementsViewController ()   <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *acknowledgementsWebView;
@end

@implementation VAcknowledgementsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.acknowledgementsWebView.delegate    =   self;
    
    NSURL*  acknowledgementURL  =   [[VThemeManager sharedThemeManager] themedURLForKey:kVSettingsAcknowledgementsURL];
    [self.acknowledgementsWebView loadRequest:[NSURLRequest requestWithURL:acknowledgementURL]];
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
    NSString* errorString = @"<html><center><font size=+5 color='red'>Acknowledgements</font></center></html>";
    [self.acknowledgementsWebView loadHTMLString:errorString baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.acknowledgementsWebView stopLoading];
    
    self.acknowledgementsWebView.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
