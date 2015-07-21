//
//  VExperienceEnhancerCell.m
//  victorious
//
//  Created by Michael Sena on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerBarCell.h"

#import "VExperienceEnhancerBar.h"
#import "VExperienceEnhancerCell.h" // for VExperienceEnhancerCellShouldShowCountKey
#import "VDependencyManager.h"

@interface VExperienceEnhancerBarCell ()

@property (nonatomic, weak, readwrite) VExperienceEnhancerBar *experienceEnhancerBar;

@end

@implementation VExperienceEnhancerBarCell

#pragma mark - VSharedCollectionReusableViewMethods

static const CGFloat kIphone5AndGreaterHeight = 93.0f;
static const CGFloat kNoLabelSize = 74.0f;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
                            dependencyManager:(VDependencyManager *)dependencyManager
{
    BOOL shouldShowCount = [[dependencyManager numberForKey:VExperienceEnhancerCellShouldShowCountKey] boolValue];
    return CGSizeMake(bounds.size.width, shouldShowCount ? kIphone5AndGreaterHeight : kNoLabelSize);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    VExperienceEnhancerBar *experienceEnhancerBar = [VExperienceEnhancerBar experienceEnhancerBar];
    experienceEnhancerBar.dependencyManager = self.dependencyManager;
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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.experienceEnhancerBar.dependencyManager = dependencyManager;
}

@end
