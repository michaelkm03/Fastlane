//
//  VFirstInstallTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VTrackingManager.h"
#import "VFirstInstallManager.h"
#import "VObjectManager+Analytics.h"
#import "NSObject+VMethodSwizzling.h"

@interface VFirstInstallManager (UnitTests)

- (void)trackEvent;
- (void)trackEventWithOldMethod;

@end

@interface VFirstInstallTests : XCTestCase

@end

@implementation VFirstInstallTests

- (void)setUp
{
    [super setUp];
    
    [VObjectManager setSharedManager:[[VObjectManager alloc] init]];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledOldTrackingDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey] );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFirstInstallOld
{
    __block BOOL wasTrackingEventCalled = NO;
    [VObjectManager v_swizzleMethod:@selector(addEvents:successBlock:failBlock:) withBlock:^void
     {
         [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledOldTrackingDefaultsKey];
         wasTrackingEventCalled = YES;
     }
                       executeBlock:^void
     {
         [[[VFirstInstallManager alloc] init] trackEventWithOldMethod];
         id defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey];
         XCTAssertEqualObjects( defaultsValue, @YES );
         XCTAssert( wasTrackingEventCalled );
     }];
    
    wasTrackingEventCalled = NO;
    [VObjectManager v_swizzleMethod:@selector(addEvents:successBlock:failBlock:) withBlock:^void
     {
         wasTrackingEventCalled = YES;
     }
                       executeBlock:^void
     {
         [[[VFirstInstallManager alloc] init] trackEventWithOldMethod];
         id defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey];
         XCTAssertEqualObjects( defaultsValue, @YES );
         XCTAssertFalse( wasTrackingEventCalled, @"Tracking event response should only be called once." );
     }];
}

- (void)testFirstInstall
{
    __block BOOL wasTrackingEventCalled = NO;
    [VTrackingManager v_swizzleMethod:@selector(trackEvent:parameters:) withBlock:^void
     {
         wasTrackingEventCalled = YES;
     }
                         executeBlock:^void
     {
         [[[VFirstInstallManager alloc] init] trackEvent];
         id defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
         XCTAssertEqualObjects( defaultsValue, @YES );
         XCTAssert( wasTrackingEventCalled );
     }];
    
    wasTrackingEventCalled = NO;
    [VTrackingManager v_swizzleMethod:@selector(trackEvent:parameters:) withBlock:^void
     {
         wasTrackingEventCalled = YES;
     }
                         executeBlock:^void
     {
         [[[VFirstInstallManager alloc] init] trackEvent];
         id defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
         XCTAssertEqualObjects( defaultsValue, @YES );
         XCTAssertFalse( wasTrackingEventCalled, @"Tracking event response should only be called once." );
     }];
}

- (void)testFirstInstallBoth
{
    __block BOOL wasNewMethodCalled = NO;
    __block BOOL wasOldMethodCalled = NO;
    IMP newMethod = [VFirstInstallManager v_swizzleMethod:@selector(trackEvent) withBlock:^void
                     {
                         wasNewMethodCalled = YES;
                     }];
    IMP oldMethod = [VFirstInstallManager v_swizzleMethod:@selector(trackEventWithOldMethod) withBlock:^void
                     {
                         wasOldMethodCalled = YES;
                     }];
    
    [[[VFirstInstallManager alloc] init] reportFirstInstall];
    XCTAssert( wasNewMethodCalled );
    XCTAssert( wasOldMethodCalled );
    
    [VFirstInstallManager v_restoreOriginalImplementation:newMethod forMethod:@selector(trackEvent)];
    [VFirstInstallManager v_restoreOriginalImplementation:oldMethod forMethod:@selector(trackEventWithOldMethod)];
}

@end
