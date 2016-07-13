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

@interface VTextSequencePreviewView ()

@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, assign) BOOL hasRenderedPreview;

@property (nonatomic, strong) NSLayoutConstraint *offscreenPreviewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *offscreenPreviewWidthConstraint;

@property (nonatomic, strong) NSLayoutConstraint *previewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *previewHeightConstraint;

@property (nonatomic, assign) CGSize previewRenderingSize;

@end

@implementation VTextSequencePreviewView

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    BOOL needsUpdate = sequence != self.streamItem;
    [super setSequence:sequence];
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
        VAsset *textAsset = [sequence previewTextPostAsset];
        
        if (textAsset == nil || ![textAsset.type isEqualToString:@"text"])
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
    _textPostViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    return _textPostViewController;
}

#pragma mark - VRenderablePreviewView

- (void)setRenderingSize:(CGSize)renderingSize
{
    self.previewRenderingSize = renderingSize;
    [self updateConstraints];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL hasRenderingSize = !CGSizeEqualToSize( self.previewRenderingSize, CGSizeZero );
    const CGFloat scale = hasRenderingSize ? CGRectGetWidth(self.bounds) / self.previewRenderingSize.width : 1.0;
    self.textPostViewController.view.transform = CGAffineTransformMakeScale( scale, scale );
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
        UIColor *color = [[UIColor alloc] initWithRgbHexString:textAsset.backgroundColor];
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
    [self updateConstraints];
}

- (void)setupPreviewImageView
{
    if ( self.previewImageView == nil )
    {
        self.previewImageView = [[UIImageView alloc] init];
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.previewImageView.clipsToBounds = YES;
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
        [self updateConstraints];
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
    const BOOL hasAddedConstraints = self.offscreenPreviewWidthConstraint != nil && self.offscreenPreviewHeightConstraint != nil;
    if ( !hasAddedConstraints )
    {
        CGSize size = kRenderedTextPostFrame.size;
        self.offscreenPreviewWidthConstraint = [self.textPostViewController.view v_addWidthConstraint:size.width];
        self.offscreenPreviewHeightConstraint = [self.textPostViewController.view v_addHeightConstraint:size.height];
    }
}

- (void)updateConstraints
{
    self.offscreenPreviewWidthConstraint.active = self.onlyShowPreview;
    self.offscreenPreviewHeightConstraint.active = self.onlyShowPreview;
    
    self.previewHeightConstraint.active = !self.onlyShowPreview;
    self.previewWidthConstraint.active = !self.onlyShowPreview;
    
    if ( !self.onlyShowPreview && self.textPostViewController != nil )
    {
        BOOL hasRenderingSize = !CGSizeEqualToSize( self.previewRenderingSize, CGSizeZero );
        const CGSize size = hasRenderingSize ? self.previewRenderingSize : self.bounds.size;
        
        const BOOL hasAddedConstraints = self.previewWidthConstraint != nil && self.previewWidthConstraint != nil;
        if ( !hasAddedConstraints && !CGSizeEqualToSize(size, CGSizeZero) && self.textPostViewController.view != nil )
        {
            [self v_addCenterToParentContraintsToSubview:self.textPostViewController.view];
            self.previewWidthConstraint = [self.textPostViewController.view v_addWidthConstraint:size.width];
            self.previewHeightConstraint = [self.textPostViewController.view v_addHeightConstraint:size.height];
        }
        
        self.previewHeightConstraint.constant = size.width;
        self.previewWidthConstraint.constant = size.height;
    }
    
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
        __weak VTextSequencePreviewView *weakSelf = self;
        fullCompletion = ^(UIImage *image){
            __strong VTextSequencePreviewView *strongSelf = weakSelf;
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
    __weak VTextSequencePreviewView *weakSelf = self;
    [self renderTextPostPreviewImageWithCompletion:^(UIImage *image) {
        __strong VTextSequencePreviewView *strongSelf = weakSelf;
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
