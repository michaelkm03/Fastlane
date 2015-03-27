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

@end

@implementation VContentTextCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    const CGFloat minSide = MIN( CGRectGetWidth(bounds), CGRectGetHeight(bounds) );
    return CGSizeMake( CGRectGetWidth(bounds), minSide );
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self cleanupTextPost];
}

- (void)cleanupTextPost
{
    if ( self.textPostViewController != nil )
    {
        [self.textPostViewController.view removeFromSuperview];
        self.textPostViewController = nil;
    }
}

- (void)setTextContent:(NSString *)text withBackgroundColor:(UIColor *)backgroundColor
{
    [self cleanupTextPost];
    
    self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
    [self.contentView addSubview:self.textPostViewController.view];
    [self.contentView v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    self.textPostViewController.view.backgroundColor = backgroundColor;
}

@end
