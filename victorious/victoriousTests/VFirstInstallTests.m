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
#import "NSObject+VMethodSwizzling.h"

@interface VFirstInstallTests : XCTestCase

@property (nonatomic, strong) NSArray *trackingURLs;
@property (nonatomic, strong) VTracking *tracking;

@end

@implementation VFirstInstallTests

- (void)setUp
{
    [super setUp];
    
    self.trackingURLs = @[ @"url1", @"url2" ];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledDefaultsKey] );
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VAppInstalledOldTrackingDefaultsKey];
    XCTAssertNil( [[NSUserDefaults standardUserDefaults] valueForKey:VAppInstalledOldTrackingDefaultsKey] );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFirstInstall
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
             NSArray *expectedUrls = self.trackingURLs;
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
             [[[VFirstInstallManager alloc] init] reportFirstInstallWithTrackingURLs:self.trackingURLs];
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
}

- (void)testFirstInstallWithOldKey
{
    // Simulate a previous version of the app markign first install using the old key
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
