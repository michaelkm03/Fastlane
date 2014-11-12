//
//  VWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebBrowserViewController.h"
#import "VWebBrowserHeaderViewController.h"
#import "VSettingManager.h"
#import "VWebViewFactory.h"
#import "VWebBrowserActions.h"
#import "VSequence+Fetcher.h"

typedef enum {
    VWebBrowserViewControllerStateComplete,
    VWebBrowserViewControllerStateLoading,
    VWebBrowserViewControllerStateFailed,
} VWebBrowserViewControllerState;

@interface VWebBrowserViewController() <VWebViewDelegate, VWebBrowserHeaderViewDelegate>

@property (nonatomic, strong) id<VWebViewProtocol> webView;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) VWebBrowserViewControllerState state;
@property (nonatomic, strong) VWebBrowserActions *actions;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) VWebBrowserHeaderViewController *headerViewController;

@end

@implementation VWebBrowserViewController

+ (VWebBrowserViewController *)instantiateFromStoryboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:nil];
    return [storyboard instantiateInitialViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.actions = [[VWebBrowserActions alloc] init];
    
    self.headerViewController.browserDelegate = self;
    
    self.webView = [VWebViewFactory createWebView];
    self.webView.delegate = self;
    [self.containerView addSubview:self.webView.asView];
    
    NSDictionary *views = @{ @"webView" : self.webView.asView };
    self.webView.asView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
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
    
    [self.webView evaluateJavaScript:@"window.location.href" completionHandler:^(id result, NSError *error)
     {
         if ( !error && [result isKindOfClass:[NSString class]] )
         {
             [self.headerViewController setSubtitle:result];
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

#pragma mark - VWebViewDelegate

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.state = VWebBrowserViewControllerStateLoading;
    [self.headerViewController updateHeaderState];
}

- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.state = VWebBrowserViewControllerStateComplete;
    [self.headerViewController updateHeaderState];
    [self updateWebViewPageInfo];
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.state = VWebBrowserViewControllerStateFailed;
    [self updateWebViewPageInfo];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
    if ( !webView.isProgressSupported )
    {
        return;
    }
    
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
    NSString *shareText = [self.webView canGoBack] ? nil : self.sequence.name;
    
    [self.actions showInViewController:self withCurrentUrl:self.currentURL text:shareText];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
