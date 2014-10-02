//
//  VExperienceEnhancerCell.m
//  victorious
//
//  Created by Michael Sena on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperienceEnhancerCell.h"

@interface VExperienceEnhancerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *experienceEnhancerIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *experienceEnhancerLabel;

@end

@implementation VExperienceEnhancerCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(35, CGRectGetHeight(bounds));
}

#pragma mark - Property Accessors

- (void)setExperienceEnhancerTitle:(NSString *)experienceEnhancerTitle
{
    _experienceEnhancerTitle = [experienceEnhancerTitle copy];
    self.experienceEnhancerLabel.text = _experienceEnhancerTitle;
}


- (void)setExperienceEnhancerIcon:(UIImage *)experienceEnhancerIcon
{
    _experienceEnhancerIcon = experienceEnhancerIcon;
    self.experienceEnhancerIconImageView.image = _experienceEnhancerIcon;
}

@end
