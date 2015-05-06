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

// Views + Helpers
#import "VTextPostViewController.h"
#import "UIColor+VHex.h"
#import "UIView+AutoLayout.h"

@interface VTextSequencePreviewView ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VTextPostViewController *textPostViewController;

@end

@implementation VTextSequencePreviewView

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    VAsset *textAsset = [self.sequence.firstNode textAsset];
    if ( textAsset.data != nil )
    {
        NSString *text = textAsset.data;
        UIColor *color = [UIColor v_colorFromHexString:textAsset.backgroundColor];
        VAsset *imageAsset = [self.sequence.firstNode imageAsset];
        NSURL *imageUrl = [NSURL URLWithString:imageAsset.data];
        [self setupTextPostViewControllerText:text color:color backgroundImageURL:imageUrl cacheKey:self.sequence.remoteId];
    }
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
    
    self.textPostViewController.text = text;
    self.textPostViewController.color = color;
    self.textPostViewController.imageURL = backgroundImageURL;
}

@end
