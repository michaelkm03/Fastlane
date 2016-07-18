//
//  VTextStreamPreviewView.m
//  victorious
//
//  Created by Sharif Ahmed on 9/25/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VTextStreamPreviewView.h"

// Models + Helpers
#import "VNode+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VImageAssetFinder.h"
#import "victorious-Swift.h"

// Views + Helpers
#import "VTextPostViewController.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager.h"
#import "UIView+VViewRendering.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+Resize.h"

static const CGFloat kRenderedTextPostSide = 320.0f;
static const CGRect kRenderedTextPostFrame = { {0, 0}, {kRenderedTextPostSide, kRenderedTextPostSide} };

@interface VTextStreamPreviewView ()

@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, assign) BOOL hasRenderedPreview;

@property (nonatomic, strong) NSLayoutConstraint *textPostViewControllerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textPostViewControllerWidthConstraint;

@end

@implementation VTextStreamPreviewView

#pragma mark - VSequencePreviewView Overrides

- (void)setStream:(VStream *)stream
{
    BOOL needsUpdate = stream != (VStream *)self.streamItem;
    [super setStream:stream];
    if ( needsUpdate )
    {
        self.hasRenderedPreview = NO;
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

- (VAsset *)textAsset
{
    return [self.streamItem previewTextPostAsset];
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
        NSString *text = textAsset.data;
        UIColor *color = [[UIColor alloc] initWithRgbHexString:textAsset.backgroundColor];
        NSURL *imageUrl = [NSURL URLWithString:textAsset.backgroundImageUrl];
        [self populateTextPostViewControllerText:text color:color backgroundImageURL:imageUrl];
    }
    [self updatePreviewBackgroundColor];
}

- (void)populateTextPostViewControllerText:(NSString *)text color:(UIColor *)color backgroundImageURL:(NSURL *)backgroundImageURL
{
    self.textPostViewController.text = text;
    self.textPostViewController.color = color;
    __weak VTextStreamPreviewView *weakSelf = self;
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
        self.previewImageView.clipsToBounds = YES;
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
    if ( self.hasRenderedPreview )
    {
        completion(self.previewImageView.image);
        return;
    }
    
    [self updateTextViewFrame];
    [self setupTextViewSizeConstraints];
    [self.textPostViewController.view layoutIfNeeded];
    ViewRenderingCompletion fullCompletion = completion;
    if ( !CGSizeEqualToSize(CGSizeZero, self.displaySize) )
    {
        __weak VTextStreamPreviewView *weakSelf = self;
        fullCompletion = ^(UIImage *image){
            VTextStreamPreviewView *strongSelf = weakSelf;
            if ( strongSelf != nil )
            {
                image = [image smoothResizedImageWithNewSize:strongSelf.displaySize];
            }
            completion(image);
        };
    }
    [self.textPostViewController.view v_renderViewWithCompletion:fullCompletion];
}

- (void)renderTextPostPreviewImage
{
    __weak VTextStreamPreviewView *weakSelf = self;
    [self renderTextPostPreviewImageWithCompletion:^(UIImage *image) {
        VTextStreamPreviewView *strongSelf = weakSelf;
        if ( strongSelf != nil )
        {
            [strongSelf.previewImageView fadeInImage:image];
            strongSelf.hasRenderedPreview = YES;
        }
    }];
}

- (void)updatePreviewBackgroundColor
{
    self.previewImageView.backgroundColor = [self.dependencyManager colorForKey:@"color.standard.textPost"];
}

@end
