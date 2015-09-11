//
//  VExperienceEnhancerCell.m
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerCell.h"
#import "VDependencyManager.h"
#import "victorious-Swift.h"  // for experience enhancer view

static const CGFloat kVExperienceEnhancerCellWidth = 50.0f;
static const CGFloat kThreePointFiveInchScreenHeight = 480.0f;
static const CGFloat kTopSpaceIconCompactVertical = 5.0f;

static NSString * const kUnlockedBallisticBackgroundIconKey = @"ballistic_background_icon";
static NSString * const kLockedBallisticBackgroundIconKey = @"locked_ballistic_background_icon";

NSString * const VExperienceEnhancerCellShouldShowCountKey = @"showBallisticCount";

@interface VExperienceEnhancerCell ()

@property (weak, nonatomic) IBOutlet ExperienceEnhancerAnimatingIconView *ballisticIconView;
@property (weak, nonatomic) IBOutlet UILabel *experienceEnhancerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *padlockImageView;
@property (weak, nonatomic) IBOutlet UILabel *unlockLevelLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceIconImageViewToContianerConstraint;
@property (nonatomic, assign) BOOL isUnhighlighting;
@property (nonatomic, strong) UIImage *unlockedBallisticBackground;
@property (nonatomic, strong) UIImage *lockedBallisticBackground;

@end

@implementation VExperienceEnhancerCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(kVExperienceEnhancerCellWidth, CGRectGetHeight(bounds));
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([UIScreen mainScreen].bounds.size.height == kThreePointFiveInchScreenHeight)
    {
        self.topSpaceIconImageViewToContianerConstraint.constant = kTopSpaceIconCompactVertical;
    }
    self.requiresPurchase = NO;
    self.requiresHigherLevel = NO;
    self.enabled = YES;
    [self.unlockLevelLabel sizeToFit];
    [self.contentView bringSubviewToFront:self.unlockLevelLabel];
}

- (void)prepareForReuse
{
    [self.ballisticIconView reset];
    self.contentView.alpha = 1.0f;
}

#pragma mark - UICollectionReusableView

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    // Return if we're cooling down
    if ( highlighted && [self.ballisticIconView isAnimating] )
    {
        return;
    }
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.ballisticIconView.alpha = highlighted ? 0.5f : 1.0f;
     }
                     completion:nil];
}

#pragma mark - Property Accessors

- (void)setCooldownStartValue:(CGFloat)cooldownStartValue
{
    _cooldownStartValue = MAX(MIN(cooldownStartValue, 1), 0);
}

- (void)setCooldownEndValue:(CGFloat)cooldownEndValue
{
    _cooldownEndValue = MAX(MIN(cooldownEndValue, 1), 0);
}

- (void)setExperienceEnhancerTitle:(NSString *)experienceEnhancerTitle
{
    _experienceEnhancerTitle = [experienceEnhancerTitle copy];
    self.experienceEnhancerLabel.text = _experienceEnhancerTitle;
}

- (void)setExperienceEnhancerIcon:(UIImage *)experienceEnhancerIcon
{
    _experienceEnhancerIcon = experienceEnhancerIcon;
    self.ballisticIconView.iconImage = experienceEnhancerIcon;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.contentView.alpha = _enabled ? 1.0f : 0.5f;
}

- (void)setRequirespurchase:(BOOL)requiresPurchase
{
    _requiresPurchase = requiresPurchase;
    [self updateOverlayImageView];
}

- (void)setRequiresHigherLevel:(BOOL)requiresHigherLevel
{
    _requiresHigherLevel = requiresHigherLevel;
    [self updateUnlockLevelLabel];
}

#pragma mark - Appearance styling

- (void)startCooldown
{
    if ([self readyToCooldown])
    {
        [self.ballisticIconView animate:self.cooldownDuration
                             startValue:self.cooldownStartValue
                               endValue:self.cooldownEndValue];
    }
}

- (BOOL)readyToCooldown
{
    BOOL cooldownTimesValid = self.cooldownEndValue > self.cooldownStartValue && self.cooldownStartValue != 1;
    BOOL timeIntervalValid = self.cooldownDuration > 0;
    return cooldownTimesValid && timeIntervalValid;
}

- (void)updateOverlayImageView
{
    UIImage *image = ( self.requiresPurchase ) ? [self.dependencyManager imageForKey:kLockedBallisticBackgroundIconKey] : [self.dependencyManager imageForKey:kUnlockedBallisticBackgroundIconKey];
    if ( image != nil )
    {
        self.ballisticIconView.overlayImage = image;
    }
    
    self.padlockImageView.hidden = !( self.requiresPurchase );
}

- (void)updateUnlockLevelLabel
{
    self.ballisticIconView.alpha = self.requiresHigherLevel ? 0.5f : 1.0f;
    if (self.requiresHigherLevel)
    {
        self.userInteractionEnabled = NO;
        self.unlockLevelLabel.hidden = NO;
        
        NSString *unlockLevelText = [NSString stringWithFormat:@"Level %ld", self.unlockLevel.integerValue];
        [self.unlockLevelLabel setText:NSLocalizedString(unlockLevelText, "")];

    }
    else
    {
        self.unlockLevelLabel.hidden = YES;
        self.userInteractionEnabled = YES;
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.experienceEnhancerLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.unlockLevelLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
        self.lockedBallisticBackground = [dependencyManager imageForKey:kLockedBallisticBackgroundIconKey];
        self.unlockedBallisticBackground = [dependencyManager imageForKey:kUnlockedBallisticBackgroundIconKey];
        [self updateOverlayImageView];
        
        BOOL shouldShowCount = [[dependencyManager numberForKey:VExperienceEnhancerCellShouldShowCountKey] boolValue];
        self.experienceEnhancerLabel.hidden = !shouldShowCount;
    }
}

@end
