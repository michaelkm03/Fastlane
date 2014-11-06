//
//  VWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebBrowserViewController.h"
#import "VWebBrowserHeaderView.h"
#import "VSettingManager.h"
#import "VWebViewProtocol.h"

#define USE_WEBKIT = 1

#ifdef USE_WEBKIT
#import "VWebViewAdvanced.h"
#else
#import "VWebViewBasic.h"
#endif

@interface VWebBrowserViewController() <VWebViewDelegate, VWebBrowserHeaderViewDelegate>

@property (nonatomic, strong) id<VWebViewProtocol> webView;
@property (nonatomic, strong) IBOutlet VWebBrowserHeaderView *headerView;
@property (nonatomic, strong) NSURL *currentURL;

@end

@implementation VWebBrowserViewController

+ (VWebBrowserViewController *)instantiateFromNib
{
    return [[VWebBrowserViewController alloc] initWithNibName:@"VWebBrowserViewController" bundle:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerView.browserDelegate = self;
    
#ifdef USE_WEBKIT
    self.webView = [[VWebViewAdvanced alloc] init];
#else
    self.webView = [[VWebViewBasic alloc] init];
#endif

    self.webView.delegate = self;
    [self.view addSubview:self.webView.asView];
    [self.view sendSubviewToBack:self.webView.asView];
    
    if ( self.currentURL != nil )
    {
        [self loadUrl:self.currentURL];
    }
    
    [self addConstraintsToWebView:self.webView.asView withHeaderView:self.headerView];
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect( self.view.frame, self.headerView.frame );
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

#pragma mark - Helpers

- (void)addConstraintsToWebView:(UIView *)webView withHeaderView:(UIView *)headerView
{
    NSParameterAssert( webView.superview != nil );
    NSParameterAssert( headerView.superview != nil );
    NSParameterAssert( [webView.superview isEqual:headerView.superview] );
    
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:headerView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:0.0f]];
    NSDictionary *viewsDict = @{ @"webView" : webView };
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[webView]-0-|"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:viewsDict]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:viewsDict]];
}

- (void)updateHeaderView:(VWebBrowserHeaderView *)headerView withWebView:(id<VWebViewProtocol>)webView
{
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error)
     {
         if ( !error && [result isKindOfClass:[NSString class]] )
         {
             [headerView setTitle:result];
         }
     }];
    
    [webView evaluateJavaScript:@"window.location.href" completionHandler:^(id result, NSError *error)
     {
         if ( !error && [result isKindOfClass:[NSString class]] )
         {
             [headerView setSubtitle:result];
         }
     }];
}

#pragma mark - Public API

- (void)loadUrl:(NSURL *)url
{
    self.currentURL = url;
    if ( self.webView != nil )
    {
        [self.headerView setSubtitle:url.absoluteString];
        [self.webView loadURL:url];
    }
}

- (void)loadUrlString:(NSString *)urlString
{
    [self loadUrl:[NSURL URLWithString:urlString]];
}

#pragma mark - VWebViewDelegate

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.headerView updateHeaderState];
    [self.headerView setLoadingStarted];
}

- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.headerView updateHeaderState];
    
    [self updateHeaderView:self.headerView withWebView:webView];
    [self.headerView setLoadingComplete:NO];
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.headerView updateHeaderState];
    [self.headerView setLoadingComplete:YES];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
    [self.headerView setLoadingProgress:progress];
}

#pragma mark - VWebBrowserHeaderView

- (BOOL)canGoBack
{
    return [self.webView canGoBack];
}

- (BOOL)canGoForward
{
    return [self.webView canGoForward];
}

- (void)goForward
{
    [self.webView goForward];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)openInBrowser
{
    [[UIApplication sharedApplication] openURL:self.currentURL];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
