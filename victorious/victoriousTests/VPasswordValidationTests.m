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

@property (nonatomic, strong) UITextField *confirmField;
@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VPasswordValidationTests

- (void)setUp
{
    [super setUp];
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
    self.confirmField = [[UITextField alloc] init];
    [self.passwordValidator setConfirmationObject:self.confirmField
                                      withKeyPath:NSStringFromSelector(@selector(text))];
}

- (void)testvalidatePassword
{
    NSString *current = @"password";
    NSString *confirm = @"password";
    NSError *error = nil;
    
    self.confirmField.text = confirm;
    XCTAssert( [self.passwordValidator validateString:current andError:&error] );
    XCTAssertNil( error );
    
    error = nil;
    self.confirmField.text = @"nomatch";
    XCTAssertFalse( [self.passwordValidator validateString:current andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordsDoNotMatch );
    
    error = nil;
    self.confirmField.text = @"";
    XCTAssertFalse( [self.passwordValidator validateString:@"" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    self.confirmField.text = nil;
    XCTAssertFalse( [self.passwordValidator validateString:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    self.confirmField.text = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    self.confirmField.text = @"";
    XCTAssertFalse( [self.passwordValidator validateString:nil andError:&error]);
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
}

- (void)testValidatePassword
{
    NSError *error;
    
    error = nil;
    [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    XCTAssert( [self.passwordValidator validateString:@"password" andError:&error] );
    XCTAssertNil( error );
    
    error = nil;
        [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    XCTAssert( [self.passwordValidator validateString:@"2+d2!5=7%1-4$da_s2#57" andError:&error] );
    XCTAssertNil( error );
}

- (void)testValidatePasswordInvalid
{
    NSError *error;
    
    error = nil;
    [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    XCTAssertFalse( [self.passwordValidator validateString:@"2short" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
    
    error = nil;
    XCTAssertFalse( [self.passwordValidator validateString:@"" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    XCTAssertEqual( error.code, VErrorCodeInvalidPasswordEntered );
}

- (void)testLocalizedErrorStrings
{
    NSError *error = nil;
    
    self.confirmField.text = @"fdsafdsa";
    [self.passwordValidator validateString:@"asdfasdf" andError:&error];
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordNotMatching", @"")] );
    
    self.passwordValidator.currentPassword = @"asdfasdf";
    self.confirmField.text = @"asdfasdf";
    [self.passwordValidator validateString:@"asdfasdf" andError:&error];
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentTitle", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"ResetPasswordNewEqualsCurrentMessage", @"")] );
    
    [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    [self.passwordValidator validateString:@"" andError:&error];
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordError", @"")] );
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"PasswordValidation", @"")] );
}

@end
