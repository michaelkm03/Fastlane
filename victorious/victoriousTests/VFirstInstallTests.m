//
//  VFirstInstallTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFirstInstallManager.h"

@interface VFirstInstallTests : XCTestCase

@property (nonatomic, strong) VFirstInstallManager *firstInstallManager;

@end

@implementation VFirstInstallTests

- (void)setUp
{
    [super setUp];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledOldTrackingDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey] );
    
    self.firstInstallManager = [[VFirstInstallManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFirstInstal
{
    XCTAssertFalse( self.firstInstallManager.hasFirstInstallBeenTracked );
    [self.firstInstallManager reportFirstInstall];
    XCTAssert( self.firstInstallManager.hasFirstInstallBeenTracked );
    
    VFirstInstallManager *anotherFirstInstallManager = [[VFirstInstallManager alloc] init];
    XCTAssert( anotherFirstInstallManager.hasFirstInstallBeenTracked );
}

- (void)testFirstInstallWithOldKey
{
    XCTAssertFalse( self.firstInstallManager.hasFirstInstallBeenTracked );
    
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledOldTrackingDefaultsKey];
    
    XCTAssert( self.firstInstallManager.hasFirstInstallBeenTracked );
}

@end
