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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

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
        [self.contentContainer addSubview:self.textPostViewController.view];
        self.textPostViewController.view.frame = self.contentContainer.bounds;
        self.textPostViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentContainer v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    }
    self.textPostViewController.isTextSelectable = NO;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.widthConstraint.constant = CGRectGetWidth(layoutAttributes.bounds);
    CGFloat scale = CGRectGetHeight(layoutAttributes.bounds) / CGRectGetWidth(self.contentView.bounds);
    CGFloat adjustedHeight = CGRectGetHeight(self.contentContainer.bounds) * scale;
    CGFloat topPadding = (CGRectGetHeight(self.contentContainer.bounds) - adjustedHeight) * 0.5f;
    CGAffineTransform yTranslation = CGAffineTransformMakeTranslation(0, -topPadding);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    self.contentContainer.transform = CGAffineTransformConcat(scaleTransform, yTranslation);
}

- (void)setTextContent:(NSString *)text
       backgroundColor:(UIColor *)backgroundColor
    backgroundImageURL:(NSURL *)backgroundImageURL
{
    self.textPostViewController.text = text;
    self.textPostViewController.color = backgroundColor;
    [self.textPostViewController setImageURL:backgroundImageURL animated:YES completion:nil];
}

@end
