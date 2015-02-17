//
//  VWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import WebKit;

#import "VWebBrowserViewController.h"
#import "VWebBrowserHeaderViewController.h"
#import "VSettingManager.h"
#import "VWebBrowserActions.h"
#import "VSequence+Fetcher.h"
#import "VConstants.h"

typedef NS_ENUM( NSUInteger, VWebBrowserViewControllerState )
{
    VWebBrowserViewControllerStateComplete,
    VWebBrowserViewControllerStateLoading,
    VWebBrowserViewControllerStateFailed,
};

@interface VWebBrowserViewController() <WKNavigationDelegate, VWebBrowserHeaderViewDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) VWebBrowserViewControllerState state;
@property (nonatomic, strong) VWebBrowserActions *actions;
@property (nonatomic, weak) VWebBrowserHeaderViewController *headerViewController;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerViewX1Constraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerViewX2Constraint;

@property (nonatomic, strong) NSTimer *progressBarAnimationTimer;

@end

@implementation VWebBrowserViewController

+ (VWebBrowserViewController *)instantiateFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:[NSBundle mainBundle]];
    return [storyboard instantiateInitialViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.actions = [[VWebBrowserActions alloc] init];
    
    self.headerViewController.browserDelegate = self;
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    [self.containerView addSubview:self.webView];
    
    NSDictionary *views = @{ @"webView" : self.webView };
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:views]];
    
    if ( self.currentURL != nil )
    {
        [self loadUrl:self.currentURL];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"embedHeader"] && [segue.destinationViewController isKindOfClass:[VWebBrowserHeaderViewController class]] )
    {
        self.headerViewController = (VWebBrowserHeaderViewController *)segue.destinationViewController;
    }
}

- (void)updateProgressFromTimer
{
    [self webViewDidUpdateProgress:self.webView.estimatedProgress];
}

- (void)webViewDidUpdateProgress:(CGFloat)progress
{
    if ( progress == 0.0f )
    {
        [self.headerViewController setLoadingStarted];
    }
    else if ( progress < 0.0f )  // This is when an error has occurred
    {
        BOOL didFail = YES;
        [self.headerViewController setLoadingComplete:didFail];
    }
    else if ( progress == 1.0f )
    {
        BOOL didFail = NO;
        [self.headerViewController setLoadingComplete:didFail];
    }
    else
    {
        [self.headerViewController setLoadingProgress:progress];
    }
}

#pragma mark - Data source

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    [self loadUrlString:_sequence.webContentUrl];
}

#pragma mark - Helpers

- (void)updateWebViewPageInfo
{
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error)
     {
         if ( !error && [result isKindOfClass:[NSString class]] )
         {
             [self.headerViewController setTitle:result];
         }
     }];
}

#pragma mark - Public API

- (void)loadUrl:(NSURL *)url
{
    self.currentURL = url;
    if ( self.webView != nil )
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)loadUrlString:(NSString *)urlString
{
    [self loadUrl:[NSURL URLWithString:urlString]];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.state = VWebBrowserViewControllerStateComplete;
    [self.headerViewController updateHeaderState];
    [self updateWebViewPageInfo];
    [self.progressBarAnimationTimer invalidate];
    [self webViewDidUpdateProgress:1.0f];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.state = VWebBrowserViewControllerStateFailed;
    [self updateWebViewPageInfo];
    [self.progressBarAnimationTimer invalidate];
    [self webViewDidUpdateProgress:-1.0f];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.state = VWebBrowserViewControllerStateLoading;
    [self.headerViewController updateHeaderState];
    
    [self webViewDidUpdateProgress:0.0f];
    [self.progressBarAnimationTimer invalidate];
    self.progressBarAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                                      target:self
                                                                    selector:@selector(updateProgressFromTimer)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ( [navigationAction.request.URL.scheme.lowercaseString rangeOfString:@"http"].location != 0 )
    {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler( WKNavigationActionPolicyCancel );
    }
    else
    {
        decisionHandler( WKNavigationActionPolicyAllow );
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
    // Only provide share text if this is the root of the navigation history,
    // i.e. the original announcement itself.
    NSString *shareTextTitle = [self.webView canGoBack] ? nil : self.sequence.name;
    NSString *shareTextDescription = [self.webView canGoBack] ? nil : self.sequence.sequenceDescription;
    
    [self.actions showInViewController:self withCurrentUrl:self.currentURL titleText:shareTextTitle descriptionText:shareTextDescription];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
