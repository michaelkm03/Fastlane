//
//  VEmailValidatorTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VEmailValidator.h"

@interface VEmailValidator()

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message;

@end

@interface VEmailValidatorTests : XCTestCase

@property (nonatomic, strong) VEmailValidator *emailValidator;

@end

@implementation VEmailValidatorTests

- (void)setUp
{
    [super setUp];
    
    self.emailValidator = [[VEmailValidator alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testValidatePass
{
    NSString *emailAddress = @"patrick@getvictorious.com";
    NSError *error = nil;
    
    XCTAssert( [self.emailValidator validateEmailAddress:emailAddress error:&error] );
    XCTAssertNil( error );
}

- (void)testValidateFail
{
    NSError *error = nil;
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"adsp9u8had3" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"dsadsa@dsadsa" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"dsadsa2.com" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"@dsadas.com" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"@.com" error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateEmailAddress:@"dsadsa@dsa." error:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
}

- (void)testLocalizedErrorStrings
{
    NSString *title = nil;
    NSString *message = nil;
    NSError *error = nil;
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:VSignupErrorCodeInvalidEmailAddress userInfo:nil];
    XCTAssert( [self.emailValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"EmailValidation", @"")] );
    XCTAssertNil( message );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
    XCTAssert( [self.emailValidator localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString( @"EmailValidation", @"")] );
    XCTAssertNil( message );
}

@end
