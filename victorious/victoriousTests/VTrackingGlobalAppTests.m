//
//  VTrackingGlobalAppTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSObject+VMethodSwizzling.h"
#import "VAsyncTestHelper.h"
#import "VAppDelegate.h"
#import "VSettingManager.h"
#import "VTrackingManager.h"
#import "VTracking.h"
#import "VObjectManager+Login.h"
#import "VDummyModels.h"

static NSString * const kTestTrackingUrlEnterForeground     = @"http://www.example.com/app-start";
static NSString * const kTestTrackingUrlEnterBackground     = @"http://www.example.com/app-stop";
static NSString * const kTestTrackingUrlLaunch              = @"http://www.example.com/app-init";

@interface VTrackingManager (UnitTests)

- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters;

@end

@interface VAppDelegate (UnitTests)

- (void)onInitResponse:(NSNotification *)notification;
- (void)initializeTracking;

@property (strong, nonatomic) VTrackingManager *trackingManager;

@end

@interface VTrackingGlobalAppTests : XCTestCase

@property (nonatomic, strong) VAppDelegate *appDelegate;
@property (nonatomic, strong) VTracking *tracking;
@property (nonatomic, strong) VAsyncTestHelper *async;
@property (nonatomic, strong) VSettingManager *settingsManager;

@end

@implementation VTrackingGlobalAppTests

- (void)setUp
{
    [super setUp];
    
    self.async = [[VAsyncTestHelper alloc] init];
    
    self.appDelegate = [[VAppDelegate alloc] init];
    [self.appDelegate initializeTracking];
    
    self.settingsManager = [VSettingManager sharedManager];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTrackingInitialization
{
    XCTAssertNotNil( self.appDelegate.trackingManager, @"Tracking manager should be initialized." );
    
    __block BOOL wasNotificationReceived = NO;
    IMP orig = [VAppDelegate v_swizzleMethod:@selector(onInitResponse:) withBlock:^void
                {
                    wasNotificationReceived = YES;
                }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInitResponseNotification object:nil];
    XCTAssert( wasNotificationReceived );
    
    [VAppDelegate v_restoreOriginalImplementation:orig forMethod:@selector(onInitResponse:)];
}

- (void)testTrackingInitializationNotMoreThanOnce
{
    [self.appDelegate onInitResponse:nil];
    
    __block BOOL wasNotificationReceived = NO;
    IMP orig = [VAppDelegate v_swizzleMethod:@selector(onInitResponse:) withBlock:^void
                {
                    wasNotificationReceived = YES;
                }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInitResponseNotification object:nil];
    XCTAssertFalse( wasNotificationReceived, @"This notification should NOT be received again after onInitResponse: is called." );
    
    [VAppDelegate v_restoreOriginalImplementation:orig forMethod:@selector(onInitResponse:)];
}

- (void)testTrackingEnterForeground
{
    __block VTracking *tracking = [VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
    tracking.appEnterForeground = @[ kTestTrackingUrlEnterForeground, kTestTrackingUrlEnterForeground, kTestTrackingUrlEnterForeground ];
    [self.settingsManager updateSettingsWithAppTracking:tracking];
    
    XCTAssertNotNil( self.settingsManager.applicationTracking );
    
    __block BOOL wasNotificationReceived = NO;
    IMP orig = [VTrackingManager v_swizzleMethod:@selector(trackEventWithUrls:andParameters:) withBlock:^void (VTrackingManager *trackingManager, NSArray *urls, NSDictionary *parameters)
                {
                    wasNotificationReceived = YES;
                    XCTAssertEqual( ((NSArray *)tracking.appEnterForeground).count, urls.count );
                    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
                        XCTAssertEqualObjects( url, tracking.appEnterForeground[ idx ] );
                    }];
                }];
    
    [self.appDelegate applicationWillEnterForeground:nil];
    XCTAssert( wasNotificationReceived );
    
    [VTrackingManager v_restoreOriginalImplementation:orig forMethod:@selector(trackEventWithUrls:andParameters:)];
}

- (void)testTrackingEnterBackground
{
    __block VTracking *tracking = [VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
    tracking.appEnterBackground = @[ kTestTrackingUrlEnterBackground, kTestTrackingUrlEnterBackground, kTestTrackingUrlEnterBackground ];
    [self.settingsManager updateSettingsWithAppTracking:tracking];
    
    XCTAssertNotNil( self.settingsManager.applicationTracking );
    
    __block BOOL wasNotificationReceived = NO;
    IMP orig = [VTrackingManager v_swizzleMethod:@selector(trackEventWithUrls:andParameters:) withBlock:^void (VTrackingManager *trackingManager, NSArray *urls, NSDictionary *parameters)
                {
                    wasNotificationReceived = YES;
                    XCTAssertEqual( ((NSArray *)tracking.appEnterBackground).count, urls.count );
                    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
                        XCTAssertEqualObjects( url, tracking.appEnterBackground[ idx ] );
                    }];
                }];
    
    [self.appDelegate applicationDidEnterBackground:nil];
    XCTAssert( wasNotificationReceived );
    
    [VTrackingManager v_restoreOriginalImplementation:orig forMethod:@selector(trackEventWithUrls:andParameters:)];
}

@end
