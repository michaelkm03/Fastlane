//
//  VUtilityButtonCell.m
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUtilityButtonCell.h"

@implementation VUtilityButtonConfig

@end

@interface VUtilityButtonCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) NSLayoutConstraint *constraintMinLeading;

@end

@implementation VUtilityButtonCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass( [self class] );
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.constraintMinLeading = [NSLayoutConstraint constraintWithItem:self.iconImageView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0f
                                                              constant:0.0f];
    self.constraintMinLeading.priority = 1000;
    [self addConstraint:self.constraintMinLeading];
}

- (void)applyConfiguration:(VUtilityButtonConfig *)config
{
    self.iconImageView.image = config.iconImage;
    self.backgroundColor = config.backgroundColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.contentView.alpha = 1.0f;
}

- (void)setIntendedFullWidth:(CGFloat)intendedFullWidth
{
    _intendedFullWidth = intendedFullWidth;
    self.constraintMinLeading.constant = intendedFullWidth * 0.5f;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.5f : 1.0f;
}

@end
