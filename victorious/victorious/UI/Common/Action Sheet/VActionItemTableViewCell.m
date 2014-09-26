//
//  VActionItemTableViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionItemTableViewCell.h"

#import "VThemeManager.h"

@interface VActionItemTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *actionIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end

@implementation VActionItemTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.detailButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    [self.detailButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                            forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleLabel.text = _title;
}

- (void)setDetailTitle:(NSString *)detailTitle
{
    _detailTitle = [detailTitle copy];
    [self.detailButton setTitle:_detailTitle
                       forState:UIControlStateNormal];
}

- (void)setActionIcon:(UIImage *)actionIcon
{
    _actionIcon = actionIcon;
    self.actionIconImageView.image = actionIcon;
}

@end
