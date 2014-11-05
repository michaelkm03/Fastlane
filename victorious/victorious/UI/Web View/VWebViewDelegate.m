//
//  VWebViewDelegate.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewDelegate.h"

@interface VWebViewDelegate()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSURL *urlCurrent;
@property (nonatomic, strong) NSURL *urlLoading;

@end

@implementation VWebViewDelegate

- (void)setShouldShowLoadingState:(BOOL)shouldShowLoadingState
{
    _shouldShowLoadingState = shouldShowLoadingState;
    if ( _shouldShowLoadingState )
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
}

- (void)loadUrlString:(NSString *)urlString withWebView:(UIWebView *)webView
{
    [self loadUrl:[NSURL URLWithString:urlString] withWebView:webView];
}

- (void)loadUrl:(NSURL *)url withWebView:(UIWebView *)webView
{
    NSParameterAssert( webView != nil );
    NSParameterAssert( [webView isKindOfClass:[UIWebView class]] );
    
    if ( url != nil && ![url isEqual:self.urlCurrent] )
    {
        self.urlLoading = url;
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        if ( !self.activityIndicator )
        {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityIndicator.hidesWhenStopped = YES;
            self.activityIndicator.center = webView.superview.center;
            [self.activityIndicator startAnimating];
            [webView.superview addSubview:self.activityIndicator];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    
    self.urlCurrent = self.urlLoading;
    self.urlLoading = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
}

@end
