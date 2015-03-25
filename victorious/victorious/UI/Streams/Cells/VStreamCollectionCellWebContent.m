//
//  VStreamCollectionCellWebContent.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellWebContent.h"
#import "VSequence+Fetcher.h"

#import "VStreamWebViewController.h"
#import "UIView+Autolayout.h"

@interface VStreamCollectionCellWebContent ()

@property (nonatomic, strong) VStreamWebViewController *webViewController;
@property (nonatomic, weak) IBOutlet UIView *webViewContainer;

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

- (CGRect)mediaContentFrame
{
    return self.frame;
}

@end
