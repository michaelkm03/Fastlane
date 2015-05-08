//
//  VWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import WebKit;

#import "VWebBrowserViewController.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VWebBrowserHeaderViewController.h"
#import "VSettingManager.h"
#import "VWebBrowserActions.h"
#import "VSequence+Fetcher.h"
#import "VConstants.h"
#import "VTracking.h"
#import "NSURL+VCustomScheme.h"
#import "UIColor+VBrightness.h"
#import "VNavigationController.h"
#import "UIView+AutoLayout.h"
#import "VWebBrowserHeaderLayoutManager.h"
#import "VDependencyManager+VWebBrowser.h"

typedef NS_ENUM( NSUInteger, VWebBrowserViewControllerState )
{
    VWebBrowserViewControllerStateComplete,
    VWebBrowserViewControllerStateLoading,
    VWebBrowserViewControllerStateFailed,
};

@interface VWebBrowserViewController() <WKNavigationDelegate, VWebBrowserHeaderViewDelegate, VWebBrowserHeaderStateDataSource, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) VWebBrowserViewControllerState loadingState;
@property (nonatomic, strong) VWebBrowserActions *actions;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSTimer *progressBarAnimationTimer;

@end

@implementation VWebBrowserViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *defaultLayout = VDependencyManagerWebBrowserLayoutHeaderTop;
    NSString *layoutIdentifier = [dependencyManager stringForKey:VDependencyManagerWebBrowserLayoutKey] ?: defaultLayout;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:layoutIdentifier];
    VWebBrowserViewController *webBrowserViewController = (VWebBrowserViewController *)viewController;
    webBrowserViewController.dependencyManager = dependencyManager;
    webBrowserViewController.layoutIdentifier = layoutIdentifier;
    
    NSString *templateUrlString = [dependencyManager stringForKey:VDependencyManagerWebURLKey];
    if ( templateUrlString != nil )
    {
        [webBrowserViewController loadUrlString:templateUrlString];
    }
    
    NSString *templateTitle = [dependencyManager stringForKey:VDependencyManagerTitleKey];
    if ( templateTitle != nil )
    {
        webBrowserViewController.templateTitle = templateTitle;
        webBrowserViewController.headerContentAlignment = VWebBrowserHeaderContentAlignmentCenter;
    }
    return webBrowserViewController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.actions = [[VWebBrowserActions alloc] init];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    /*
     To support opening new tabs, we have to be a UIDelegate, respond to the
        webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures: method and,
        when asked to load a url that isn't aimed at our current targetFrame, load it in our
        WKWebView instead.
     */
    self.webView.UIDelegate = self;
    
    [self.containerView addSubview:self.webView];
    [self.containerView v_addFitToParentConstraintsToSubview:self.webView];
    
    self.headerViewController.delegate = self;
    self.headerViewController.stateDataSource = self;
    
    if ( self.currentURL != nil )
    {
        [self loadUrl:self.currentURL];
    }
    
    self.headerViewController.title = self.templateTitle ?: NSLocalizedString( @"Loading...", @"" );
    
    [self updateHeaderLayuout];
}

- (void)setLayoutIdentifier:(NSString *)layoutIdentifier
{
    _layoutIdentifier = layoutIdentifier;
    
    [self updateHeaderLayuout];
}

- (void)setTemplateTitle:(NSString *)templateTitle
{
    _templateTitle = templateTitle;
    self.title = _templateTitle;
}

- (void)updateHeaderLayuout
{
    self.headerViewController.layoutManager.contentAlignment = self.headerContentAlignment;
    if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutHeaderTop] )
    {
        self.headerViewController.layoutManager.progressBarAlignment = VWebBrowserHeaderProgressBarAlignmentBottom;
    }
    if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutHeaderBottom] )
    {
        self.headerViewController.layoutManager.progressBarAlignment = VWebBrowserHeaderProgressBarAlignmentTop;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( self.sequence != nil )
    {
        // Track view-start event, similar to how content is tracking in VNewContentViewController when loaded
        NSDictionary *params = @{ VTrackingKeyTimeCurrent : [NSDate date],
                                  VTrackingKeySequenceId : self.sequence.remoteId,
                                  VTrackingKeyUrls : self.sequence.tracking.viewStart ?: @[] };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
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

- (BOOL)v_prefersNavigationBarHidden
{
    return self.layoutIdentifier == VDependencyManagerWebBrowserLayoutHeaderTop;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIColor *navBarBackgroundColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerBackgroundColorKey];
    switch ( [navBarBackgroundColor v_colorLuminance] )
    {
        case VColorLuminanceBright:
            return UIStatusBarStyleDefault;
        case VColorLuminanceDark:
            return UIStatusBarStyleLightContent;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController isKindOfClass:[VWebBrowserHeaderViewController class]] )
    {
        self.headerViewController = (VWebBrowserHeaderViewController *)segue.destinationViewController;
        self.headerViewController.dependencyManager = [self.dependencyManager dependencyManagerForNavigationBar];
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
    
    [self.headerViewController.layoutManager updateAnimated:YES];
}

#pragma mark - Data source

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    [self loadUrlString:_sequence.webContentUrl];
}

#pragma mark - Title

- (void)setTitle:(NSString *)title
{
    if ( self.templateTitle != nil )
    {
        if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutHeaderBottom] )
        {
            self.headerViewController.title = nil;
            super.title = self.templateTitle;
        }
        else
        {
            self.headerViewController.title = self.templateTitle;
            super.title = self.templateTitle;
        }
    }
    else
    {
        self.headerViewController.title = title;
    }
}

- (void)updateTitle
{
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id result, NSError *error)
     {
         if ( !error && [result isKindOfClass:[NSString class]] )
         {
             self.title = result;
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
    
    self.loadingState = VWebBrowserViewControllerStateComplete;
    [self updateTitle];
    [self.headerViewController.layoutManager updateAnimated:YES];
    [self.progressBarAnimationTimer invalidate];
    [self webViewDidUpdateProgress:1.0f];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.loadingState = VWebBrowserViewControllerStateFailed;
    [self updateTitle];
    [self.progressBarAnimationTimer invalidate];
    [self webViewDidUpdateProgress:-1.0f];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.loadingState = VWebBrowserViewControllerStateLoading;
    [self.headerViewController.layoutManager updateAnimated:YES];
    
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
    if ( [navigationAction.request.URL v_hasCustomScheme] )
    {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler( WKNavigationActionPolicyCancel );
    }
    else
    {
        decisionHandler( WKNavigationActionPolicyAllow );
    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if ( !navigationAction.targetFrame.isMainFrame )
    {
        //The webView wants to load a request in a new tab / window, load it in our webView instead
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - VWebBrowserHeaderStateDataSource

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
    return self.currentURL != nil && self.loadingState != VWebBrowserViewControllerStateLoading;
}

#pragma mark - VWebBrowserHeaderView

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
