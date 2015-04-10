//
//  VAbstractMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"
#import "VSharedCollectionReusableViewMethods.h"
#import "VDependencyManager.h"
#import "VStreamWebViewController.h"
#import "VSequence+Fetcher.h"
#import "UIView+AutoLayout.h"

static NSString * const kOrIconKey = @"orIcon";

@interface VAbstractMarqueeStreamItemCell () <VSharedCollectionReusableViewMethods>

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, strong) VStreamWebViewController *webViewController;

@end

@implementation VAbstractMarqueeStreamItemCell

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"desiredSizeWithCollectionViewBounds: must be overridden by subclasses of VAbstractMarqueeStreamItemCell");
    return CGSizeZero;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.pollOrImageView.image = [dependencyManager imageForKey:kOrIconKey];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        if ( [sequence isWebContent] )
        {
            [self setupWebViewWithSequence:sequence];
        }
        else
        {
            [self cleanupWebView];
        }
    }
}

#pragma mark - Cell setup

- (void)cleanupWebView
{
    if ( self.webViewController != nil )
    {
        [self.webViewController.view removeFromSuperview];
        self.webViewController = nil;
        self.previewImageView.hidden = NO;
    }
}

- (void)setupWebViewWithSequence:(VSequence *)sequence
{
    if ( self.webViewController == nil )
    {
        self.webViewController = [[VStreamWebViewController alloc] init];
        [self.webViewContainer addSubview:self.webViewController.view];
        [self.webViewContainer v_addFitToParentConstraintsToSubview:self.webViewController.view];
        self.previewImageView.hidden = YES;
    }
    
    NSString *contentUrl = (NSString *)sequence.previewData;
    [self.webViewController setUrl:[NSURL URLWithString:contentUrl]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
}

@end
