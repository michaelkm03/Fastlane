//
//  VWebContentViewController.m
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebContentViewController.h"
#import "UIViewController+VNavMenu.h"
#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VWebViewAdvanced.h"
#import "VWebViewBasic.h"

@interface VWebContentViewController () <VNavigationHeaderDelegate, VWebViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VWebContentViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if ( NSClassFromString( @"WKWebView" ) != nil )
    {
        self.webView = [[VWebViewAdvanced alloc] init];
    }
    else
    {
        self.webView = [[VWebViewBasic alloc] init];
    }
    
    self.webView.asView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView.asView];
    self.webView.delegate = self;
    
    self.urlToView = self.urlToView;
    
    [self addHeader];
}

- (void)addHeader
{
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    [self addConstraintsToWebView:self.webView.asView withHeaderView:self.navHeaderView];
}

- (void)addConstraintsToWebView:(UIWebView *)webView withHeaderView:(UIView *)headerView
{
    NSParameterAssert( webView.superview != nil );
    NSParameterAssert( headerView.superview != nil );
    NSParameterAssert( [webView.superview isEqual:headerView.superview] );
    
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:headerView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:0.0f]];
    NSDictionary *viewsDict = @{ @"webView" : webView };
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[webView]-0-|" options:kNilOptions metrics:nil views:viewsDict]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:kNilOptions metrics:nil views:viewsDict]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    
    [[VThemeManager sharedThemeManager] applyNormalNavBarStyling];
}

- (void)setShouldShowLoadingState:(BOOL)shouldShowLoadingState
{
    _shouldShowLoadingState = shouldShowLoadingState;
    if ( _shouldShowLoadingState )
    {
        [self.activityIndicator startAnimating];
    }
    else
    {
        [self.activityIndicator stopAnimating];
    }
}

- (void)setUrlToView:(NSURL *)urlToView
{
    _urlToView = urlToView;
    
    if ( _urlToView != nil )
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:_urlToView]];
        
        if ( !self.activityIndicator )
        {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.webView.asView.superview addSubview:self.activityIndicator];
            self.activityIndicator.hidesWhenStopped = YES;
        }
        self.activityIndicator.center = self.webView.asView.superview.center;
        [self.activityIndicator startAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
    
    self.webView.delegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

#pragma mark - VWebViewDelegate

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
}

@end


