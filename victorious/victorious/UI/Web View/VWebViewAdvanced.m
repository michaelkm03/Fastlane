//
//  VWebViewAdvanced.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewAdvanced.h"

@interface VWebViewAdvanced() <WKNavigationDelegate>

@property (nonatomic, strong) NSTimer *progressBarAnimationTimer;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation VWebViewAdvanced

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

#pragma mark - UIWebViewProtocol

- (UIView *)asView
{
    return self.webView;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)loadURL:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)goForward
{
    [self.webView goForward];
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
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.delegate webView:self didFailLoadWithError:error];
    
    [self.progressBarAnimationTimer invalidate];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.delegate webViewDidStartLoad:self];
    
    [self updateProgress];
    if ( [self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)] )
    {
        self.progressBarAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
}

@end
