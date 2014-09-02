//
//  VActivityIndicatorView.m
//  victorious
//
//  Created by Josh Hinman on 5/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActivityIndicatorView.h"

static const CGFloat kActivityIndicatorSize = 20.0f;
static const CGFloat kMarginWidth           =  5.0f;

@interface VActivityIndicatorView ()

@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end

@implementation VActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:activityIndicator];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0]];
    activityIndicator.hidesWhenStopped = NO;
    self.activityIndicator = activityIndicator;
    self.hidden = YES;
}

- (void)startAnimating
{
    self.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating
{
    self.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5f;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kActivityIndicatorSize + kMarginWidth, kActivityIndicatorSize + kMarginWidth);
}

@end
