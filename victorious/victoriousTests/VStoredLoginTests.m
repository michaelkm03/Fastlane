//
//  VStoredLoginTests.m
//  victorious
//
//  Created by Patrick Lynch on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSObject+VMethodSwizzling.h"
#import "VStoredLogin.h"
#import "VDummyModels.h"
#import "VUser+RestKit.h"

@interface VStoredLogin()

- (VUser *)createNewUserWithRemoteId:(NSNumber *)remoteId token:(NSString *)token;
- (BOOL)isTokenExpirationDateExpired:(NSDate *)creationDate;

@end

static NSString * const kTestToken = @"dsadasdsa8ga7fb976dafga8bs6fgabdsfdsa";

@interface VStoredLoginTests : XCTestCase

@property (nonatomic, strong) VStoredLogin *storedLogin;
@property (nonatomic, assign) IMP createUserImplementation;

@end

@implementation VStoredLoginTests

- (void)setUp
{
    [super setUp];
    
    self.storedLogin = [[VStoredLogin alloc] init];
    [self.storedLogin clearLoggedInUserFromDisk];
    
    SEL selector = @selector(createNewUserWithRemoteId:token:);
    self.createUserImplementation =  [VStoredLogin v_swizzleMethod:selector withBlock:^VUser *(id obj, NSNumber *remoteId, NSString *token)
                                      {
                                          VUser *user = [VDummyModels objectWithEntityName:[VUser entityName] subclass:[VUser class]];
                                          user.remoteId = remoteId;
                                          user.token = token;
                                          return user;
                                      }];
}

- (void)tearDown
{
    [super tearDown];
    
    [VStoredLogin v_restoreOriginalImplementation:self.createUserImplementation forMethod:@selector(createNewUserWithRemoteId:token:)];
}

- (void)testSaveLoggedInUser
{
    VStoredLoginInfo *storedLoginInfo = nil;
    
    storedLoginInfo = [self.storedLogin storedLoginInfo];
    XCTAssertNil( storedLoginInfo, @"Should return nil before a call to `saveLoggedInUserToDisk:`" );
    
    VUser *loggedInUser = [VDummyModels objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    loggedInUser.remoteId = @(202);
    loggedInUser.token = kTestToken;
    loggedInUser.loginType = [NSNumber numberWithInt:VLoginTypeEmail];
    XCTAssert( [self.storedLogin saveLoggedInUserToDisk:loggedInUser] );
    
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:loggedInUser], @"Should NOT save the same token again." );
    
    loggedInUser.token = @"adifferenttokendasoidsapd78ash0kd7as80das";
    XCTAssert( [self.storedLogin saveLoggedInUserToDisk:loggedInUser], @"Should save the a different token." );
    
    storedLoginInfo = [self.storedLogin storedLoginInfo];
    XCTAssertNotNil( storedLoginInfo );
    XCTAssertEqual( storedLoginInfo.lastLoginType, (VLoginType)loggedInUser.loginType.integerValue );
    XCTAssertEqualObjects( storedLoginInfo.userRemoteId, loggedInUser.remoteId );
    XCTAssertEqualObjects( storedLoginInfo.token, loggedInUser.token );
    
    XCTAssert( [self.storedLogin clearLoggedInUserFromDisk] );
    XCTAssertNil( storedLoginInfo, @"Should return nil after a call to `clearLoggedInUserFromDisk`" );
    
    XCTAssertFalse( [self.storedLogin clearLoggedInUserFromDisk], @"Shouldn't clear if already cleared." );
}

- (void)testSaveLoggedInUserInvalid
{
    VUser *loggedInUser = [VDummyModels objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    
    loggedInUser.remoteId = @(0);
    loggedInUser.token = kTestToken;
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:loggedInUser] );
    
    loggedInUser.remoteId = nil;
    loggedInUser.token = kTestToken;
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:loggedInUser] );
    
    loggedInUser.remoteId = @(32);
    loggedInUser.token = nil;
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:loggedInUser] );
    
    loggedInUser.remoteId = @(32);
    loggedInUser.token = @"";
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:loggedInUser] );
}

- (void)testLoadLastLoggedInUser
{
    VUser *loggedInUser = [VDummyModels objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    loggedInUser.remoteId = @(202);
    loggedInUser.token = kTestToken;
    [self.storedLogin saveLoggedInUserToDisk:loggedInUser];
    
    [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
     {
         return NO;
     }
                     executeBlock:^
     {
         VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
         XCTAssertNotNil( storedLoginInfo  );
         XCTAssertEqual( storedLoginInfo.lastLoginType, (VLoginType)loggedInUser.loginType.integerValue );
         XCTAssertEqualObjects( storedLoginInfo.userRemoteId, loggedInUser.remoteId );
         XCTAssertEqualObjects( storedLoginInfo.token, loggedInUser.token );
     }];
    
    [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
     {
         return YES;
     }
                     executeBlock:^
     {
         VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
         XCTAssertNil( storedLoginInfo  );
     }];
}

- (void)testTokenExpiration
{
    NSTimeInterval anticipationDuration = 60 * 60; ///< 1 hour in seconds
    NSDate *expirationDate;
    
    expirationDate = [NSDate dateWithTimeIntervalSinceNow:anticipationDuration + 5];  // Just before expiration date
    XCTAssertFalse( [self.storedLogin isTokenExpirationDateExpired:expirationDate] );
    
    expirationDate = [NSDate dateWithTimeIntervalSinceNow:anticipationDuration]; // Exactly on expiration date
    XCTAssert( [self.storedLogin isTokenExpirationDateExpired:expirationDate] );
    
    expirationDate = [NSDate dateWithTimeIntervalSinceNow:anticipationDuration - 5]; // Just after expiration date
    XCTAssert( [self.storedLogin isTokenExpirationDateExpired:expirationDate] );
}

- (void)testLoginType
{
    VUser *loggedInUser = [VDummyModels objectWithEntityName:[VUser entityName] subclass:[VUser class]];
    loggedInUser.remoteId = @(202);
    loggedInUser.token = kTestToken;
    
    for ( NSInteger i = 0; i < 4; i++ )
    {
        loggedInUser.loginType = [NSNumber numberWithInteger:i];
        [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
         {
             return NO;
         }
                         executeBlock:^
         {
             VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
             [self.storedLogin saveLoggedInUserToDisk:loggedInUser];
             XCTAssertNotNil( storedLoginInfo );
             XCTAssertEqual( storedLoginInfo.lastLoginType, (VLoginType)loggedInUser.loginType.integerValue );
             [self.storedLogin clearLoggedInUserFromDisk];
         }];
    }
    
    for ( NSInteger i = 0; i < 4; i++ )
    {
        loggedInUser.loginType = [NSNumber numberWithInteger:i];
        [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
         {
             return YES;
         }
                         executeBlock:^
         {
             VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
             [self.storedLogin saveLoggedInUserToDisk:loggedInUser];
             XCTAssertNotNil( storedLoginInfo );
             XCTAssertEqual( storedLoginInfo.lastLoginType, (VLoginType)loggedInUser.loginType.integerValue );
         }];
    }
}

@end
