//
//  VWebBrowserViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import WebKit;

#import "VWebBrowserViewController.h"
#import "VDependencyManager+NavigationBar.h"
#import "VWebBrowserHeaderViewController.h"
#import "VWebBrowserActions.h"
#import "VSequence+Fetcher.h"
#import "VConstants.h"
#import "UIColor+VBrightness.h"
#import "VNavigationController.h"
#import "UIView+AutoLayout.h"
#import "VWebBrowserHeaderLayoutManager.h"
#import "VDependencyManager+VWebBrowser.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "victorious-Swift.h"

static NSString * const kURLKey = @"url";

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
    NSString *defaultLayout = VDependencyManagerWebBrowserLayoutTopNavigation;
    NSString *layoutIdentifier = [dependencyManager stringForKey:VDependencyManagerWebBrowserLayoutKey] ?: defaultLayout;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebBrowser" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:layoutIdentifier];
    VWebBrowserViewController *webBrowserViewController = (VWebBrowserViewController *)viewController;
    webBrowserViewController.dependencyManager = dependencyManager;
    webBrowserViewController.layoutIdentifier = layoutIdentifier;
    
    NSString *templateUrlString = [dependencyManager stringForKey:kURLKey];
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

    [self.v_navigationController setNavigationBarHidden:YES];
    self.headerViewController.layoutManager.exitButtonVisible = (self.presentingViewController != nil);
    
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
    
    self.title = NSLocalizedString( @"Loading...", @"" );
    
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
    if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutTopNavigation] )
    {
        self.headerViewController.layoutManager.progressBarAlignment = VWebBrowserHeaderProgressBarAlignmentBottom;
    }
    if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutBottomNavigation] )
    {
        self.headerViewController.layoutManager.progressBarAlignment = VWebBrowserHeaderProgressBarAlignmentTop;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Tracking code removed
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ( !self.isLandscapeOrientationSupported )
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return [super supportedInterfaceOrientations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [self.webView stopLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIColor *navigationBarTextColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
    return [StatusBarUtilities statusBarStyleWithColor:navigationBarTextColor];
}

- (BOOL)v_prefersNavigationBarHidden
{
    return [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutTopNavigation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController isKindOfClass:[VWebBrowserHeaderViewController class]] )
    {
        self.headerViewController = (VWebBrowserHeaderViewController *)segue.destinationViewController;
        self.headerViewController.dependencyManager = self.dependencyManager;
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
    if ( [self.layoutIdentifier isEqualToString:VDependencyManagerWebBrowserLayoutTopNavigation] )
    {
        if ( self.templateTitle != nil )
        {
            self.headerViewController.title = self.templateTitle;
            super.title = self.templateTitle;
        }
        else
        {
            self.headerViewController.title = title;
        }
    }
    else
    {
        self.headerViewController.title = nil;
        super.title = self.templateTitle;
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
        if ( url.scheme == nil ) //< WKWebView won't load a URL without a scheme
        {
            NSString *defaultScheme = @"http://";
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", defaultScheme, url.absoluteString]];
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
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

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // Add one single "OK" button
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    completionHandler();
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // Add a "Cancel" button
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action)
                                {
                                    completionHandler(NO);
                                }]];
    // Add a "OK" button
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    completionHandler(YES);
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // Add a input text field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = defaultText;
    }];
    
    // Add a "Cancel" button
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action)
                                {
                                    completionHandler(nil);
                                }]];
    // Add a "OK" button
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    UITextField *userInputTextField = alertController.textFields.firstObject;
                                    completionHandler(userInputTextField.text);
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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

- (void)exportURL
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
