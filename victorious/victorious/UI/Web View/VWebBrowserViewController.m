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
#import "VWebViewCreator.h"
#import "VWebBrowserActions.h"
#import "VSequence+Fetcher.h"

typedef enum {
    VWebBrowserViewControllerStateComplete,
    VWebBrowserViewControllerStateLoading,
    VWebBrowserViewControllerStateFailed,
} VWebBrowserViewControllerState;

@interface VWebBrowserViewController() <VWebViewDelegate, VWebBrowserHeaderViewDelegate>

@property (nonatomic, strong) id<VWebViewProtocol> webView;
@property (nonatomic, strong) IBOutlet VWebBrowserHeaderView *headerView;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) VWebBrowserViewControllerState state;
@property (nonatomic, strong) VWebBrowserActions *actions;

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
    
    self.actions = [[VWebBrowserActions alloc] init];
    
    self.headerView.browserDelegate = self;
    
    self.webView = [VWebViewCreator createWebView];
    self.webView.delegate = self;
    [self.view addSubview:self.webView.asView];
    [self.view sendSubviewToBack:self.webView.asView];
    
    if ( self.currentURL != nil )
    {
        [self loadUrl:self.currentURL];
    }
    
    [self addConstraintsToWebView:self.webView.asView withHeaderView:self.headerView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
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

#pragma mark - Data source

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    [self loadUrlString:_sequence.webContentUrl];
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
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    self.state = VWebBrowserViewControllerStateLoading;
    [self.headerView updateHeaderState];
}

- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.state = VWebBrowserViewControllerStateComplete;
    [self.headerView updateHeaderState];
    [self updateHeaderView:self.headerView withWebView:webView];
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.state = VWebBrowserViewControllerStateFailed;
    [self.headerView updateHeaderState];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
    if ( !webView.isProgressSupported )
    {
        return;
    }
    
    if ( progress == 0.0f )
    {
        [self.headerView setLoadingStarted];
    }
    else if ( progress < 0.0f )  // This is when an error has occurred
    {
        BOOL didFail = YES;
        [self.headerView setLoadingComplete:didFail];
    }
    else if ( progress == 1.0f )
    {
        BOOL didFail = NO;
        [self.headerView setLoadingComplete:didFail];
    }
    else
    {
        [self.headerView setLoadingProgress:progress];
    }
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

- (BOOL)canRefresh
{
    return self.currentURL != nil && self.state != VWebBrowserViewControllerStateLoading;
}

- (void)goForward
{
    [self.webView goForward];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)reload
{
    [self.webView reload];
}

- (void)export
{
    [self.actions showInViewController:self withSequence:self.sequence];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
