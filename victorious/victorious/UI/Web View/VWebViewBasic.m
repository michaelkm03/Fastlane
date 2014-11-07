//
//  VWebViewBasic.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewBasic.h"

@interface VWebViewBasic() <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation VWebViewBasic

@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.webView = [[UIWebView alloc] init];
        self.webView.scalesPageToFit = NO;
        self.webView.delegate = self;
    }
    return self;
}

#pragma mark - VWebViewProtocol

- (UIView *)asView
{
    return self.webView;
}

- (BOOL)isProgressSupported
{
    return YES;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString *output = [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
    completionHandler( output, nil );
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self.webView loadHTMLString:string baseURL:baseURL];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)goForward
{
    [self.webView goForward];
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

- (void)reload
{
    [self.webView reload];
}

- (BOOL)canGoBack
{
    return self.webView.canGoBack;
}

- (BOOL)canGoForward
{
    return self.webView.canGoForward;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.delegate webViewDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate webViewDidFinishLoad:self];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate webView:self didFailLoadWithError:error];
}

@end
