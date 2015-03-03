//
//  VNotificationSettingCell.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNotificationSettingCell.h"
#import "VThemeManager.h"

@interface VNotificationSettingCell()

@property (nonatomic, strong) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, strong) IBOutlet UILabel *settingLabel;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VNotificationSettingCell

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.settingLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.settingSwitch.onTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
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
