//
//  VExperienceEnhancerCell.m
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerCell.h"
#import "VThemeManager.h"

static const CGFloat kVExperienceEnhancerCellWidth = 50.0f;
static const CGFloat kThreePointFiveInchScreenHeight = 480.0f;
static const CGFloat kTopSpaceIconCompactVertical = 5.0f;

@interface VExperienceEnhancerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *experienceEnhancerBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *experienceEnhancerIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *experienceEnhancerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceIconImageViewToContianerConstraint;
@property (nonatomic, assign) BOOL isUnhighlighting;

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
    
    self.isLocked = NO;
    self.enabled = YES;
}

- (void)prepareForReuse
{
    self.contentView.alpha = 1.0f;
}

#pragma mark - UICollectionReusableView

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.experienceEnhancerIconImageView.alpha = highlighted ? 0.5f : 1.0f;
     }
                     completion:nil];
}

#pragma mark - Property Accessors

- (void)setExperienceEnhancerTitle:(NSString *)experienceEnhancerTitle
{
    _experienceEnhancerTitle = [experienceEnhancerTitle copy];
    self.experienceEnhancerLabel.text = _experienceEnhancerTitle;
    self.experienceEnhancerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

- (void)setExperienceEnhancerIcon:(UIImage *)experienceEnhancerIcon
{
    _experienceEnhancerIcon = experienceEnhancerIcon;
    self.experienceEnhancerIconImageView.image = experienceEnhancerIcon;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.contentView.alpha = _enabled ? 1.0f : 0.5f;
}

- (void)setIsLocked:(BOOL)isLocked
{
    _isLocked = isLocked;
    
    UIImage *image = nil;
    if ( _isLocked )
    {
        image = [UIImage imageNamed:@"ballistic-bg-locked"];
    }
    else
    {
        image = [UIImage imageNamed:@"ballistic-bg"];
    }
    
    if ( image != nil )
    {
        self.experienceEnhancerBackgroundImageView.image = image;
    }
}

@end
