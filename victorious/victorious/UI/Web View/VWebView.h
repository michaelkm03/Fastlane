//
//  VWebView.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebView.h"
#import "VWebViewDelegate.h"

@import UIKit;
@import WebKit;

@interface VWebView : NSObject

@property (nonatomic, weak) id<VWebViewDelegate> delegate;

- (UIView *)asView;

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
