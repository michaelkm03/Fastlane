//
//  VActionItemTableViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionItemTableViewCell.h"

// Theme
#import "VThemeManager.h"

@interface VActionItemTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *actionIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceSeparatorToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceSeparatorToContainerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstaint;

@end

@implementation VActionItemTableViewCell

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    self.detailButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    [self.detailButton setTitleColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                            forState:UIControlStateNormal];
    
    self.separatorHeightConstaint.constant = 1 / [UIScreen mainScreen].scale;
}

#pragma mark - UITableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted
                 animated:animated];
    
    void (^highlightAnimations)(void) = ^void(void)
    {
        self.titleLabel.alpha = highlighted ? 0.5f : 1.0f;
        self.actionIconImageView.alpha = highlighted ? 0.5f : 1.0f;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f
                         animations:highlightAnimations];
    }
    else
    {
        highlightAnimations();
    }
}

#pragma mark - Property Accessor

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
    self.detailButton.enabled = !(!detailTitle || (detailTitle.length == 0));
}

- (void)setActionIcon:(UIImage *)actionIcon
{
    _actionIcon = actionIcon;
    self.actionIconImageView.image = actionIcon;
}

- (void)setSeparatorInsets:(UIEdgeInsets)separatorInsets
{
    _separatorInsets = separatorInsets;
    self.leadingSpaceSeparatorToContainerConstraint.constant = separatorInsets.left;
    self.trailingSpaceSeparatorToContainerConstraint.constant = separatorInsets.right;
}

#pragma mark - IBActions

- (IBAction)pressedAccessoryButton:(id)sender
{
    if (self.accessorySelectionHandler)
    {
        self.accessorySelectionHandler();
    }
}

@end
