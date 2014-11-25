//
//  VNotificationSettingsViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsViewController.h"
#import "VNotificationSettingCell.h"
#import "UIViewController+VNavMenu.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VNotificationSettings.h"
#import "VNoContentTableViewCell.h"
#import "VNotificationSettings+Fetcher.h"
#import "VAlertController.h"

static const NSInteger kErrorCodeDeviceNotFound = 5000;

@implementation VNotificationSettingsSection

- (instancetype)initWithTitle:(NSString *)title data:(NSArray *)data
{
    self = [super init];
    if (self)
    {
        _title = title;
        _data = data;
    }
    return self;
}

@end

@implementation VNotificationSetting

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled
{
    self = [super init];
    if (self)
    {
        _title = title;
        _isEnabled = isEnabled;
    }
    return self;
}

@end


@interface VNotificationSettingsViewController() <VNavigationHeaderDelegate, VNotificationSettingCellDelegate>

@property (nonatomic, strong) VNotificationSettings *settings;
@property (nonatomic, strong) NSOrderedSet *sections;
@property (nonatomic, assign, readonly) BOOL hasValidSettings;
@property (nonatomic, strong) NSError *settingsError;

@end


@implementation VNotificationSettingsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [VNoContentTableViewCell registerNibWithTableView:self.tableView];
    
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self saveSettings];
}

#pragma mark -

- (void)loadSettings
{
    self.settingsError = nil;
    self.settings = nil;
    
    [[VObjectManager sharedManager] getDeviceSettingsSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         self.settingsError = nil;
         self.settings = [self evalulateFetchedResult:resultObjects.firstObject];
         [self.tableView reloadData];
     }
                                                        failBlock:^(NSOperation *operation, NSError *error)
     {
         if ( error.code == kErrorCodeDeviceNotFound )
         {
             NSString *domain = NSLocalizedString( @"ErrorPushNotificationsNotEnabled", nil );
             self.settingsError = [NSError errorWithDomain:domain code:error.code userInfo:nil];
         }
         [self.tableView reloadData];
     }];
}

- (VNotificationSettings *)evalulateFetchedResult:(id)result
{
    if ( result != nil && [result isKindOfClass:[VNotificationSettings class]])
    {
        return result;
    }
    else
    {
       return [VNotificationSettings createDefaultSettings];
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
    
    NSString *format = NSLocalizedString( @"PostFromCreator", nil);
    NSString *creatorName = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSArray *sectionFeedData = @[ [[VNotificationSetting alloc] initWithTitle:[NSString stringWithFormat:format, creatorName]
                                                                      enabled:_settings.isNewCommentOnMyPostEnabled.boolValue],
                                  [[VNotificationSetting alloc] initWithTitle:NSLocalizedString( @"PostFromFollowed", nil)
                                                                      enabled:_settings.isPostFromFollowedEnabled.boolValue],
                                  [[VNotificationSetting alloc] initWithTitle:NSLocalizedString( @"NewComment", nil)
                                                                      enabled:_settings.isNewCommentOnMyPostEnabled.boolValue],
                                  [[VNotificationSetting alloc] initWithTitle:NSLocalizedString( @"NewPrivateMessage", nil)
                                                                      enabled:_settings.isNewPrivateMessageEnabled.boolValue]];
    VNotificationSettingsSection *sectionFeed = [[VNotificationSettingsSection alloc] initWithTitle:@"Feed" data:sectionFeedData ];
    
    NSArray *sectionPeopleData = @[ [[VNotificationSetting alloc] initWithTitle:NSLocalizedString( @"NewFollower", nil)
                                                                        enabled:_settings.isNewFollowerEnabled.boolValue]];
    VNotificationSettingsSection *sectionPeople = [[VNotificationSettingsSection alloc] initWithTitle:@"People" data:sectionPeopleData ];
    
    self.sections = [[NSOrderedSet alloc] initWithObjects:sectionFeed, sectionPeople, nil];
}

- (void)updateSettings
{
    VNotificationSettingsSection *section = self.sections[ 0 ];
    self.settings.isNewCommentOnMyPostEnabled = @( ((VNotificationSetting *)section.data[ 0 ]).isEnabled );
    self.settings.isPostFromFollowedEnabled = @( ((VNotificationSetting *)section.data[ 1 ]).isEnabled );
    self.settings.isNewCommentOnMyPostEnabled = @( ((VNotificationSetting *)section.data[ 2 ]).isEnabled );
    self.settings.isNewPrivateMessageEnabled = @( ((VNotificationSetting *)section.data[ 3 ]).isEnabled );
    section = self.sections[ 1 ];
    self.settings.isNewFollowerEnabled = @( ((VNotificationSetting *)section.data[ 0 ]).isEnabled );
}

- (void)saveSettings
{
    [[VObjectManager sharedManager] setDeviceSettings:self.settings successBlock:nil failBlock:^(NSOperation *operation, NSError *error)
    {
        NSString *title = @"Error Saving Preferences";
        NSString *message = @"Oops!  Something went wrong, please try again later.";
        VAlertController *alertConroller = [VAlertController alertWithTitle:title message:message];
        [alertConroller addAction:[VAlertAction cancelButtonWithTitle:@"OK" handler:nil]];
        [alertConroller presentInViewController:self.navigationController animated:YES completion:nil];
    }];
}

- (BOOL)hasValidSettings
{
    return self.sections != nil && self.sections.count != 0;
}

#pragma mark - VNotificationSettingCellDelegate

- (void)userDidUpdateSettingAtIndex:(NSIndexPath *)indexPath withValue:(BOOL)value
{
    if (self.settings == nil )
    {
        return;
    }
    
    VNotificationSettingsSection *section = self.sections[ indexPath.section ];
    VNotificationSetting *setting = section.data[ indexPath.row ];
    setting.isEnabled = value;
    
    [self updateSettings];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - VNavigationHeaderDelegate

- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.hasValidSettings )
    {
        NSString *reuseId = NSStringFromClass([VNotificationSettingCell class]);
        VNotificationSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
        
        VNotificationSettingsSection *section = self.sections[ indexPath.section ];
        VNotificationSetting *setting = section.data[ indexPath.row ];
        [cell setTitle:setting.title value:setting.isEnabled];
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        return cell;
    }
    else
    {
        VNoContentTableViewCell *cell = [VNoContentTableViewCell createCellFromTableView:tableView];
        if ( self.settingsError != nil )
        {
            cell.message = self.settingsError.domain;
            cell.isCentered = YES;
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
    
    VNotificationSettingsSection *sectionData = self.sections[ section ];
    return sectionData.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX( self.sections.count, (NSUInteger)1 );
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    VNotificationSettingsSection *sectionData = self.sections[ section ];
    return sectionData.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 && !self.hasValidSettings )
    {
        return 100.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
