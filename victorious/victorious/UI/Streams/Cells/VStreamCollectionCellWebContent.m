//
//  VStreamCollectionCellWebContent.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellWebContent.h"

// API
#import "VSequence+Fetcher.h"

// Controllers
#import "VStreamWebViewController.h"

// Views + Helpers
#import "UIView+Autolayout.h"
#import "VParallaxPatternView.h"

// Dependencies
#import "VDependencyManager.h"

@interface VStreamCollectionCellWebContent ()

@property (nonatomic, strong) VStreamWebViewController *webViewController;
@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, weak) IBOutlet VParallaxPatternView *parallaxPatternView;

@end

@implementation VStreamCollectionCellWebContent

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.webViewController = [[VStreamWebViewController alloc] init];
    self.webViewController.view.backgroundColor = [UIColor clearColor];
    [self.webViewContainer addSubview:self.webViewController.view];
    [self.webViewContainer v_addFitToParentConstraintsToSubview:self.webViewController.view];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.webViewController.url = [NSURL URLWithString:sequence.webContentPreviewUrl];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.parallaxPatternView.patternTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

- (CGRect)mediaContentFrame
{
    return self.frame;
}

@end
