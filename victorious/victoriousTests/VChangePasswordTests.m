//
//  VChangePasswordTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VChangePasswordViewController.h"
#import "VConstants.h"

@interface VChangePasswordViewController()

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message;

@end

@interface VChangePasswordTests : XCTestCase
{
    VChangePasswordViewController *_viewController;
}

@end

@implementation VChangePasswordTests

- (void)setUp
{
    [super setUp];
    
    _viewController = [[VChangePasswordViewController alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testGenericError
{
    NSString *title = nil;
    NSString *message = nil;
    NSError *error = nil;
    
    error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    XCTAssert( [_viewController localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString(@"ResetPasswordErrorFailTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString(@"ResetPasswordErrorFailMessage", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:kVCurrentPasswordIsInvalid userInfo:nil];
    XCTAssert( [_viewController localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString(@"ResetPasswordErrorIncorrectTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString(@"ResetPasswordErrorIncorrectMessage", @"")] );
    
    title = nil;
    message = nil;
    error = [NSError errorWithDomain:@"" code:kVPasswordResetCodeExpired userInfo:nil];
    XCTAssert( [_viewController localizedErrorStringsForError:error title:&title message:&message] );
    XCTAssert( [title isEqualToString:NSLocalizedString(@"ResetPasswordErrorFailTitle", @"")] );
    XCTAssert( [message isEqualToString:NSLocalizedString(@"ResetPasswordErrorFailMessage", @"")] );
}

@end
