//
//  VContentTextCell.m
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentTextCell.h"
#import "VEditableTextPostViewController.h"
#import "UIView+AutoLayout.h"

@interface VContentTextCell()

@property (nonatomic, strong) VEditableTextPostViewController *textPostViewController;

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

- (VEditableTextPostViewController *)textPostViewController
{
    if ( _textPostViewController == nil )
    {
        _textPostViewController = [VEditableTextPostViewController newWithDependencyManager:self.dependencyManager];
        _textPostViewController.isTextSelectable = YES;
        [self.contentView addSubview:_textPostViewController.view];
        [self.contentView v_addFitToParentConstraintsToSubview:_textPostViewController.view];
    }
    return _textPostViewController;
}

- (void)setTextContent:(NSString *)text withBackgroundColor:(UIColor *)backgroundColor
{
    self.textPostViewController.text = text;
    self.textPostViewController.view.backgroundColor = backgroundColor;
}

@end
