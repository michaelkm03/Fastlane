//
//  VHTMLSequncePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHTMLSequncePreviewView.h"

// Models + Helpers
#import "VSequence+Fetcher.h"

// Views + Helpers
#import "UIView+Autolayout.h"

// Controllers
#import "VStreamWebViewController.h"

@interface VHTMLSequncePreviewView () <VStreamWebViewControllerDelegate>

@property (nonatomic, strong) VStreamWebViewController *webViewController;

@end

@implementation VHTMLSequncePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _webViewController = [[VStreamWebViewController alloc] init];
        _webViewController.view.backgroundColor = [UIColor clearColor];
        _webViewController.delegate = self;
        [self addSubview:_webViewController.view];
        [self v_addFitToParentConstraintsToSubview:_webViewController.view];
    }
    return self;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.webViewController.url = [NSURL URLWithString:sequence.webContentPreviewUrl];
}

#pragma mark - VStreamWebViewControllerDelegate

- (void)streamWebViewControllerContentIsVisible
{
    self.readyForDisplay = YES;
}

@end
