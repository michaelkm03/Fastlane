//
//  VFirstInstallTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFirstInstallManager.h"
#import "NSObject+VMethodSwizzling.h"

@interface VFirstInstallManager (UnitTests)

- (void)trackEvent;
- (void)trackEventWithOldMethod;

@end

@interface VFirstInstallTests : XCTestCase

@property (nonatomic, assign) BOOL wasOldTrackingMethodCalled;
@property (nonatomic, assign) BOOL wasNewTrackingMethodCalled;

@property (nonatomic, assign) IMP oldTrackingMethodImp;
@property (nonatomic, assign) IMP newTrackingMethodImp;

@end

@implementation VFirstInstallTests

- (void)setUp
{
    [super setUp];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    
    self.oldTrackingMethodImp = [VFirstInstallManager v_swizzleMethod:@selector(trackEventWithOldMethod) withBlock:^void
                                 {
                                     self.wasOldTrackingMethodCalled = YES;
                                 }];
    
    self.newTrackingMethodImp = [VFirstInstallManager v_swizzleMethod:@selector(trackEvent) withBlock:^void
                                 {
                                     self.wasNewTrackingMethodCalled = YES;
                                 }];
}

- (void)tearDown
{
    [super tearDown];
    
    [VFirstInstallManager v_restoreOriginalImplementation:self.oldTrackingMethodImp forMethod:@selector(trackEventWithOldMethod)];
    [VFirstInstallManager v_restoreOriginalImplementation:self.newTrackingMethodImp forMethod:@selector(trackEvent)];
}

- (void)testFirstInstall
{
    [[[VFirstInstallManager alloc] init] reportFirstInstall];
    XCTAssertNotNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    XCTAssertEqualObjects( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey], @YES );
    XCTAssert( self.wasOldTrackingMethodCalled );
    XCTAssert( self.wasNewTrackingMethodCalled );
    
    self.wasOldTrackingMethodCalled = NO;
    self.wasNewTrackingMethodCalled = NO;
    [[[VFirstInstallManager alloc] init] reportFirstInstall];
    XCTAssertNotNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    XCTAssertEqualObjects( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey], @YES );
    XCTAssertFalse( self.wasOldTrackingMethodCalled );
    XCTAssertFalse( self.wasNewTrackingMethodCalled );
}

@end
