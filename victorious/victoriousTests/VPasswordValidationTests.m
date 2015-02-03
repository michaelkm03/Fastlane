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

@interface VPasswordValidator()

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message;

@end

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
    
    XCTAssert( [self.passwordValidator validateString:current withConfirmation:confirm andError:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:current withConfirmation:@"nomatch" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordsDoNotMatch );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"" withConfirmation:@"" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:nil withConfirmation:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"" withConfirmation:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:nil withConfirmation:@"" andError:&error]);
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
}

- (void)testValidatePassword
{
    NSError *error;
    
    error = nil;
    XCTAssert( [self.passwordValidator validateString:@"password" withConfirmation:nil andError:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssert( [self.passwordValidator validateString:@"2+d2!5=7%1-4$da_s2#57" withConfirmation:nil andError:&error] );
    XCTAssertNil( error );
}

- (void)testValidatePasswordInvalid
{
    NSError *error;
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"2short" withConfirmation:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:nil withConfirmation:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"" withConfirmation:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
}

- (void)testLocalizedErrorStrings
{
    NSError *error = nil;

    [self.passwordValidator validateString:@"" withConfirmation:nil andError:&error];
    XCTAssert( [error.localizedFailureReason isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordValidation", @"")] );
    
    [self.passwordValidator validateString:@"asdfasdf" withConfirmation:@"fdsafdsa" andError:&error];
    XCTAssert( [error.localizedFailureReason isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordNotMatching", @"")] );
    
    self.passwordValidator.currentPassword = @"asdfasdf";
    [self.passwordValidator validateString:@"asdfasdf" withConfirmation:@"asdfasdf" andError:&error];
    XCTAssert( [error.localizedFailureReason isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentMessage", @"")] );
}

@end
