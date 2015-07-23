//
//  VNavigationTitleView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNavigationTitleView.h"
#import "UIView+AutoLayout.h"

@implementation VNavigationTitleView

- (instancetype)initWithTitleView:(UIView *)titleView withPreferredSize:(CGSize)preferredSize
{
    self = [super init];
    if ( self != nil )
    {
        _titleView = titleView;
        _preferredSize = preferredSize;
        self.translatesAutoresizingMaskIntoConstraints = NO;
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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[titleView(height@999)]-(>=0)-|"
                                                                     options:kNilOptions
                                                                     metrics:@{ @"height" : @(height) }
                                                                       views:@{ @"titleView" : self.titleView }]];
        [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.titleView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0f
                                                                    constant:height / self.preferredSize.width]];
        [self.titleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[titleView]-(>=0)-|"
                                                                               options:kNilOptions
                                                                               metrics:nil
                                                                                 views:@{ @"titleView" : self.titleView }]];
        
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGPoint titleCenter = [self.superview convertPoint:self.superview.center toView:self];
    self.titleView.center = titleCenter;
}

@end
