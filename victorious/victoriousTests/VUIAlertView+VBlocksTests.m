//
//  VUIAlertView+VBlocksTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "VAsyncTestHelper.h"
#import "UIAlertView+VBlocks.h"

@interface VUIAlertView_VBlocksTests : XCTestCase
{
    NSTimeInterval _asyncWaitTime;
    VAsyncTestHelper *_asyncHelper;
    
    NSString *_button1Text;
    NSString *_button2Text;
    NSString *_titleText;
    NSString *_messageText;
    NSString *_cancelButtonText;
}

@end

@implementation VUIAlertView_VBlocksTests

- (void)setUp
{
    [super setUp];
    
    _button1Text = @"button1";
    _button2Text = @"button2";
    _titleText = @"title";
    _messageText = @"button";
    _cancelButtonText = @"cancel";
    
    _asyncWaitTime = 5.0f;
    _asyncHelper = [[VAsyncTestHelper alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitializationWithArray
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_titleText message:_messageText cancelButtonTitle:_cancelButtonText onCancelButton:nil otherButtonTitlesAndBlocks:_button1Text, ^{}, _button2Text, ^{}, nil];
    
    XCTAssert( [[alertView buttonTitleAtIndex:1] isEqualToString:_button1Text] );
    XCTAssert( [[alertView buttonTitleAtIndex:2] isEqualToString:_button2Text] );
    XCTAssert( [[alertView buttonTitleAtIndex:alertView.cancelButtonIndex] isEqualToString:_cancelButtonText] );
}

- (void)testInitializationIndividualMethods
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_titleText message:_messageText cancelButtonTitle:_cancelButtonText onCancelButton:nil otherButtonTitlesAndBlocks:nil];
    
    [alertView addButtonWithTitle:_button1Text block:^{}];
    [alertView addButtonWithTitle:_button2Text block:^{}];
    
    XCTAssert( [[alertView buttonTitleAtIndex:1] isEqualToString:_button1Text] );
    XCTAssert( [[alertView buttonTitleAtIndex:2] isEqualToString:_button2Text] );
    XCTAssert( [[alertView buttonTitleAtIndex:alertView.cancelButtonIndex] isEqualToString:_cancelButtonText] );
}

- (void)testCancelSelected
{
    __block BOOL wasBlockCalled = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_titleText message:_messageText cancelButtonTitle:_cancelButtonText onCancelButton:^{
        wasBlockCalled = YES;
    }otherButtonTitlesAndBlocks:nil];
    
    [alertView show];
    [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
    
    [_asyncHelper waitForSignal:_asyncWaitTime withSignalBlock:^BOOL{
        return wasBlockCalled;
    }];
    
    XCTAssert( wasBlockCalled );
}

- (void)testButtonsSelected
{
    __block BOOL wasBlock1Called = NO;
    __block BOOL wasBlock2Called = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_titleText message:_messageText cancelButtonTitle:_cancelButtonText onCancelButton:nil otherButtonTitlesAndBlocks:nil];
    
    [alertView addButtonWithTitle:_button1Text block:^{
        wasBlock1Called = YES;
    }];
    
    [alertView addButtonWithTitle:_button2Text block:^{
        wasBlock2Called = YES;
    }];
    
    [alertView show];
    [alertView dismissWithClickedButtonIndex:1 animated:NO];
    
    [_asyncHelper waitForSignal:_asyncWaitTime withSignalBlock:^BOOL{
        return wasBlock1Called;
    }];
    
    [alertView show];
    [alertView dismissWithClickedButtonIndex:2 animated:NO];
    
    [_asyncHelper waitForSignal:_asyncWaitTime withSignalBlock:^BOOL{
        return wasBlock2Called;
    }];
    
    XCTAssert( wasBlock1Called );
    XCTAssert( wasBlock2Called );
}

@end
