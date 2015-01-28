//
//  VAutoplaySettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAutoplaySettingsViewController.h"
#import "VVideoSettings.h"
#import "VThemeManager.h"

@interface VAutoplaySettingsViewController ()

@end

@implementation VAutoplaySettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VAutoplaySettingCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"serverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    cell.textLabel.text = [VVideoSettings displayNameForSetting:(VAutoplaySetting)indexPath.row];
    
    VAutoplaySetting currentSetting = [VVideoSettings autoplaySetting];
    cell.accessoryType = indexPath.row == currentSetting ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSUInteger n = 0; n < VAutoplaySettingCount; n++)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:n inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [VVideoSettings setAutoPlaySetting:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
