////
////  VPushNotificationManagerTests.m
////  victorious
////
////  Created by Sebastian Nystorm on 6/10/15.
////  Copyright © 2015 Victorious. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import <OCMock/OCMock.h>
//#import "VPushNotificationManager.h"
//
//#import "NSObject+VMethodSwizzling.h"
//
//@interface VPushNotificationManager ()
//
//- (NSData *)storedToken;
//- (BOOL)storeNewToken:(NSData *)token;
//
//@end
//
//NSString *const VTestPushNotificationTokenString = @"AAAAAAAAAAAAAAAAABBBBBBBBBBBBBBB";
//
//@interface VPushNotificationManagerTests : XCTestCase
//
//@property (nonatomic, strong) VPushNotificationManager *notificationManager;
//@property (nonatomic, strong) NSData *pushTokenData;
//
//@end
//
//@implementation VPushNotificationManagerTests
//
//- (void)setUp
//{
//    [super setUp];
//
//    self.notificationManager = [VPushNotificationManager sharedPushNotificationManager];
//    self.pushTokenData = [VTestPushNotificationTokenString dataUsingEncoding:NSUTF8StringEncoding];
//}
//
//- (void)tearDown
//{
//    [self.notificationManager storeNewToken:nil];
//    [super tearDown];
//}
//
//- (void)testTokenStored
//{
//    id notificationManagerMock = OCMPartialMock(self.notificationManager);
//    OCMStub([notificationManagerMock sendTokenWithSuccessBlock:nil failBlock:nil]);
//    
//    // Send in a push notification token and confirm it gets stored in the class.
//    [notificationManagerMock didRegisterForRemoteNotificationsWithDeviceToken:self.pushTokenData];
//    
//    NSData *storedToken = [notificationManagerMock storedToken];
//    XCTAssertNotNil(storedToken);
//    XCTAssertTrue([self.pushTokenData isEqualToData:storedToken]);
//}
//
//- (void)testSameTokenSetTwice
//{
//    // Send in the same push notification token twice and confirm it does not get sent to the server twice.
//    __block NSInteger selectorCallCount = 0;
//
//    [VPushNotificationManager v_swizzleMethod:@selector(sendTokenWithSuccessBlock:failBlock:)
//                                    withBlock:^void
//     {
//         selectorCallCount++;
//     }                           executeBlock:^
//     {
//         NSData *duplicatedData = self.pushTokenData;
//         [self.notificationManager didRegisterForRemoteNotificationsWithDeviceToken:duplicatedData];
//         [self.notificationManager didRegisterForRemoteNotificationsWithDeviceToken:duplicatedData];
//
//         XCTAssertEqual(selectorCallCount, 1);
//     }];
//}
//
//@end
