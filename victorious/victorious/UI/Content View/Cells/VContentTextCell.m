//
//  VContentTextCell.m
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentTextCell.h"
#import "VTextPostViewController.h"
#import "UIView+AutoLayout.h"

@interface VContentTextCell()

@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@end

@implementation VContentTextCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    const CGFloat minSide = MIN( CGRectGetWidth(bounds), CGRectGetHeight(bounds) );
    return CGSizeMake( CGRectGetWidth(bounds), minSide );
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ( self.textPostViewController == nil )
    {
        self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
        self.textPostViewController.view.frame = self.contentContainer.bounds;
        [self.contentContainer addSubview:self.textPostViewController.view];
        [self.contentContainer v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
        self.shrinkingContentView = self.contentContainer;
    }
    self.textPostViewController.isTextSelectable = NO;
}

- (void)setTextContent:(NSString *)text
       backgroundColor:(UIColor *)backgroundColor
    backgroundImageURL:(NSURL *)backgroundImageURL
{
    self.textPostViewController.text = text;
    self.textPostViewController.color = backgroundColor;
    self.textPostViewController.imageURL = backgroundImageURL;
}

@end
