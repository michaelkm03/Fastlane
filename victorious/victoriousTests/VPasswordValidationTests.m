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

@end

@implementation VPasswordValidationTests

- (void)testvalidatePassword
{
    NSString *current = @"password";
    NSString *confirm = @"password";
    
    XCTAssert( [VPasswordValidator validatePassword:current confirmation:confirm] );
    
    XCTAssertFalse( [VPasswordValidator validatePassword:current confirmation:@"nomatch"] );
    XCTAssertFalse( [VPasswordValidator validatePassword:@"" confirmation:@""] );
    XCTAssertFalse( [VPasswordValidator validatePassword:nil confirmation:nil] );
    XCTAssertFalse( [VPasswordValidator validatePassword:@"" confirmation:nil] );
    XCTAssertFalse( [VPasswordValidator validatePassword:nil confirmation:@""] );
}

- (void)testValidatePassword
{
    NSError *error;
    
    error = nil;
    XCTAssert( [VPasswordValidator validatePassword:@"password" error:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssert( [VPasswordValidator validatePassword:@"2+d2!5=7%1-4$da_s2#57" error:&error] );
    XCTAssertNil( error );
}

- (void)testValidatePasswordInvalid
{
    NSError *error;
    
    error = nil;
    XCTAssertFalse( [VPasswordValidator validatePassword:@"2short" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (NSInteger)kVInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [VPasswordValidator validatePassword:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (NSInteger)kVInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [VPasswordValidator validatePassword:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (NSInteger)kVInvalidPasswordEntered );
}

@end
