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
    for ( NSUInteger i = 0; i < 2; i++ )
    {
        BOOL isFirstTimeCalled = i == 0;
        
        __block BOOL wasTrackingEventCalled = NO;
        [VTrackingManager v_swizzleMethod:@selector(trackEvent:parameters:) withBlock:^void (VTrackingManager *trackingManager,
                                                                                             NSString *eventName,
                                                                                             NSDictionary *parameters)
         {
             NSArray *urls = parameters[ VTrackingKeyUrls ];
             NSArray *expectedUrls = (NSArray *)self.tracking.appInstall;
             XCTAssertNotNil( urls );
             XCTAssert( [urls isKindOfClass:[NSArray class]] );
             XCTAssertEqual( urls.count, expectedUrls.count );
             for ( NSUInteger i = 0; i < expectedUrls.count; i++ )
             {
                 XCTAssertEqualObjects( urls[i], expectedUrls[i] );
             }
             wasTrackingEventCalled = YES;
         }
                             executeBlock:^void
         {
             [[[VFirstInstallManager alloc] init] reportFirstInstallWithTrackingURLs:self.tracking.appInstall];
             id defaultsValue = [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey];
             XCTAssertEqualObjects( defaultsValue, @YES );
             
             if ( isFirstTimeCalled )
             {
                 XCTAssert( wasTrackingEventCalled );
             }
             else
             {
                 XCTAssertFalse( wasTrackingEventCalled );
             }
         }];
    }

- (void)testFirstInstallWithOldKey
{
    XCTAssertFalse( self.firstInstallManager.hasFirstInstallBeenTracked );
    
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VAppInstalledOldTrackingDefaultsKey];
    
    // Now report first install with the new key and make sure it doesn't call the tracking method
    __block BOOL wasTrackingEventCalled = NO;
    [VTrackingManager v_swizzleMethod:@selector(trackEvent:parameters:) withBlock:^void
     {
         wasTrackingEventCalled = YES;
     }
                         executeBlock:^void
     {
         [[[VFirstInstallManager alloc] init] reportFirstInstallWithTrackingURLs:nil];
         XCTAssertFalse( wasTrackingEventCalled );
     }];
}

@end
