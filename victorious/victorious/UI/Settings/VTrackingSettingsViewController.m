//
//  VTrackingSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrackingSettingsViewController.h"
#import "VThemeManager.h"

/**
 Values for the autoplay setting that determine when autoplay of
 the next video in a stream or playlist should be enabled.
 */
typedef NS_ENUM( NSUInteger, VTrackingSetting )
{
    VTrackingSettingShowEventAlerts,
    VTrackingSettingShowStartEndEventAlerts,
    VTrackingSettingCount
};

@implementation VTrackingSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VTrackingSettingCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VTrackingSetting setting = (VTrackingSetting)indexPath.row;
    
    static NSString * const reuseID = @"trackingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    cell.textLabel.text = [self displayNameForSetting:setting];
    
    cell.accessoryType = [self valueForSetting:setting] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VTrackingSetting setting = (VTrackingSetting)indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setValue:![self valueForSetting:setting] forSetting:setting];
    cell.accessoryType = [self valueForSetting:setting] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)valueForSetting:(VTrackingSetting)setting
{
    switch (setting)
    {
        case VTrackingSettingShowEventAlerts:
            return [VTrackingManager sharedInstance].showTrackingEventAlerts;
        case VTrackingSettingShowStartEndEventAlerts:
            return [VTrackingManager sharedInstance].showTrackingStartEndAlerts;
        default:
            return NO;
    }
}

- (void)setValue:(BOOL)value forSetting:(VTrackingSetting)setting
{
    switch (setting)
    {
        case VTrackingSettingShowEventAlerts:
            [VTrackingManager sharedInstance].showTrackingEventAlerts = value;
            break;
        case VTrackingSettingShowStartEndEventAlerts:
            [VTrackingManager sharedInstance].showTrackingStartEndAlerts = value;
            break;
        default:
            break;
    }
}

- (NSString *)displayNameForSetting:(VTrackingSetting)setting
{
    switch (setting)
    {
        case VTrackingSettingShowEventAlerts:
            return @"Events and Parameters"; // Debug only, non-localized
        case VTrackingSettingShowStartEndEventAlerts:
            return @"Start/End Events (Google Analytics)"; // Debug only, non-localized
        default:
            break;
    }
    
    return nil;
}

@end
