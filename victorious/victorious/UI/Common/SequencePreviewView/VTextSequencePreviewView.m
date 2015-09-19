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

@interface VTextSequencePreviewView ()

@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) UIImageView *previewImageView;

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
        [self updateSequence];
    }
}

- (void)setDependencyManager:(VDependencyManager * __nullable)dependencyManager
{
    BOOL needsUpdate = dependencyManager != self.dependencyManager;
    [super setDependencyManager:dependencyManager];
    if ( self.dependencyManager != nil && needsUpdate )
    {
        [self updatePreviewBackgroundColor];
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

#pragma mark - View updating

- (void)updateSequence
{
    VAsset *textAsset = [self textAsset];
    if ( self.onlyShowPreview || textAsset == nil )
    {
        [self setupPreviewImageView];
    }
    else
    {
        VSequence *sequence = [self convertedSequence];
        NSString *text = textAsset.data;
        UIColor *color = [UIColor v_colorFromHexString:textAsset.backgroundColor];
        VAsset *imageAsset = [sequence.firstNode imageAsset];
        NSURL *imageUrl = [NSURL URLWithString:imageAsset.data];
        [self setupTextPostViewControllerText:text color:color backgroundImageURL:imageUrl cacheKey:sequence.remoteId];
    }
    [self updatePreviewBackgroundColor];
}

- (void)setupTextPostViewControllerText:(NSString *)text color:(UIColor *)color backgroundImageURL:(NSURL *)backgroundImageURL cacheKey:(NSString *)cacheKey
{
    if ( self.textPostViewController == nil )
    {
        self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
        self.textPostViewController.view.frame = self.bounds;
        [self addSubview:self.textPostViewController.view];
        [self v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    }
    
    self.textPostViewController.view.hidden = NO;
    self.previewImageView.hidden = YES;
    
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
        self.previewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textPostThumbnail"]];
        self.previewImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.previewImageView];
        [self v_addFitToParentConstraintsToSubview:self.previewImageView];
    }
    
    self.textPostViewController.view.hidden = YES;
    self.previewImageView.hidden = NO;
    self.readyForDisplay = YES;
}

- (void)updatePreviewBackgroundColor
{
    self.previewImageView.backgroundColor = [self.dependencyManager colorForKey:@"color.standard.textPost"];
}

@end
