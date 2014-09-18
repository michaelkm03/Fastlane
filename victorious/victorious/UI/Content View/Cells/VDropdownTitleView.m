//
//  VDropdownTitleView.m
//  victorious
//
//  Created by Michael Sena on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDropdownTitleView.h"

#import "VThemeManager.h"

@interface VDropdownTitleView ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation VDropdownTitleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor] colorWithAlphaComponent:0.97f];
    self.label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

#pragma mark - Property Accessors

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.label.text = titleText;
}

@end
