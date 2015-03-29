//
//  VBlurredMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeStreamItemCell.h"
#import "VDependencyManager.h"
#import "VStreamItem+Fetcher.h"
#import "UIImageView+Blurring.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VStreamWebViewController.h"
#import "VSequence.h"
#import "UIView+AutoLayout.h"
#import "VSequence+Fetcher.h"

static const CGFloat kImageTopConstraintHeight = 30.0f;
static const CGFloat kLabelBottomConstraintHeight = 10.0f;
static const CGFloat kImageHorizontalInset = 55.0f;
static const CGFloat kLabelHeight = 70.0f;

@interface VBlurredMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundImageRightConstraint;

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;

@property (nonatomic, weak) IBOutlet UIImageView *pollOrImageView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VStreamWebViewController *webViewController;

@end

@implementation VBlurredMarqueeStreamItemCell

- (void)setStreamItem:(VStreamItem *)streamItem
{
    [super setStreamItem:streamItem];
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:nil];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        
        self.pollOrImageView.hidden = ![sequence isPoll];
        
    }
    
}

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

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width - kImageHorizontalInset * 2 + kLabelHeight + kLabelBottomConstraintHeight + kImageTopConstraintHeight);
    return CGSizeMake(width, height);
}

@end
