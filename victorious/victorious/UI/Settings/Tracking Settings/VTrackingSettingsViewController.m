//
//  VTrackingSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrackingSettingsViewController.h"
#import "VThemeManager.h"
#import "VTrackingEventLog.h"

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

typedef NS_ENUM( NSInteger, VTrackingSettingsSection )
{
    VTrackingSettingsSectionAlerts,
    VTrackingSettingsSectionEventLog,
    VTrackingSettingsSectionCount
};

@interface VTrackingSettingsViewController ()

@property (nonatomic, strong) VTrackingEventLog *eventLog;
@property (nonatomic, strong) NSDateFormatter *dateformater;

@end


@implementation VTrackingSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dateformater = [[NSDateFormatter alloc] init];
    [_dateformater setDateFormat:@"HH:mm:ss"];
    
    self.eventLog = [[VTrackingEventLog alloc] init];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ( section )
    {
        case VTrackingSettingsSectionAlerts:
            return VTrackingSettingCount;
            
        case VTrackingSettingsSectionEventLog:
            return self.eventLog.events.count;
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VTrackingSetting setting = (VTrackingSetting)indexPath.row;
    
    switch (indexPath.section)
    {
        case VTrackingSettingsSectionAlerts:
        {
            static NSString * const reuseID = @"trackingCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
            cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
            cell.textLabel.text = [self displayNameForSetting:setting];
            cell.accessoryType = [self valueForSetting:setting] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
            break;
            
        case VTrackingSettingsSectionEventLog:
        {
            static NSString * const reuseID = @"trackingCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
            cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
            NSDictionary *eventData = [[self.eventLog.events reverseObjectEnumerator] allObjects][ indexPath.row ];
            NSDate *date = (NSDate *)eventData[ VTrackingEventLogKeyDate ];
            NSString *timeString = [self.dateformater stringFromDate:date];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ — %@", timeString, eventData[ VTrackingEventLogKeyEventName ]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case VTrackingSettingsSectionAlerts:
        {
            VTrackingSetting setting = (VTrackingSetting)indexPath.row;
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self setValue:![self valueForSetting:setting] forSetting:setting];
            cell.accessoryType = [self valueForSetting:setting] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ( section )
    {
        case VTrackingSettingsSectionAlerts:
            return @"Alert Settings"; // Debug only, non-localized
            break;
            
        case VTrackingSettingsSectionEventLog:
            return @"Event Log"; // Debug only, non-localized
            
        default:
            break;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VTrackingSettingsSectionCount;
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
