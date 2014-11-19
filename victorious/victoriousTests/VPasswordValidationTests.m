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

- (void)testLocalizedErrorStrings
{
    NSString *title = nil;
    NSString *message = nil;
    NSError *error = nil;
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VErrorCodeInvalidPasswordEntered userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"PasswordValidation", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VErrorCodeInvalidPasswordsDoNotMatch userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"PasswordNotMatching", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VErrorCodeCurrentPasswordIsIncorrect userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"ResetPasswordErrorIncorrectTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"ResetPasswordErrorMessage", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VErrorCodeCurrentPasswordIsInvalid userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"ResetPasswordErrorInvalidTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"ResetPasswordErrorMessage", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VErrorCodeInvalidPasswordsNewEqualsCurrent userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentMessage", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
    XCTAssert( [self.passwordValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"ResetPasswordErrorFailTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString( @"ResetPasswordErrorFailMessage", @"")] );
}

@end
