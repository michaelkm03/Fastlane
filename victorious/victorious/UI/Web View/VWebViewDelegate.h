//
//  VWebViewDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWebViewDelegate : NSObject <UIWebViewDelegate>

- (void)loadUrl:(NSURL *)url withWebView:(UIWebView *)webView;

- (void)loadUrlString:(NSString *)urlString withWebView:(UIWebView *)webView;

@property (nonatomic, assign) BOOL shouldShowLoadingState;

@end
