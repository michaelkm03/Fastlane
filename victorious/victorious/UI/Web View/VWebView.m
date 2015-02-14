//
//  VWebView.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MessageUI;

#import "VWebView.h"

static NSString * const kMailToPrefix = @"mailto";
static NSString * const kITunesPrefix = @"http://itunes.apple.com";
static NSString * const kITunesPrefixSSL = @"https://itunes.apple.com";

@interface VWebView() <WKNavigationDelegate>

@property (nonatomic, strong) NSTimer *progressBarAnimationTimer;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation VWebView

@synthesize delegate;

#pragma mark - VWebViewProtocol

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.webView = [[WKWebView alloc] init];
        self.webView.navigationDelegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self.progressBarAnimationTimer invalidate];
}

- (void)updateProgress
{
    [self.delegate webView:self didUpdateProgress:self.webView.estimatedProgress];
}

#pragma mark - Public methods

- (UIView *)asView
{
    return self.webView;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)loadRequest:(NSURLRequest *)request
{
#warning delete this, testing only:
    //[self loadHTMLString:nil baseURL:nil];
    [self.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
#warning delete this, testing only:
    //string = @"<a href=\"https://itunes.apple.com/us/app/escape-run/id555012306?mt=8\" style=\"font-size: 50px;\">LINK</a>";
    //baseURL = [NSURL URLWithString:@"http://www.apple.com"];
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.delegate webViewDidFinishLoad:self];
    [self.progressBarAnimationTimer invalidate];
    [self.delegate webView:self didUpdateProgress:1.0f];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.delegate webView:self didFailLoadWithError:error];
    [self.progressBarAnimationTimer invalidate];
    [self.delegate webView:self didUpdateProgress:-1.0f];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.delegate webViewDidStartLoad:self];
    [self.delegate webView:self didUpdateProgress:0.0f];
    self.progressBarAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                                      target:self
                                                                    selector:@selector(updateProgress)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ( [self shouldURLInSafari:navigationAction.request.URL] )
    {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler( WKNavigationActionPolicyCancel );
    }
    else
    {
        decisionHandler( WKNavigationActionPolicyAllow );
    }
}

#pragma mark - Helpers

- (BOOL)shouldURLInSafari:(NSURL *)url
{
    __block BOOL output = NO;
    
    NSString *urlString = url.absoluteString;
    [@[ kMailToPrefix, kITunesPrefix, kITunesPrefixSSL ] enumerateObjectsUsingBlock:^(NSString *prefix, NSUInteger idx, BOOL *stop)
    {
        if ( [urlString rangeOfString:prefix].location == 0 )
        {
            output = YES;
            *stop = YES;
        }
    }];
    
    return output;
}

@end
