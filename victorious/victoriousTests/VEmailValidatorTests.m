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
    
    XCTAssert( [self.emailValidator validateString:emailAddress andError:&error] );
    XCTAssertNil( error );
}

- (void)testValidateFail
{
    NSError *error = nil;
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:nil andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"adsp9u8had3" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"dsadsa@dsadsa" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"dsadsa2.com" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"@dsadas.com" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"@.com" andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
    
    error = nil;
    XCTAssertFalse( [self.emailValidator validateString:@"dsadsa@dsa." andError:&error] );
    XCTAssertNotNil( error );
    XCTAssertEqual( error.code, VSignupErrorCodeInvalidEmailAddress );
}

- (void)testLocalizedErrorStrings
{
    NSError *error = nil;

    [self.emailValidator validateString:@"" andError:&error];
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"EmailValidation", @"")] );

    [self.emailValidator validateString:@".com" andError:&error];
    XCTAssert( [error.localizedDescription isEqualToString:NSLocalizedString( @"EmailValidation", @"")] );
}

@end
