//
//  VWebViewProtocol.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@protocol VWebViewProtocol;

@protocol VWebViewDelegate <NSObject>

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView;
- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView;
- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress;

@end

/**
 Convenience function for create the appropriate webview depending on system OS version
 */
extern id<VWebViewProtocol> createGenericWebView();

/**
 A protocol to which both UIWebView (<= iOS 7) and WKWebView (>= iOS 8) can conform
 in order to provide a similar experience for both OS versions.
 */
@protocol VWebViewProtocol <NSObject>

@property (nonatomic, readonly, assign) BOOL isProgressSupported;
@property (nonatomic, readonly) UIView *asView;
@property (nonatomic, weak) id<VWebViewDelegate> delegate;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)goBack;
- (void)goForward;
- (void)stopLoading;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (void)reload;

@end