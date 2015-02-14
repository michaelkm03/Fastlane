//
//  VWebViewDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@class VWebView;

@protocol VWebViewDelegate <NSObject>

- (void)webViewDidStartLoad:(VWebView *)webView;
- (void)webViewDidFinishLoad:(VWebView *)webView;
- (void)webView:(VWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(VWebView *)webView didUpdateProgress:(float)progress;

@end