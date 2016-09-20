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
#import "victorious-swift.h"

@interface VStoredLogin()

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
}

- (void)testSaveLoggedInUser
{
    VStoredLoginInfo *storedLoginInfo = nil;
    
    storedLoginInfo = [self.storedLogin storedLoginInfo];
    XCTAssertNil( storedLoginInfo, @"Should return nil before a call to `saveLoggedInUserToDisk:`" );
    
    VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init:@(202) withToken:kTestToken withLoginType:VLoginTypeEmail];
    XCTAssert( [self.storedLogin saveLoggedInUserToDisk:info] );
    
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:info], @"Should NOT save the same token again." );
    
    storedLoginInfo = [self.storedLogin storedLoginInfo];
    XCTAssertNotNil( storedLoginInfo );
    XCTAssertEqual( storedLoginInfo.lastLoginType, info.lastLoginType );
    XCTAssertEqualObjects( storedLoginInfo.userRemoteId, info.userRemoteId );
    XCTAssertEqualObjects( storedLoginInfo.token, info.token );
    
    XCTAssert( [self.storedLogin clearLoggedInUserFromDisk] );
    storedLoginInfo = [self.storedLogin storedLoginInfo];
    XCTAssertNil( storedLoginInfo, @"Should return nil after a call to `clearLoggedInUserFromDisk`" );
    
    XCTAssertFalse( [self.storedLogin clearLoggedInUserFromDisk], @"Shouldn't clear if already cleared." );
}

- (void)testSaveLoggedInUserInvalid
{
    VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init:@(0) withToken:kTestToken withLoginType:VLoginTypeEmail];
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:info] );
    
    VStoredLoginInfo *info2 = [[VStoredLoginInfo alloc] init:@(12345) withToken:@"" withLoginType:VLoginTypeEmail];
    XCTAssertFalse( [self.storedLogin saveLoggedInUserToDisk:info2] );
}

- (void)testLoadLastLoggedInUser
{
    VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init:@(202) withToken:kTestToken withLoginType:VLoginTypeEmail];

    [self.storedLogin saveLoggedInUserToDisk:info];
    
    [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
     {
         return NO;
     }
                     executeBlock:^
     {
         VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
         XCTAssertNotNil( storedLoginInfo  );
         XCTAssertEqual( storedLoginInfo.lastLoginType, info.lastLoginType );
         XCTAssertEqualObjects( storedLoginInfo.userRemoteId, info.userRemoteId );
         XCTAssertEqualObjects( storedLoginInfo.token, info.token );
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
    for ( NSInteger i = 0; i < 4; i++ )
    {
        VLoginType loginType = (VLoginType)[NSNumber numberWithInteger:i];
        VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init:@(202) withToken:kTestToken withLoginType:loginType];
        [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
         {
             return NO;
         }
                         executeBlock:^
         {
             [self.storedLogin saveLoggedInUserToDisk:info];
             VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
             XCTAssertNotNil( storedLoginInfo );
             XCTAssertEqual( storedLoginInfo.lastLoginType, info.lastLoginType );
             [self.storedLogin clearLoggedInUserFromDisk];
         }];
    }
    
    for ( NSInteger i = 0; i < 4; i++ )
    {
        VLoginType loginType = (VLoginType)[NSNumber numberWithInteger:i];
        VStoredLoginInfo *info = [[VStoredLoginInfo alloc] init:@(202) withToken:kTestToken withLoginType:loginType];
        [VStoredLogin v_swizzleMethod:@selector(isTokenExpirationDateExpired:) withBlock:^BOOL(NSDate *date)
         {
             return YES;
         }
                         executeBlock:^
         {
             [self.storedLogin saveLoggedInUserToDisk:info];
             VStoredLoginInfo *storedLoginInfo = [self.storedLogin storedLoginInfo];
             XCTAssertNil( storedLoginInfo );
         }];
    }
}

@end
