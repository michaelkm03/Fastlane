//
//  VTextSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextSequencePreviewView.h"

// Models + Helpers
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VImageAsset.h"
#import "VImageAssetFinder.h"

// Views + Helpers
#import "VTextPostViewController.h"
#import "UIColor+VHex.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager.h"
#import "UIView+VViewRendering.h"
#import "UIImageView+VLoadingAnimations.h"

static const CGFloat kRenderedTextPostSide = 320.0f;
static const CGRect kRenderedTextPostFrame = { {0, 0}, {kRenderedTextPostSide, kRenderedTextPostSide} };

@interface VTextSequencePreviewView ()

@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, strong) NSLayoutConstraint *textPostViewControllerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textPostViewControllerWidthConstraint;

@end

@implementation VTextSequencePreviewView

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    BOOL needsUpdate = sequence != self.streamItem;
    [super setSequence:sequence];
    if ( needsUpdate )
    {
        [self updateSequence];
    }
}

- (void)setOnlyShowPreview:(BOOL)onlyShowPreview
{
    BOOL needsUpdate = onlyShowPreview != self.onlyShowPreview;
    [super setOnlyShowPreview:onlyShowPreview];
    if ( needsUpdate )
    {
        [self updateSubviews];
        if ( self.readyForDisplay )
        {
            [self renderTextPostPreviewImage];
        }
    }
}

- (void)updateSubviews
{
    [self updateTextViewFrame];
    if ( self.onlyShowPreview )
    {
        [self setupPreviewImageView];
    }
    else
    {
        [self setupTextPostView];
    }
}

- (void)setDependencyManager:(VDependencyManager *__nullable)dependencyManager
{
    BOOL needsToRefreshSequence = self.textPostViewController == nil;
    BOOL needsUpdate = dependencyManager != self.dependencyManager;
    [super setDependencyManager:dependencyManager];
    if ( self.dependencyManager != nil && needsUpdate )
    {
        [self updatePreviewBackgroundColor];
        [self updateSubviews];
        if ( needsToRefreshSequence )
        {
            [self updateSequence];
        }
    }
}

#pragma mark - Convenience accessors

- (VSequence *)convertedSequence
{
    if ( [self.streamItem isKindOfClass:[VSequence class]] )
    {
        return (VSequence *)self.streamItem;
    }
    return nil;
}

- (VAsset *)textAsset
{
    VSequence *sequence = [self convertedSequence];
    if ( sequence != nil )
    {
        VImageAssetFinder *assetFinder = [[VImageAssetFinder alloc] init];
        VAsset *textAsset = [assetFinder textAssetFromAssets:sequence.previewAssets];
        
        if (textAsset == nil)
        {
            // fall back gracefully
            textAsset = [sequence.firstNode textAsset];
        }
        
        if ( textAsset.data != nil )
        {
            return  textAsset;
        }
    }
    return nil;
}

- (VTextPostViewController *)textPostViewController
{
    if ( _textPostViewController != nil || self.dependencyManager == nil )
    {
        return _textPostViewController;
    }
    
    _textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
    _textPostViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    return _textPostViewController;
}

#pragma mark - View updating

- (void)updateSequence
{
    self.previewImageView.alpha = 0.0f;
    VAsset *textAsset = [self textAsset];
    if ( textAsset != nil )
    {
        VSequence *sequence = [self convertedSequence];
        NSString *text = textAsset.data;
        UIColor *color = [UIColor v_colorFromHexString:textAsset.backgroundColor];
        VAsset *imageAsset = [sequence.firstNode imageAsset];
        NSURL *imageUrl = [NSURL URLWithString:imageAsset.data];
        [self populateTextPostViewControllerText:text color:color backgroundImageURL:imageUrl cacheKey:sequence.remoteId];
    }
    [self updatePreviewBackgroundColor];
}

- (void)populateTextPostViewControllerText:(NSString *)text color:(UIColor *)color backgroundImageURL:(NSURL *)backgroundImageURL cacheKey:(NSString *)cacheKey
{
    self.textPostViewController.text = text;
    self.textPostViewController.color = color;
    __weak VTextSequencePreviewView *weakSelf = self;
    [self.textPostViewController setImageURL:backgroundImageURL animated:YES completion:^(UIImage *image)
     {
         weakSelf.readyForDisplay = YES;
     }];
}

- (void)setupPreviewImageView
{
    if ( self.previewImageView == nil )
    {
        self.previewImageView = [[UIImageView alloc] init];
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if ( self.previewImageView.superview == nil )
    {
        [self addSubview:self.previewImageView];
        [self v_addFitToParentConstraintsToSubview:self.previewImageView];
    }
    
    if ( self.textPostViewController.view.superview != nil )
    {
        [self.textPostViewController.view removeFromSuperview];
    }
}

- (void)setupTextPostView
{
    if ( self.textPostViewController.view.superview == nil )
    {
        [self addSubview:self.textPostViewController.view];
        [self v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    }

    if ( self.previewImageView.superview != nil )
    {
        [self.previewImageView removeFromSuperview];
    }
}

- (void)setReadyForDisplay:(BOOL)readyForDisplay
{
    [super setReadyForDisplay:readyForDisplay];
    if ( self.onlyShowPreview && readyForDisplay )
    {
        [self setupPreviewImageView];
        [self renderTextPostPreviewImage];
    }
}

- (void)setupTextViewSizeConstraints
{
    CGSize size = kRenderedTextPostFrame.size;
    if ( self.textPostViewControllerWidthConstraint == nil )
    {
        self.textPostViewControllerWidthConstraint = [self.textPostViewController.view v_addWidthConstraint:size.width];
    }
    if ( self.textPostViewControllerHeightConstraint == nil )
    {
        self.textPostViewControllerHeightConstraint = [self.textPostViewController.view v_addHeightConstraint:size.height];
    }
}

- (void)updateConstraints
{
    self.textPostViewControllerWidthConstraint.active = self.onlyShowPreview;
    self.textPostViewControllerHeightConstraint.active = self.onlyShowPreview;
    [super updateConstraints];
}

- (void)updateTextViewFrame
{
    self.textPostViewController.view.frame = self.onlyShowPreview ? kRenderedTextPostFrame : self.bounds;
}

- (void)renderTextPostPreviewImageWithCompletion:(void(^)(UIImage *image))completion
{
    [self updateTextViewFrame];
    [self setupTextViewSizeConstraints];
    [self.textPostViewController.view layoutIfNeeded];
    [self.textPostViewController.view v_renderViewWithCompletion:completion];
}

- (void)renderTextPostPreviewImage
{
    [self renderTextPostPreviewImageWithCompletion:^(UIImage *image) {
        [self.previewImageView fadeInImage:image];
    }];
}

- (void)updatePreviewBackgroundColor
{
    self.previewImageView.backgroundColor = [self.dependencyManager colorForKey:@"color.standard.textPost"];
}

@end
