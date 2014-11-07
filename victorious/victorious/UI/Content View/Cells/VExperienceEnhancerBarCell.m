//
//  VExperienceEnhancerCell.m
//  victorious
//
//  Created by Michael Sena on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerBarCell.h"

#import "VExperienceEnhancerBar.h"

@interface VExperienceEnhancerBarCell ()

@property (nonatomic, weak, readwrite) VExperienceEnhancerBar *experienceEnhancerBar;

@end

@implementation VExperienceEnhancerBarCell

#pragma mark - VSharedCollectionReusableViewMethods

static const CGFloat kThreePointFiveInchIphoneHeight = 480.0f;
static const CGFloat kIphone4AndLessHeight = 73.0f;
static const CGFloat kIphone5AndGreaterHeight = 93.0f;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    BOOL isUltraCompact = ([UIScreen mainScreen].bounds.size.height <= kThreePointFiveInchIphoneHeight) ? YES : NO;
    return CGSizeMake(CGRectGetWidth(bounds), isUltraCompact ? kIphone4AndLessHeight : kIphone5AndGreaterHeight);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    VExperienceEnhancerBar *experienceEnhancerBar = [VExperienceEnhancerBar experienceEnhancerBar];
    experienceEnhancerBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:experienceEnhancerBar];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0f
                                                                  constant:0.0f]];

    self.experienceEnhancerBar = experienceEnhancerBar;
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:1.0f];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];

    [self.contentView layoutIfNeeded];
    [self.experienceEnhancerBar layoutIfNeeded];
}

@end
