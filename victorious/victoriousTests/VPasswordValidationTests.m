//
//  VPasswordValidationTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VConstants.h"
#import "VPasswordValidator.h"

@interface VPasswordValidationTests : XCTestCase

@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VPasswordValidationTests

- (void)setUp
{
    [super setUp];
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
}

- (void)testvalidatePassword
{
    NSString *current = @"password";
    NSString *confirm = @"password";
    NSError *error = nil;
    
    XCTAssert( [self.passwordValidator validatePassword:current withConfirmation:confirm error:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:current withConfirmation:@"nomatch" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordsDoNotMatch );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:@"" withConfirmation:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:nil withConfirmation:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:@"" withConfirmation:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:nil withConfirmation:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
}

- (void)testValidatePassword
{
    NSError *error;
    
    error = nil;
    XCTAssert( [self.passwordValidator validatePassword:@"password" error:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssert( [self.passwordValidator validatePassword:@"2+d2!5=7%1-4$da_s2#57" error:&error] );
    XCTAssertNil( error );
}

- (void)testValidatePasswordInvalid
{
    NSError *error;
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:@"2short" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validatePassword:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
}

@end
