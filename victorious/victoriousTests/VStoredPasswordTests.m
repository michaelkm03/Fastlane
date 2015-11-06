//
//  VStoredPasswordTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSObject+VMethodSwizzling.h"
#import "VStoredPassword.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VStoredPasswordTests : XCTestCase

@property (nonatomic, strong) VStoredPassword *storedPassword;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@end

@implementation VStoredPasswordTests

- (void)setUp
{
    [super setUp];
    
    self.storedPassword = [[VStoredPassword alloc] init];
    [self.storedPassword clearSavedPassword];
    
    self.password = @"password";
    self.email = @"some@email.com";
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testKeychain
{
    // Should be nothing saved at start of test
    XCTAssertNil( [self.storedPassword passwordForEmail:self.email] );
    
    // Add the password to the keychain
    XCTAssert( [self.storedPassword savePassword:self.password forEmail:self.email] );
    XCTAssertEqualObjects( [self.storedPassword passwordForEmail:self.email], self.password );
    
    // Update the password
    NSString *newPassword = @"password_2";
    XCTAssert( [self.storedPassword savePassword:newPassword forEmail:self.email] );
    XCTAssertEqualObjects( [self.storedPassword passwordForEmail:self.email], newPassword );
    
    // Delete the password
    XCTAssert( [self.storedPassword clearSavedPassword] );
    XCTAssertNil( [self.storedPassword passwordForEmail:self.email] );
}

- (void)testKeychainInvalidInput
{
    XCTAssertFalse( [self.storedPassword savePassword:nil forEmail:self.email] );
    XCTAssertFalse( [self.storedPassword savePassword:self.password forEmail:nil] );
    XCTAssertFalse( [self.storedPassword savePassword:nil forEmail:nil] );
    
    // Should be nothing saved with bad input
    XCTAssertNil( [self.storedPassword passwordForEmail:self.email] );
}

@end
