//
//  VNotificationSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsViewController.h"
#import "VSettingsSwitchCell.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VNotificationSettings.h"
#import "VNoContentTableViewCell.h"
#import "VNotificationSettings+Fetcher.h"

#import "VNotificationSettingsTableSection.h"
#import "VNotificationSettingsStateManager.h"
#import "VConstants.h"
#import "VDependencyManager.h"
#import "VAppInfo.h"
#import "VPermissionsTrackingHelper.h"
#import "victorious-swift.h"

@interface VNotificationSettingsViewController() <VSettingsSwitchCellDelegate, VNotificiationSettingsStateManagerDelegate>

@property (nonatomic, strong) VNotificationSettings *settings;
@property (nonatomic, strong) NSOrderedSet *sections;
@property (nonatomic, assign, readonly) BOOL hasValidSettings;
@property (nonatomic, strong) NSError *settingsError;
@property (nonatomic, assign) BOOL didSettingsChange;
@property (nonatomic, strong, readwrite) VNotificationSettingsStateManager *stateManager;
@property (nonatomic, assign) CGFloat lastKnownTableWidth;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@end

@implementation VNotificationSettingsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stateManager = [[VNotificationSettingsStateManager alloc] initWithDelegate:self];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
    self.permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
}

- (void)viewDidLayoutSubviews
{
    if ( CGRectGetWidth(self.tableView.frame) != self.lastKnownTableWidth )
    {
        self.lastKnownTableWidth = CGRectGetWidth(self.tableView.frame);
        [self.tableView reloadData]; // to force the resizing of the no content cell, if visible
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.stateManager reset];
    NSAssert(self.dependencyManager != nil, @"VNotificationSettingsViewController doesn't have an instance of dependency manager.");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ( self.didSettingsChange && self.settingsError == nil )
    {
        [self saveSettings:self.settings];
    }
}

#pragma mark - VNotificiationSettingsStateManagerDelegate

- (void)onDeviceDidRegisterWithOS
{
    [self loadSettings];
}

- (void)onError:(NSError *)error
{
    self.settings = nil;
    self.settingsError = error;
    [self.tableView reloadData];
}

- (void)onDeviceWillRegisterWithServer
{
    [self setLoading];
}

#pragma mark - Settings Table Data Management

- (void)setLoading
{
    BOOL needsReload = self.settings != nil || self.settings != nil;
    
    self.settings = nil;
    self.settingsError = nil;
    
    if ( needsReload )
    {
        [self.tableView reloadData];
    }
}

- (void)setSettings:(VNotificationSettings *)settings
{
    _settings = settings;
    
    if ( _settings == nil )
    {
        self.sections = nil;
        return;
    }
    
    // Feed section
    NSString *format = NSLocalizedString( @"PostFromCreator", nil);
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    NSString *creatorName = appInfo.ownerName;
    NSArray *sectionFeedRows = @[ [[VNotificationSettingsTableRow alloc] initWithTitle:[NSString stringWithFormat:format, creatorName]
                                                                               enabled:_settings.isPostFromCreatorEnabled.boolValue],
                                  [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"PostFromFollowed", nil)
                                                                               enabled:_settings.isPostFromFollowedEnabled.boolValue],
                                  [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewComment", nil)
                                                                               enabled:_settings.isNewCommentOnMyPostEnabled.boolValue],
                                  [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"PostOnFollowedHashTag", nil)
                                                                               enabled:_settings.isPostOnFollowedHashTagEnabled.boolValue]];
    NSString *sectionFeedTitle = NSLocalizedString( @"NotificationSettingSectionFeeds", nil);
    VNotificationSettingsTableSection *sectionFeed = [[VNotificationSettingsTableSection alloc] initWithTitle:sectionFeedTitle
                                                                                                         rows:sectionFeedRows ];
    
    // People Section
    NSArray *sectionPeopleRows = @[ [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewPrivateMessage", nil)
                                                                                 enabled:_settings.isNewPrivateMessageEnabled.boolValue],
                                    [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewFollower", nil)
                                                                                 enabled:_settings.isNewFollowerEnabled.boolValue],
                                    [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"TagInComment", nil)
                                                                                 enabled:_settings.isUserTagInCommentEnabled.boolValue],
                                    [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"LikePost", nil)
                                                                                 enabled:_settings.isPeopleLikeMyPostEnabled.boolValue]];
    NSString *sectionPeopleTitle = NSLocalizedString( @"NotificationSettingSectionPeople", nil);
    VNotificationSettingsTableSection *sectionPeople = [[VNotificationSettingsTableSection alloc] initWithTitle:sectionPeopleTitle
                                                                                                           rows:sectionPeopleRows ];
    
    // Add both sections
    self.sections = [[NSOrderedSet alloc] initWithObjects:sectionFeed, sectionPeople, nil];
}

- (void)updateSettings
{
    VNotificationSettingsTableSection *section;
    section = self.sections[ 0 ];
    self.settings.isPostFromCreatorEnabled = @( [section rowAtIndex:0].isEnabled );
    self.settings.isPostFromFollowedEnabled = @( [section rowAtIndex:1].isEnabled );
    self.settings.isNewCommentOnMyPostEnabled = @( [section rowAtIndex:2].isEnabled );
    self.settings.isPostOnFollowedHashTagEnabled = @( [section rowAtIndex:3].isEnabled );
    section = self.sections[ 1 ];
    self.settings.isNewPrivateMessageEnabled = @( [section rowAtIndex:0].isEnabled );
    self.settings.isNewFollowerEnabled = @( [section rowAtIndex:1].isEnabled );
    self.settings.isUserTagInCommentEnabled = @( [section rowAtIndex:2].isEnabled );
    self.settings.isPeopleLikeMyPostEnabled = @( [section rowAtIndex:3].isEnabled );
}

- (BOOL)hasValidSettings
{
    return self.sections != nil && self.sections.count != 0;
}

- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section < 0 || indexPath.section >= (NSInteger)self.sections.count )
    {
        return NO;
    }
    VNotificationSettingsTableSection *section = self.sections[ indexPath.section ];
    return [section rowAtIndex:indexPath.row] != nil;
}

- (void)updateSettingsAtIndexPath:(NSIndexPath *)indexPath withValue:(BOOL)value
{
    // Update our sections and rows rows with changes from the UI
    VNotificationSettingsTableSection *section = self.sections[ indexPath.section ];
    VNotificationSettingsTableRow *row = section.rows[ indexPath.row ];
    
    if ( row.isEnabled != value )
    {
        self.didSettingsChange = YES;
        
        row.isEnabled = value;
        
        // Update our underlying rows model with section and row rows
        [self updateSettings];
        
        [self trackPermissionsForIndexPath:indexPath row:row];
    }
}

- (void)trackPermissionsForIndexPath:(NSIndexPath *)indexPath row:(VNotificationSettingsTableRow *)row
{
    NSString *permissionChanged;
    NSString *trackingValueState;
    trackingValueState = row.isEnabled ? VTrackingValueAuthorized : VTrackingValueDenied;

    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                permissionChanged = VTrackingValuePostFromCreator;
                break;
            case 1:
                permissionChanged = VTrackingValuePostFromFollowed;
                break;
            case 2:
                permissionChanged = VTrackingValueNewCommentOnMyPost;
                break;
            case 3:
                permissionChanged = VTrackingValuePostOnFollowedHashtag;
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
                permissionChanged = VTrackingValueNewPrivateMessage;
                break;
            case 1:
                permissionChanged = VTrackingValueNewFollower;
                break;
            case 2:
                permissionChanged = VTrackingValueUsertagInComment;
                break;
            case 3:
                permissionChanged = VTrackingValuePeopleLikeMyPost;
            default:
                break;
        }
    }
    [self.permissionsTrackingHelper permissionsDidChange:permissionChanged permissionState:trackingValueState];
}

#pragma mark - VSettingsSwitchCellDelegate

- (void)settingsDidUpdateFromCell:(VSettingsSwitchCell *)cell
{
    if (self.settings == nil )
    {
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BOOL value = cell.value;
    [self updateSettingsAtIndexPath:indexPath withValue:value];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasValidSettings )
    {
        // Only return cells for sections and rows that exist
        if ( ![self isValidIndexPath:indexPath] )
        {
            return nil;
        }
        
        // Create cell from VNotificationSettingsTableSection and VNotificationSettingsTableRow rows
        NSString *reuseId = NSStringFromClass([VSettingsSwitchCell class]);
        VSettingsSwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
        
        VNotificationSettingsTableSection *section = self.sections[ indexPath.section ];
        VNotificationSettingsTableRow *row = [section rowAtIndex:indexPath.row];
        cell.delegate = self;
        cell.dependencyManager = self.dependencyManager;
        [cell setTitle:row.title value:row.isEnabled];
        return cell;
    }
    else
    {
        // Only ever return one NoContentCell in the first section
        if ( indexPath.section != 0 || indexPath.row != 0 )
        {
            return nil;
        }
        
        // Show loading or error message
        VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
        if ( self.settingsError != nil )
        {
            cell.message = self.settingsError.localizedDescription;
            cell.centered = YES;
            
            if ( self.settingsError.code == kErrorCodeUserNotRegistered )
            {
                [cell showActionButtonWithLabel:NSLocalizedString( @"Open Settings", nil) callback:^void
                 {
                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                     [[UIApplication sharedApplication] openURL:url];
                 }];
            }
        }
        else
        {
            cell.isLoading = YES;
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 && !self.hasValidSettings )
    {
        return 1;
    }
    
    VNotificationSettingsTableSection *sectionData = self.sections[ section ];
    return sectionData.rows.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Must have at least one section to show error/loading when there is not rows in self.sections
    return MAX( self.sections.count, (NSUInteger)1 );
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    VNotificationSettingsTableSection *sectionData = self.sections[ section ];
    return sectionData.title;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 && !self.hasValidSettings )
    {
        if ( self.settingsError != nil )
        {
            return [VNoContentTableViewCell heightWithMessage:self.settingsError.localizedDescription andWidth:CGRectGetWidth(self.tableView.frame)];
        }
        return 130.0f;
    }

    return 44.0f;
}

@end
