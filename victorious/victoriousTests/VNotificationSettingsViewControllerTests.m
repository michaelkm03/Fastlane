//
//  VNotificationSettingsViewControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDummyModels.h"
#import "NSObject+VMethodSwizzling.h"
#import "VNotificationSettings+Fetcher.h"
#import "VNotificationSettings+RestKit.h"
#import "VNotificationSettingsTableSection.h"
#import "VNotificationSettingsViewController.h"
#import "VTestHelpers.h"
#import "VObjectManager.h"
#import "VObjectManager+DeviceRegistration.h"
#import "VAsyncTestHelper.h"
#import "VNotificationSettingCell.h"
#import "VNoContentTableViewCell.h"

@interface VNotificationSettingsViewController (UnitTests)

- (void)settingsDidLoadWithResults:(NSArray *)resultObjects;
- (void)updateSettings;
- (void)saveSettings;
- (void)onError:(NSError *)error;
- (void)settingsDidUpdateFromCell:(VNotificationSettingCell *)cell;
- (void)updateSettingsAtIndexPath:(NSIndexPath *)indexPath withValue:(BOOL)value;

@property (nonatomic, assign, readonly) BOOL hasValidSettings;
@property (nonatomic, strong) NSError *settingsError;
@property (nonatomic, strong) VNotificationSettings *settings;
@property (nonatomic, strong) NSOrderedSet *sections;
@property (nonatomic, assign) BOOL didSettingsChange;

@end

@interface VNotificationSettingsViewControllerTests : XCTestCase

@property (nonatomic, strong) VNotificationSettingsViewController *viewController;
@property (nonatomic, strong) VNotificationSettings *randomSettings;
@property (nonatomic, strong) VNotificationSettings *defaultSettings;

@end

@implementation VNotificationSettingsViewControllerTests

- (void)setUp
{
    [super setUp];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings" bundle:[NSBundle mainBundle]];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VNotificationSettingsViewController class])];
    [self.viewController viewDidLoad];
    self.viewController.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
    
    self.randomSettings = [VDummyModels objectWithEntityName:[VNotificationSettings entityName]
                                                    subclass:[VNotificationSettings class]];
    // At least one should always be yes so that it doesn't equal the default settings
    self.randomSettings.isPostFromCreatorEnabled    = @YES;
    self.randomSettings.isNewFollowerEnabled        = @( randomBool() );
    self.randomSettings.isNewPrivateMessageEnabled  = @( randomBool() );
    self.randomSettings.isNewCommentOnMyPostEnabled = @( randomBool() );
    self.randomSettings.isPostFromFollowedEnabled   = @( randomBool() );
    
    self.defaultSettings = [VDummyModels objectWithEntityName:[VNotificationSettings entityName]
                                                     subclass:[VNotificationSettings class]];
    self.defaultSettings.isPostFromCreatorEnabled    = @NO;
    self.defaultSettings.isNewFollowerEnabled        = @NO;
    self.defaultSettings.isNewPrivateMessageEnabled  = @NO;
    self.defaultSettings.isNewCommentOnMyPostEnabled = @NO;
    self.defaultSettings.isPostFromFollowedEnabled   = @NO;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldSaveOnDisappear
{
    __block BOOL wasSaveSettingsCalled = NO;
    [VNotificationSettingsViewController v_swizzleMethod:@selector(saveSettings) withBlock:^void
     {
         wasSaveSettingsCalled = YES;
     }
                                            executeBlock:^
     {
         wasSaveSettingsCalled = NO;
         self.viewController.didSettingsChange = NO;
         self.viewController.settingsError = nil;
         [self.viewController viewWillDisappear:YES];
         XCTAssertFalse( wasSaveSettingsCalled );
         
         wasSaveSettingsCalled = NO;
         self.viewController.didSettingsChange = NO;
         self.viewController.settingsError = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
         [self.viewController viewWillDisappear:YES];
         XCTAssertFalse( wasSaveSettingsCalled );
         
         wasSaveSettingsCalled = NO;
         self.viewController.didSettingsChange = YES;
         self.viewController.settingsError = nil;
         [self.viewController viewWillDisappear:YES];
         XCTAssert( wasSaveSettingsCalled );
     }];
}

- (void)testCreateTableViewCells
{
    [self.viewController settingsDidLoadWithResults:@[ self.randomSettings ]];
    
    for ( NSInteger s = 0; s < (NSInteger)self.viewController.sections.count; s++ )
    {
        VNotificationSettingsTableSection *section = self.viewController.sections[ s ];
        for ( NSInteger r = -1; r < (NSInteger)section.rows.count + 1; r++ )
        {
            NSIndexPath *indexPath = VIndexPathMake(r, s);
            UITableViewCell *cell = nil;
            
            if ( s >= 0 && s < (NSInteger)self.viewController.sections.count &&
                 r >= 0 && r < (NSInteger)section.rows.count )
            {
                cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:indexPath];
                XCTAssert( [cell isKindOfClass:[VNotificationSettingCell class]] );
                XCTAssertNotNil( cell );
            }
            else
            {
                XCTAssertThrows( cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:indexPath] );
                XCTAssertNil( cell );
            }
        }
    }
    
    UITableViewCell *cell = nil;
    NSIndexPath *indexPath = VIndexPathMake(0, 0);
    [self.viewController onError:[NSError errorWithDomain:@"" code:-1 userInfo:nil]];
    cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:indexPath];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]] );
    XCTAssertNotNil( cell );
    
    indexPath = VIndexPathMake(0, 1);
    cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertNil( cell );
    
    indexPath = VIndexPathMake(1, 0);
    cell = [self.viewController tableView:self.viewController.tableView cellForRowAtIndexPath:indexPath];
    XCTAssertNil( cell );
}

- (void)testSaveError
{
    [VObjectManager setSharedManager:[[VObjectManager alloc] init]];
    
    // Swizzle the setDeviceSettings: method to ensure that it calls the failure block to simulate an error
    [VObjectManager v_swizzleMethod:@selector(setDeviceSettings:successBlock:failBlock:)
                          withBlock:^void (VObjectManager *objManager,
                                           VNotificationSettings *settings,
                                           VSuccessBlock success,
                                           VFailBlock failed)
    {
        failed( nil, [NSError errorWithDomain:@"" code:0 userInfo:nil] );
    }
                       executeBlock:^
     {
         __block BOOL presentWasCalled = NO;
         // Swizzle the presentViewController method to check that the presented view controller is an alert.
         // This proves that the alert was presented in response to the error saving the updated setttings
         [UIViewController v_swizzleMethod:@selector(presentViewController:animated:completion:) withBlock:^void(UIViewController *presenter, UIViewController *presentee)
          {
              XCTAssert( [presentee isKindOfClass:[UIAlertController class]] );
              presentWasCalled = YES;
          }
                              executeBlock:^
          {
              // Stickt the view controller in a navigation controller where the alert will be presented
              __unused UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
              // Save the settings (swizzling above ensures it will fail)
              [self.viewController saveSettings];
          }];
         XCTAssert( presentWasCalled );
     }];
}

- (void)testUpdateSettings
{
    // Set the initial settings
    self.viewController.settings = self.defaultSettings;
    [self assertSectionsAndRowsDefined];
    
    // Set our expected values
    VNotificationSettings *expectedSettings = self.defaultSettings;
    expectedSettings.isPostFromCreatorEnabled = @YES;
    expectedSettings.isNewFollowerEnabled = @YES;
    expectedSettings.isNewPrivateMessageEnabled = @YES;
    expectedSettings.isNewCommentOnMyPostEnabled = @YES;
    expectedSettings.isPostFromFollowedEnabled = @YES;
    
    // Simulate updates from UI
    [self.viewController updateSettingsAtIndexPath:VIndexPathMake(0, 0) withValue:YES];
    [self.viewController updateSettingsAtIndexPath:VIndexPathMake(1, 0) withValue:YES];
    [self.viewController updateSettingsAtIndexPath:VIndexPathMake(2, 0) withValue:YES];
    [self.viewController updateSettingsAtIndexPath:VIndexPathMake(0, 1) withValue:YES];
    [self.viewController updateSettingsAtIndexPath:VIndexPathMake(1, 1) withValue:YES];
    
    // Ensure that updates from UI update the view controller's settings
    XCTAssertEqual( self.viewController.settings.isPostFromCreatorEnabled, expectedSettings.isPostFromCreatorEnabled );
    XCTAssertEqual( self.viewController.settings.isNewFollowerEnabled, expectedSettings.isNewFollowerEnabled );
    XCTAssertEqual( self.viewController.settings.isNewPrivateMessageEnabled, expectedSettings.isNewPrivateMessageEnabled );
    XCTAssertEqual( self.viewController.settings.isNewCommentOnMyPostEnabled, expectedSettings.isNewCommentOnMyPostEnabled );
    XCTAssertEqual( self.viewController.settings.isPostFromFollowedEnabled, expectedSettings.isPostFromFollowedEnabled );
}

- (void)testHandleErrorResponse
{
    NSError *error = nil;
    
    error = [NSError errorWithDomain:@"" code:5000 userInfo:nil];
    [self.viewController onError:error];
    XCTAssertNotNil( self.viewController.settingsError );
    XCTAssertFalse( self.viewController.hasValidSettings );
    
    error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
    [self.viewController onError:error];
    XCTAssertNotNil( self.viewController.settingsError );
    XCTAssertFalse( self.viewController.hasValidSettings );
}

- (void)testHandleLoadResponse
{
    [VNotificationSettings v_swizzleClassMethod:@selector(createDefaultSettings) withBlock:(VNotificationSettings *)^
    {
        return self.defaultSettings;
    }
                                   executeBlock:^
    {
        [self.viewController settingsDidLoadWithResults:@[ self.randomSettings ]];
        XCTAssertNil( self.viewController.settingsError );
        XCTAssert( self.viewController.hasValidSettings );
        XCTAssertEqualObjects( self.viewController.settings, self.randomSettings );
        [self assertSectionsAndRowsDefined];
        [self assertSectionStructureMatchesSettings:self.randomSettings  ];
        XCTAssert( self.viewController.hasValidSettings );
        
        [self.viewController settingsDidLoadWithResults:@[]];
        XCTAssertNil( self.viewController.settingsError );
        XCTAssert( self.viewController.hasValidSettings );
        XCTAssertEqualObjects( self.viewController.settings, self.defaultSettings );
        [self assertSectionsAndRowsDefined];
        [self assertSectionStructureMatchesSettings:self.defaultSettings];
        XCTAssert( self.viewController.hasValidSettings );
        
        [self.viewController settingsDidLoadWithResults:@[ [NSNull null] ]];
        XCTAssertNil( self.viewController.settingsError );
        XCTAssert( self.viewController.hasValidSettings );
        XCTAssertEqualObjects( self.viewController.settings, self.defaultSettings );
        [self assertSectionsAndRowsDefined];
        [self assertSectionStructureMatchesSettings:self.defaultSettings];
        XCTAssert( self.viewController.hasValidSettings );
    }];
}

- (void)assertSectionStructureMatchesSettings:(VNotificationSettings *)settings
{
    XCTAssertEqual( [self.viewController.sections[0] rowAtIndex:0].isEnabled,
                   settings.isPostFromCreatorEnabled.boolValue );
    XCTAssertEqual( [self.viewController.sections[0] rowAtIndex:1].isEnabled,
                   settings.isPostFromFollowedEnabled.boolValue );
    XCTAssertEqual( [self.viewController.sections[0] rowAtIndex:2].isEnabled,
                   settings.isNewCommentOnMyPostEnabled.boolValue );
    XCTAssertEqual( [self.viewController.sections[1] rowAtIndex:0].isEnabled,
                   settings.isNewPrivateMessageEnabled.boolValue );
    XCTAssertEqual( [self.viewController.sections[1] rowAtIndex:1].isEnabled,
                   settings.isNewFollowerEnabled.boolValue );
}

- (void)assertSectionsAndRowsDefined
{
    XCTAssertEqual( self.viewController.sections.count, (NSUInteger)2 );
    XCTAssertNotNil( [self.viewController.sections[0] rowAtIndex:0] );
    XCTAssertNotNil( [self.viewController.sections[0] rowAtIndex:1] );
    XCTAssertNotNil( [self.viewController.sections[0] rowAtIndex:2] );
    XCTAssertNotNil( [self.viewController.sections[1] rowAtIndex:0] );
    XCTAssertNotNil( [self.viewController.sections[1] rowAtIndex:1] );
}

- (void)testSection
{
    NSString *title = @"title";
    
    NSArray *rows = @[ [[VNotificationSettingsTableRow alloc] initWithTitle:@"1" enabled:YES],
                       [[VNotificationSettingsTableRow alloc] initWithTitle:@"2" enabled:NO],
                       [[VNotificationSettingsTableRow alloc] initWithTitle:@"3" enabled:YES] ];
    VNotificationSettingsTableSection *section = [[VNotificationSettingsTableSection alloc] initWithTitle:title rows:rows];
    XCTAssertEqualObjects( section.title, title );
    XCTAssertEqual( section.rows.count, rows.count );
    [rows enumerateObjectsUsingBlock:^(VNotificationSettingsTableRow *row, NSUInteger idx, BOOL *stop)
    {
        XCTAssertEqualObjects( row, [section rowAtIndex:idx] );
    }];
    
    XCTAssertThrows( [section rowAtIndex:-1] );
    XCTAssertThrows( [section rowAtIndex:rows.count] );
}

@end
