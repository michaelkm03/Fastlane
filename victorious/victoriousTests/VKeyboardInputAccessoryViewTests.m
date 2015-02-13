//
//  VKeyboardInputAccessoryViewTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VKeyboardInputAccessoryView.h"

@interface VKeyboardInputAccessoryViewTests : XCTestCase

@end

@implementation VKeyboardInputAccessoryViewTests

- (void)testInit
{
    XCTAssertNotNil([VKeyboardInputAccessoryView defaultInputAccessoryView], @"should return a valid keyboardInputAccessoryView for nil dependency manager");
}

@end
