//
//  VStreamWebViewController.m
//  victorious
//
//  Created by Patrick Lynch on 1/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import WebKit;

#import "VStreamWebViewController.h"
#import "UIView+Autolayout.h"
#import "VThemeManager.h"

static const NSTimeInterval kWebViewFirstLoadAnimationDelay      = 0.0f;
static const NSTimeInterval kWebViewFirstLoadAnimationDuration   = 0.5f;

@interface VStreamWebViewController() <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VStreamWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.view.backgroundColor = backgroundColor;
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    self.webView.userInteractionEnabled = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];
    [self.view v_addFitToParentConstraintsToSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.activityIndicator];
    [self.view v_addCenterToParentContraintsToSubview:self.activityIndicator];
    
    // The webview should start off hidden before first load to prevent an ugly white background from showing
    self.webView.alpha = 0.0;
}

- (void)setUrl:(NSURL *)url
{
    if ( url == nil || [_url isEqual:url] )
    {
        // Don't reload the same URL
        return;
    }
    
    BOOL hadPreviousContent = _url != nil;
    
    _url = url;
    
    if ( _url != nil )
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
        if ( hadPreviousContent )
        {
            // Loaded a url previously, need to call reload to cause the new "loadRequest" to load
            // Also reset the alpha of the webview back to 0.0 to show the proper loading animation
            self.webView.alpha = 0.0f;
            [self.webView reload];
        }
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.activityIndicator stopAnimating];
    
    [UIView animateWithDuration:kWebViewFirstLoadAnimationDuration delay:kWebViewFirstLoadAnimationDelay options:kNilOptions animations:^
     {
         self.webView.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         if ( self.delegate != nil )
         {
             [self.delegate streamWebViewControllerContentIsVisible];
         }
         
     }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.activityIndicator startAnimating];
}

@end
