//
//  VUserManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VUserManager.h"
#import "NSObject+VMethodSwizzling.h"

@interface VUserManager()

- (NSString *)passwordForEmail:(NSString *)email;
- (BOOL)clearSavedPassword;

@end

@interface VUserManagerTests : XCTestCase

@property (nonatomic, strong) VUserManager *userManager;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@end

@implementation VUserManagerTests

- (void)setUp
{
    [super setUp];
    
    self.userManager = [[VUserManager alloc] init];
    [self.userManager clearSavedPassword];
    
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
    XCTAssertNil( [self.userManager passwordForEmail:self.email] );
    
    // Add the password to the keychain
    XCTAssert( [self.userManager savePassword:self.password forEmail:self.email] );
    XCTAssertEqualObjects( [self.userManager passwordForEmail:self.email], self.password );
    
    // Update the password
    NSString *newPassword = @"password_2";
    XCTAssert( [self.userManager savePassword:newPassword forEmail:self.email] );
    XCTAssertEqualObjects( [self.userManager passwordForEmail:self.email], newPassword );
    
    // Delete the password
    XCTAssert( [self.userManager clearSavedPassword] );
    XCTAssertNil( [self.userManager passwordForEmail:self.email] );
}

- (void)testKeychainInvalidInput
{
    XCTAssertFalse( [self.userManager savePassword:nil forEmail:self.email] );
    XCTAssertFalse( [self.userManager savePassword:self.password forEmail:nil] );
    XCTAssertFalse( [self.userManager savePassword:nil forEmail:nil] );
    
    // Should be nothing saved with bad input
    XCTAssertNil( [self.userManager passwordForEmail:self.email] );
}

@end
