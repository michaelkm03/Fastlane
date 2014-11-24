//
//  VAlertControllerAdvancedTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VAlertController.h"
#import "VAlertControllerAdvanced.h"

@interface VAlertControllerAdvanced (UnitTest)

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;
- (UIAlertControllerStyle)systemStyleFromStyle:(VAlertControllerStyle)style;
- (UIAlertActionStyle)systemActionStyleFromActionStyle:(VAlertActionStyle)style;
- (UIAlertAction *)systemActionFromAction:(VAlertAction *)action;

@property (nonatomic, strong) NSMutableArray *actions;

@end

@interface VAlertControllerAdvancedTests : XCTestCase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end

@implementation VAlertControllerAdvancedTests

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

- (void)testStyleConversion
{
    VAlertControllerAdvanced *alertController = [[VAlertControllerAdvanced alloc] init];
    XCTAssertEqual( [alertController systemStyleFromStyle:VAlertControllerStyleActionSheet], UIAlertControllerStyleActionSheet );
    XCTAssertEqual( [alertController systemStyleFromStyle:VAlertControllerStyleAlert], UIAlertControllerStyleAlert );
}

- (void)testActionStylecConverstion
{
    VAlertControllerAdvanced *alertController = [[VAlertControllerAdvanced alloc] init];
    XCTAssertEqual( [alertController systemActionStyleFromActionStyle:VAlertActionStyleDefault], UIAlertActionStyleDefault );
    XCTAssertEqual( [alertController systemActionStyleFromActionStyle:VAlertActionStyleDestructive], UIAlertActionStyleDestructive );
    XCTAssertEqual( [alertController systemActionStyleFromActionStyle:VAlertActionStyleCancel], UIAlertActionStyleCancel );
}

- (void)testsystemActionFromAction1
{
    VAlertControllerAdvanced *alertController = [[VAlertControllerAdvanced alloc] init];
    VAlertAction *myAlertAction = [[VAlertAction alloc] initWithTitle:self.title style:VAlertActionStyleCancel handler:^(VAlertAction *action) {}];
    UIAlertAction *systemAlertAction = [alertController systemActionFromAction:myAlertAction];
    XCTAssertEqualObjects( myAlertAction.title, systemAlertAction.title );
    XCTAssertEqual( myAlertAction.enabled, systemAlertAction.enabled );
    XCTAssertNotNil( myAlertAction.handler );
    XCTAssertEqual( [alertController systemActionStyleFromActionStyle:myAlertAction.style], systemAlertAction.style );
}

- (void)testsystemActionFromAction2
{
    VAlertControllerAdvanced *alertController = [[VAlertControllerAdvanced alloc] init];
    VAlertAction *myAlertAction = [[VAlertAction alloc] initWithTitle:self.title style:VAlertActionStyleDestructive handler:nil];
    myAlertAction.enabled = NO;
    UIAlertAction *systemAlertAction = [alertController systemActionFromAction:myAlertAction];
    XCTAssertEqualObjects( myAlertAction.title, systemAlertAction.title );
    XCTAssertEqual( myAlertAction.enabled, systemAlertAction.enabled );
    XCTAssertNil( myAlertAction.handler );
    XCTAssertEqual( [alertController systemActionStyleFromActionStyle:myAlertAction.style], systemAlertAction.style );
}

- (void)testActions
{
    VAlertControllerAdvanced *alertController = [[VAlertControllerAdvanced alloc] init];
    XCTAssertNil( alertController.actions );
    
    NSArray *actions = [self createActions];
    for ( VAlertAction *action in actions )
    {
        [alertController addAction:action];
    }
    XCTAssertEqual( actions.count, alertController.actions.count );
    
    [alertController removeAllActions];
    XCTAssertEqual( (NSUInteger)0, alertController.actions.count );
}

#pragma mark - Helpers

- (NSArray *)createActions
{
    return @[ [[VAlertAction alloc] initWithTitle:@"cancelAction" style:VAlertActionStyleCancel handler:nil],
              [[VAlertAction alloc] initWithTitle:@"destructiveAction" style:VAlertActionStyleDestructive handler:nil],
              [[VAlertAction alloc] initWithTitle:@"dfeaultAction" style:VAlertActionStyleDefault handler:nil]
              ];
}

@end
