//
//  VAlertControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VAlertController.h"
#import "VAlertControllerAdvanced.h"
#import "VAlertControllerBasic.h"

@interface VAlertController (UnitTests)

+ (VAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;

@end

@interface VAlertControllerTests : XCTestCase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end

@implementation VAlertControllerTests

- (void)setUp
{
    [super setUp];
    
    self.title = @"generic title";
    self.message = @"generic message";
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCreationAdvanced
{
    __block VAlertController *alertController = nil;
    __block BOOL blockWasCalled = NO;
    [VAlertController v_swizzleClassMethod:@selector(canUseAlertController) withBlock:^BOOL
     {
         return YES;
     }
                              executeBlock:^
     {
         alertController = [VAlertController alertControllerWithTitle:self.title
                                                              message:self.message
                                                                style:VAlertControllerStyleActionSheet];
         XCTAssertNotNil( alertController );
         XCTAssert( [alertController isMemberOfClass:[VAlertControllerAdvanced class]] );
         XCTAssert( [alertController isKindOfClass:[VAlertController class]] );
         blockWasCalled = YES;
     }];
    XCTAssert( blockWasCalled );
}

- (void)testCreationBasic
{
    __block VAlertController *alertController = nil;
    __block BOOL blockWasCalled = NO;
    [VAlertController v_swizzleClassMethod:@selector(canUseAlertController) withBlock:^BOOL
     {
         return NO;
     }
                              executeBlock:^
     {
         alertController = [VAlertController alertControllerWithTitle:self.title
                                                              message:self.message
                                                                style:VAlertControllerStyleActionSheet];
         XCTAssertNotNil( alertController );
         XCTAssert( [alertController isMemberOfClass:[VAlertControllerBasic class]] );
         XCTAssert( [alertController isKindOfClass:[VAlertController class]] );
         blockWasCalled = YES;
     }];
    XCTAssert( blockWasCalled );
}

- (void)testInit
{
    VAlertController *alertController = nil;
    
    alertController = [VAlertController alertWithTitle:self.title message:self.message];
    XCTAssertEqualObjects( self.title, alertController.title );
    XCTAssertEqualObjects( self.message, alertController.message );
    XCTAssertEqual( VAlertControllerStyleAlert, alertController.style );
    
    alertController = [VAlertController actionSheetWithTitle:self.title message:self.message];
    XCTAssertEqualObjects( self.title, alertController.title );
    XCTAssertEqualObjects( self.message, alertController.message );
    XCTAssertEqual( VAlertControllerStyleActionSheet, alertController.style );
}

- (void)testActionInitializers
{
    NSString *actionTitle = @"actionTitle";
    VAlertAction *actionDefault = [VAlertAction buttonWithTitle:actionTitle handler:^(VAlertAction *action) {}];
    XCTAssertEqual( actionDefault.style, VAlertActionStyleDefault );
    XCTAssertNotNil( actionDefault.handler );
    XCTAssertEqualObjects( actionTitle, actionDefault.title );
    
    NSString *cancelTitle = @"cancelTitle";
    VAlertAction *actionCancel = [VAlertAction cancelButtonWithTitle:cancelTitle handler:^(VAlertAction *action) {}];
    XCTAssertEqual( actionCancel.style, VAlertActionStyleCancel );
    XCTAssertNotNil( actionCancel.handler );
    XCTAssertEqualObjects( cancelTitle, actionCancel.title );
    
    NSString *destructiveTitle = @"destructiveTitle";
    VAlertAction *actionDestructive = [VAlertAction destructiveButtonWithTitle:destructiveTitle handler:^(VAlertAction *action) {}];
    XCTAssertEqual( actionDestructive.style, VAlertActionStyleDestructive );
    XCTAssertNotNil( actionDestructive.handler );
    XCTAssertEqualObjects( destructiveTitle, actionDestructive.title );
}

@end
