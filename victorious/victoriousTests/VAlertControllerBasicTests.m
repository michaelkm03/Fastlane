//
//  VAlertControllerBasicTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VAlertController.h"
#import "VAlertControllerBasic.h"
#import "NSObject+VMethodSwizzling.h"

@interface VAlertController (UnitTest)

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(VAlertControllerStyle)style;

@end

@interface VAlertControllerBasic (UnitTest)

@property (nonatomic, strong) VAlertAction *cancelAction;
@property (nonatomic, strong) VAlertAction *destructiveAction;
@property (nonatomic, strong) NSMutableArray *defaultActions;
@property (nonatomic, readonly) UIAlertView *alertView;
@property (nonatomic, readonly) UIActionSheet *actionSheet;

@end

@interface VAlertControllerBasicTests : XCTestCase

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end

@implementation VAlertControllerBasicTests

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

- (void)testPresentation
{
    __block BOOL blockWasCalled = NO;
    __block BOOL showWasCalled = NO;
    VAlertControllerBasic *alertController = nil;
    UIViewController *parentVC = [[UIViewController alloc] init];
    
    alertController = [[VAlertControllerBasic alloc] initWithTitle:self.title
                                                           message:self.message
                                                             style:VAlertControllerStyleAlert];
    [alertController addAction:[[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleCancel handler:nil]];
    showWasCalled = NO;
    [UIAlertView v_swizzleMethod:@selector(show) withBlock:^void (UIAlertView *alertView)
     {
         showWasCalled = YES;
     }
                    executeBlock:^
     {
         [alertController presentInViewController:parentVC animated:YES completion:nil];
         XCTAssert( showWasCalled );
         blockWasCalled = YES;
     }];
    XCTAssert( blockWasCalled );
    
    alertController = [[VAlertControllerBasic alloc] initWithTitle:self.title
                                                           message:self.message
                                                             style:VAlertControllerStyleActionSheet];
    [alertController addAction:[[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleCancel handler:nil]];
    showWasCalled = NO;
    [UIActionSheet v_swizzleMethod:@selector(showInView:) withBlock:^void (UIActionSheet *actionSheet, UIView *view)
     {
         XCTAssertEqualObjects( view, parentVC.view );
         showWasCalled = YES;
     }
                      executeBlock:^
     {
         [alertController presentInViewController:parentVC animated:YES completion:nil];
         XCTAssert( showWasCalled );
         blockWasCalled = YES;
     }];
    XCTAssert( blockWasCalled );
}

- (void)testActions
{
    VAlertControllerBasic *alertController = [[VAlertControllerBasic alloc] initWithTitle:self.title
                                                                                  message:self.message
                                                                                    style:VAlertControllerStyleAlert];
    VAlertAction *cancelAction = [[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    XCTAssertEqualObjects( cancelAction, alertController.cancelAction );
    VAlertAction *destructiveAction = [[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleDestructive handler:nil];
    [alertController addAction:destructiveAction];
    XCTAssertEqualObjects( destructiveAction, alertController.destructiveAction );
    NSUInteger defaultActionsCount = 2;
    for ( NSUInteger i = 0; i < defaultActionsCount; i++ )
    {
        VAlertAction *defaultAction = [[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleDefault handler:nil];
        [alertController addAction:defaultAction];
    }
    XCTAssertEqual( defaultActionsCount, alertController.defaultActions.count );
    [alertController removeAllActions];
    XCTAssertEqual( (NSUInteger)0, alertController.defaultActions.count );
    XCTAssertNil( alertController.destructiveAction );
    XCTAssertNil( alertController.cancelAction );
}

- (void)testAlert
{
    VAlertControllerBasic *alertController = [[VAlertControllerBasic alloc] initWithTitle:self.title
                                                                                  message:self.message
                                                                                    style:VAlertControllerStyleAlert];
    XCTAssertThrows( alertController.alertView, @"Should throw NSParameterAssert if no actions have been added yet." );
    [alertController addAction:[[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleCancel handler:nil]];
    XCTAssertNotNil( alertController.alertView );
    XCTAssertThrows( alertController.actionSheet );
}

- (void)testActionSheet
{
    VAlertControllerBasic *alertController = [[VAlertControllerBasic alloc] initWithTitle:self.title
                                                                                  message:self.message
                                                                                    style:VAlertControllerStyleActionSheet];
    XCTAssertThrows( alertController.actionSheet, @"Should throw NSParameterAssert if no actions have been added yet." );
    [alertController addAction:[[VAlertAction alloc] initWithTitle:@"title" style:VAlertActionStyleCancel handler:nil]];
    XCTAssertThrows( alertController.alertView );
    XCTAssertNotNil( alertController.actionSheet );
}

@end
