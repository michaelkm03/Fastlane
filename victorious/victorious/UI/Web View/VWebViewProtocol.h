//
//  VWebViewAdapter.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VWebViewProtocol;

@protocol VWebViewDelegate <NSObject>

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView;
- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView;
- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error;

@optional
- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress;

@end


@protocol VWebViewProtocol <NSObject>

@property (nonatomic, readonly, assign) BOOL isProgressSupported;
@property (nonatomic, readonly) UIView *asView;
@property (nonatomic, strong) id<VWebViewDelegate> delegate;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)goBack;
- (void)goForward;
- (void)stopLoading;
- (BOOL)canGoBack;
- (BOOL)canGoForward;

@optional

- (void)reload;
- (void)stopLoading;

@end