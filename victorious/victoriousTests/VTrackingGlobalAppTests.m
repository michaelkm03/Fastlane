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

@interface VTrackingManager (UnitTests)

- (void)sendRequestWithUrlString:(NSString *)url;

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
    
    self.settingsManager = [[VSettingManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTrackingInitialization
{
    XCTAssertNotNil( self.appDelegate.trackingManager, @"Tracking manager should be initialized." );
    
    __block BOOL wasNotificationReceived = NO;
    IMP orig = [VAppDelegate v_swizzleMethod:@selector(onInitResponse:) withBlock:^void (NSNotification *notification)
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
    IMP orig = [VAppDelegate v_swizzleMethod:@selector(onInitResponse:) withBlock:^void (NSNotification *notification)
                {
                    wasNotificationReceived = YES;
                }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInitResponseNotification object:nil];
    XCTAssertFalse( wasNotificationReceived, @"This notification should NOT be received again after onInitResponse: is called." );
    
    [VAppDelegate v_restoreOriginalImplementation:orig forMethod:@selector(onInitResponse:)];
}

@end
