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
        self.titleCenterConstraint = [NSLayoutConstraint constraintWithItem:self.titleView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:0.0f];
        [self.titleView addConstraint:self.titleCenterConstraint];
    }
}

- (void)updateConstraints
{
    UIView *navigationBar = self.superview;
    while ( ![navigationBar isKindOfClass:[UINavigationBar class]] )
    {
        if ( navigationBar == nil )
        {
            NSAssert(false, @"The VNavigationTitleView was added to a view that is not a subview of a UINavigationBar");
            return;
        }
        navigationBar = navigationBar.superview;
    }
    CGPoint titleCenter = [navigationBar convertPoint:navigationBar.center toView:self];
    if ( CGRectContainsPoint(self.frame, titleCenter) )
    {
        //We can't get the proper center, use our own instead
        titleCenter = self.center;
    }
    
    self.titleView.center = titleCenter;
    
    [super updateConstraints];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}

@end
