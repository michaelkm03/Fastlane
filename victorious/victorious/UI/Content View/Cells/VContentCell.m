//
//  VContentCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCell.h"

@interface VContentCell ()

@property (nonatomic, weak) UIImageView *animationImageView;

@end

@implementation VContentCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (!self.animationImageView)
    {
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        animationImageView.backgroundColor = [UIColor clearColor];
        animationImageView.userInteractionEnabled = NO;
        self.animationImageView = animationImageView;
        [self.contentView addSubview:animationImageView];
    }
    
    self.repeatCount = 1;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.animationImageView];
}

#pragma mark - Public Methods

- (void)playAnimation
{
    self.animationImageView.animationImages = self.animationSequence;
    self.animationImageView.animationDuration = self.animationDuration;
    self.animationImageView.animationRepeatCount = self.repeatCount;
    [self.animationImageView startAnimating];
}

@end
