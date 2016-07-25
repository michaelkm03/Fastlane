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
@property (nonatomic, strong) NSString *username;

@end

@implementation VStoredPasswordTests

- (void)setUp
{
    [super setUp];
    
    self.storedPassword = [[VStoredPassword alloc] init];
    [self.storedPassword clearSavedPassword];
    
    self.password = @"password";
    self.username = @"some@email.com";
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testKeychain
{
    // Should be nothing saved at start of test
    XCTAssertNil( [self.storedPassword passwordForUsername:self.username] );
    
    // Add the password to the keychain
    XCTAssert( [self.storedPassword savePassword:self.password forUsername:self.username] );
    XCTAssertEqualObjects( [self.storedPassword passwordForUsername:self.username], self.password );
    
    // Update the password
    NSString *newPassword = @"password_2";
    XCTAssert( [self.storedPassword savePassword:newPassword forUsername:self.username] );
    XCTAssertEqualObjects( [self.storedPassword passwordForUsername:self.username], newPassword );
    
    // Delete the password
    XCTAssert( [self.storedPassword clearSavedPassword] );
    XCTAssertNil( [self.storedPassword passwordForUsername:self.username] );
}

- (void)testKeychainInvalidInput
{
    XCTAssertFalse( [self.storedPassword savePassword:@"" forUsername:self.username] );
    XCTAssertFalse( [self.storedPassword savePassword:self.password forUsername:@""] );
    XCTAssertFalse( [self.storedPassword savePassword:@"" forUsername:@""] );
    
    // Should be nothing saved with bad input
    XCTAssertNil( [self.storedPassword passwordForUsername:self.username] );
}

@end
