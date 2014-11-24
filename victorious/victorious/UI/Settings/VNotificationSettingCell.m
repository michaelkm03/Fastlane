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

- (void)setLabel:(NSString *)label withValue:(BOOL)value
{
    self.settingLabel.text = label;
    self.settingSwitch.on = value;
    
    self.settingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.settingSwitch.onTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

@end
