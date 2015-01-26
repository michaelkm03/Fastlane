//
//  VStreamWebViewController.m
//  victorious
//
//  Created by Patrick Lynch on 1/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamWebViewController.h"

#import "VStreamWebViewController.h"
#import "VThemeManager.h"
#import "VWebViewFactory.h"
#import "VSequence+Fetcher.h"

static const NSTimeInterval kWebViewFirstLoadAnimationDelay      = 0.0f;
static const NSTimeInterval kWebViewFirstLoadAnimationDuration   = 0.35f;

@interface VStreamWebViewController() <VWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, strong) id<VWebViewProtocol> webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation VStreamWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.view.backgroundColor = backgroundColor;
    
    self.webView = [VWebViewFactory createWebView];
    self.webView.delegate = self;
    self.webView.asView.userInteractionEnabled = NO;
    self.webView.asView.backgroundColor = [UIColor clearColor];
    [self.webViewContainer addSubview:self.webView.asView];
    [self addConstraintsToView:self.webView.asView];
    
    // The webview should start off hidden before first load to prevent an ugly white background from showing
    self.webView.asView.alpha = 0.0;
}

- (void)addConstraintsToView:(UIView *)view
{
    NSParameterAssert( view.superview != nil );
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{ @"view" : view };
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    [view.superview addConstraints:constraintsH];
    [view.superview addConstraints:constraintsV];
}

- (void)setUrl:(NSURL *)url
{
    if ( _url != nil && [_url isEqual:url] )
    {
        // Don't reload the same URL
        return;
    }
    
    _url = url;
    
    if ( _url != nil )
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}

#pragma mark - VWebViewDelegate

- (void)webViewDidStartLoad:(id<VWebViewProtocol>)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(id<VWebViewProtocol>)webView
{
    [self.activityIndicator stopAnimating];
    
    [UIView animateWithDuration:kWebViewFirstLoadAnimationDuration delay:kWebViewFirstLoadAnimationDelay options:kNilOptions animations:^
     {
         self.webView.asView.alpha = 1.0f;
     }
                     completion:nil];
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
}

@end
