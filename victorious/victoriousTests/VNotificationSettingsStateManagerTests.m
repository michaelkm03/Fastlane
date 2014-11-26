//
//  VNotificationSettingsStateManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VNotificationSettingsStateManager.h"
#import "VPushNotificationManager.h"
#import "NSObject+VMethodSwizzling.h"
#import "VNotificationSettingsTestDelegate.h"

@interface VNotificationSettingsStateManager (UnitTests)

@property (nonatomic, readonly) NSError *errorDeviceNotFound;
@property (nonatomic, readonly) NSError *errorUnknown;
@property (nonatomic, readonly) NSError *errorNotRegistered;

- (void)startListeningForRegistrationNotification;
- (void)stopListeningForRegistrationNotification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;

@end

@interface VNotificationSettingsStateManagerTests : XCTestCase

@property (nonatomic, strong) VNotificationSettingsStateManager *stateManager;
@property (nonatomic, strong) VNotificationSettingsTestDelegate *delegate;

@end

@implementation VNotificationSettingsStateManagerTests

- (void)setUp
{
    [super setUp];
    
    self.delegate = [[VNotificationSettingsTestDelegate alloc] init];
    self.stateManager = [[VNotificationSettingsStateManager alloc] initWithDelegate:self.delegate];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDefaultRegistered
{
    [VPushNotificationManager v_swizzleMethod:@selector(isRegisteredForPushNotifications) withBlock:^BOOL
     {
         return YES;
     } executeBlock:^
     {
         self.stateManager.state = VNotificationSettingsStateDefault;
         XCTAssertEqual( self.stateManager.state, VNotificationSettingsStateRegistered );
     }];
}

- (void)testDefaultNotRegistered
{
    [VPushNotificationManager v_swizzleMethod:@selector(isRegisteredForPushNotifications) withBlock:^BOOL
     {
         return NO;
     } executeBlock:^
     {
         self.stateManager.state = VNotificationSettingsStateDefault;
         XCTAssertEqual( self.stateManager.state, VNotificationSettingsStateNotRegistered );
     }];
}

- (void)testRegistered
{
    self.stateManager.state = VNotificationSettingsStateRegistered;
    XCTAssert( self.delegate.onDeviceDidRegisterWithOSCalled );
}

- (void)testNotRegistered
{
    self.stateManager.state = VNotificationSettingsStateNotRegistered;
    XCTAssertNotNil( self.delegate.error );
    XCTAssertEqualObjects( self.delegate.error, self.stateManager.errorNotRegistered );
}

- (void)testUnknownErrors
{
    self.stateManager.state = VNotificationSettingsStateRegistrationFailed;
    XCTAssertEqualObjects( self.delegate.error, self.stateManager.errorUnknown );
    
    self.stateManager.state = VNotificationSettingsStateLoadSettingsFailed;
    XCTAssertEqualObjects( self.delegate.error, self.stateManager.errorUnknown );
}

- (void)testDeviceNotFound
{
    [VPushNotificationManager v_swizzleMethod:@selector(sendTokenWithSuccessBlock:failBlock:)
                                    withBlock:^void ( id obj, void(^success)(), void(^failure)(NSError *error) )
     {
         failure(nil);
     } executeBlock:^
     {
         self.stateManager.state = VNotificationSettingsStateDeviceNotFound;
         XCTAssertEqual( self.stateManager.state, VNotificationSettingsStateRegistrationFailed );
     }];
    
    [VPushNotificationManager v_swizzleMethod:@selector(sendTokenWithSuccessBlock:failBlock:)
                                    withBlock:^void ( id obj, void(^success)(), void(^failure)(NSError *error) )
     {
         success();
     } executeBlock:^
     {
         self.stateManager.state = VNotificationSettingsStateDeviceNotFound;
         XCTAssertEqual( self.stateManager.state, VNotificationSettingsStateRegistered );
     }];
}

- (void)testNotificationListeners
{
    __block BOOL wasSelectorCalled = NO;
    [VNotificationSettingsStateManager v_swizzleMethod:@selector(applicationDidBecomeActive:) withBlock:^void
    {
        wasSelectorCalled = YES;
    } executeBlock:^
     {
         wasSelectorCalled = NO;
         [self.stateManager stopListeningForRegistrationNotification];
         [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
         XCTAssertFalse( wasSelectorCalled );
         
         wasSelectorCalled = NO;
         [self.stateManager startListeningForRegistrationNotification];
         [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
         XCTAssert( wasSelectorCalled );
         
     }];
}

@end
