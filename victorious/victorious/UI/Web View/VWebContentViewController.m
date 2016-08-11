//
//  VWebContentViewController.m
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import WebKit;

#import "VWebContentViewController.h"

@interface VWebContentViewController () <WKNavigationDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VWebContentViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] init];
    
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    
    self.urlToView = self.urlToView;
    [self addConstraintsToWebView:self.webView];
    
    if (self.shouldShowNavigationButtons) {
        [self configureNavigationButtons];
    }
    
    
}

- (void)setFailureWithError:(NSError *)error
{
    [self webView:self.webView didFailNavigation:nil withError:error];
}

- (void)addConstraintsToWebView:(UIView *)webView
{
    NSParameterAssert( webView.superview != nil );
    
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [webView.superview addConstraint:[NSLayoutConstraint constraintWithItem:webView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.topLayoutGuide
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    [webView.superview addConstraint:[NSLayoutConstraint constraintWithItem:webView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.bottomLayoutGuide
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(webView)]];
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
            [self.webView.superview addSubview:self.activityIndicator];
            self.activityIndicator.hidesWhenStopped = YES;
        }
        self.activityIndicator.center = self.webView.superview.center;
        [self.activityIndicator startAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
    
    self.webView.navigationDelegate = nil;    // disconnect the delegate as the webview is hidden
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Actions

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
