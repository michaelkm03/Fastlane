//
//  VNotificationSettingCell.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingCell.h"
#import "VThemeManager.h"

@interface VNotificationSettingCell()

@property (nonatomic, strong) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, strong) IBOutlet UILabel *settingLabel;

@end

@implementation VNotificationSettingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.settingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.settingSwitch.onTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (void)setTitle:(NSString *)title value:(BOOL)value
{
    self.settingLabel.text = title;
    self.settingSwitch.on = value;
}

- (BOOL)value
{
    return self.settingSwitch.on;
}

#pragma mark - Actions

- (IBAction)settingValueDidchange:(UISwitch *)settingSwitch
{
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(settingsDidUpdateFromCell:)] )
    {
        [self.delegate settingsDidUpdateFromCell:self];
    }
}

@end
