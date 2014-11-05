//
//  VWebContentViewController.m
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebContentViewController.h"
#import "VThemeManager.h"

#import "UIViewController+VNavMenu.h"
#import "VSettingManager.h"

@interface VWebContentViewController () <VNavigationHeaderDelegate>

@end

@implementation VWebContentViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webViewDelegate = [[VWebViewDelegate alloc] init];
    
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    self.webView.delegate = self.webViewDelegate;
    
    [self addConstraintsToWebView:self.webView withHeaderView:self.navHeaderView];
    
    self.urlToView = self.urlToView;
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

- (void)setUrlToView:(NSURL *)urlToView
{
    _urlToView = urlToView;
    [self.webViewDelegate loadUrl:urlToView withWebView:self.webView];
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

@end


