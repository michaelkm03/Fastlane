//
//  VPasswordValidationTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VChangePasswordViewController.h"

@interface VChangePasswordViewController (UnitTest)

- (BOOL)shouldUpdatePassword:(NSString *)password confirmation:(NSString *)confirmationPassword;

- (BOOL)validatePassword:(NSString *)password error:(NSError **)outError;

@end

@interface VPasswordValidationTests : XCTestCase
{
    VChangePasswordViewController *_viewController;
}

@end

@implementation VPasswordValidationTests

- (void)setUp
{
    [super setUp];
    
    _viewController = [[VChangePasswordViewController alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldUpdatePassword
{
    NSString *current = @"password";
    NSString *confirm = @"password";
    XCTAssert( [_viewController shouldUpdatePassword:current confirmation:confirm] );
    
    XCTAssertFalse( [_viewController shouldUpdatePassword:current confirmation:@"nomatch"] );
    XCTAssertFalse( [_viewController shouldUpdatePassword:@"" confirmation:@""] );
    XCTAssertFalse( [_viewController shouldUpdatePassword:nil confirmation:nil] );
    XCTAssertFalse( [_viewController shouldUpdatePassword:@"" confirmation:nil] );
    XCTAssertFalse( [_viewController shouldUpdatePassword:nil confirmation:@""] );
}

- (void)testValidatePassword
{
    NSError *error;
    
    error = nil;
    XCTAssert( [_viewController validatePassword:@"password" error:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssert( [_viewController validatePassword:@"2+d2!5=7%1-4$da_s2#57" error:&error] );
    XCTAssertNil( error );
}


- (void)testValidatePasswordInvalid
{
    NSError *error;
    
    error = nil;
    XCTAssertFalse( [_viewController validatePassword:@"2short" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (int)VAccountUpdateViewControllerBadPasswordErrorCode );
    
    error = nil;
    XCTAssertFalse( [_viewController validatePassword:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (int)VAccountUpdateViewControllerBadPasswordErrorCode );
    
    error = nil;
    XCTAssertFalse( [_viewController validatePassword:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, (int)VAccountUpdateViewControllerBadPasswordErrorCode );
}

@end
