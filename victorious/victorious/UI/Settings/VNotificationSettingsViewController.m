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


@interface VNotificationSettingsViewController() <VNavigationHeaderDelegate>

@property (nonatomic, strong) NSOrderedSet *sections;

@end


@implementation VNotificationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    NSArray *sectionFeedData = @[ [[VNotificationSetting alloc] initWithTitle:@"Title 1" enabled:YES],
                                  [[VNotificationSetting alloc] initWithTitle:@"Title 2" enabled:NO],
                                  [[VNotificationSetting alloc] initWithTitle:@"Title 3" enabled:YES],
                                  [[VNotificationSetting alloc] initWithTitle:@"Title 4" enabled:NO]];
    VNotificationSettingsSection *sectionFeed = [[VNotificationSettingsSection alloc] initWithTitle:@"Feed" data:sectionFeedData ];
    
    NSArray *sectionPeopleData = @[ [[VNotificationSetting alloc] initWithTitle:@"Title 1" enabled:YES],
                                    [[VNotificationSetting alloc] initWithTitle:@"Title 2" enabled:NO]];
    VNotificationSettingsSection *sectionPeople = [[VNotificationSettingsSection alloc] initWithTitle:@"People" data:sectionPeopleData ];
    self.sections = [[NSOrderedSet alloc] initWithObjects:sectionFeed, sectionPeople, nil];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
    
    [self refresh];
}

- (void)refresh
{
    [[VObjectManager sharedManager] getDevicePreferencesSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        
    }
                                                           failBlock:^(NSOperation *operation, NSError *error)
     {
         
     }];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - VNavigationHeaderDelegate

- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([VNotificationSettingCell class]);
    VNotificationSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
    
    VNotificationSettingsSection *section = self.sections[ indexPath.section ];
    VNotificationSetting *setting = section.data[ indexPath.row ];
    [cell setLabel:setting.title withValue:setting.isEnabled];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VNotificationSettingsSection *sectionData = self.sections[ section ];
    return sectionData.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    VNotificationSettingsSection *sectionData = self.sections[ section ];
    return sectionData.title;
}

@end
