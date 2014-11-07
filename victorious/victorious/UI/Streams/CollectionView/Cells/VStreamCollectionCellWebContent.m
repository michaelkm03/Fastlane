//
//  VStreamCollectionCellWebContent.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellWebContent.h"
#import "VThemeManager.h"
#import "VWebViewCreator.h"
#import "VSequence+Fetcher.h"

@interface VStreamCollectionCellWebContent() <VWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, strong) id<VWebViewProtocol> webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation VStreamCollectionCellWebContent

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.backgroundColor = backgroundColor;
    self.webViewContainer.backgroundColor = backgroundColor;
    
    self.webView = [VWebViewCreator createWebView];
    self.webView.delegate = self;
    self.webView.asView.userInteractionEnabled = NO;
    self.webView.asView.backgroundColor = backgroundColor;
    [self.webViewContainer addSubview:self.webView.asView];
    [self addConstraintsToView:self.webView.asView];
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

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    if ( self.url == nil )
    {
        self.url = [NSURL URLWithString:sequence.webContentUrl];
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
}

- (void)webView:(id<VWebViewProtocol>)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

- (void)webView:(id<VWebViewProtocol>)webView didUpdateProgress:(float)progress
{
}

@end
