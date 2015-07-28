//
//  VNavigationTitleView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNavigationTitleView.h"
#import "UIView+AutoLayout.h"

@interface VNavigationTitleView ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, strong) NSLayoutConstraint *titleCenterConstraint;

@end

@implementation VNavigationTitleView

- (instancetype)initWithTitleView:(UIView *)titleView withPreferredSize:(CGSize)preferredSize
{
    self = [super initWithFrame:CGRectMake(0, 0, preferredSize.width, preferredSize.height)];
    if ( self != nil )
    {
        _titleView = titleView;
        _preferredSize = preferredSize;
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( self.titleView.superview == nil )
    {
        [self addSubview:self.titleView];
        [self v_addCenterVerticallyConstraintsToSubview:self.titleView];
        CGFloat height = self.preferredSize.height;
        CGFloat width = self.preferredSize.width;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[titleView(height@999)]-(>=0)-|"
                                                                     options:kNilOptions
                                                                     metrics:@{ @"height" : @(height) }
                                                                       views:@{ @"titleView" : self.titleView }]];
        [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.titleView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:height / width
                                                                    constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[titleView]-(>=0)-|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{ @"titleView" : self.titleView }]];
        CGFloat constant = [self titleCenterConstraintValue];
        self.titleCenterConstraint = [NSLayoutConstraint constraintWithItem:self.titleView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:constant];
        [self addConstraint:self.titleCenterConstraint];
    }
}

- (CGFloat)titleCenterConstraintValue
{
    UIView *navigationBar = self.superview;
    while ( ![navigationBar isKindOfClass:[UINavigationBar class]] )
    {
        if ( navigationBar == nil )
        {
            return 0;
        }
        navigationBar = navigationBar.superview;
    }
    CGPoint titleCenter = [self convertPoint:navigationBar.center toView:self];
    
    titleCenter.x -= self.center.x;
    
    return titleCenter.x;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.titleCenterConstraint.constant = [self titleCenterConstraintValue];
    
    [self needsUpdateConstraints];
}

@end
