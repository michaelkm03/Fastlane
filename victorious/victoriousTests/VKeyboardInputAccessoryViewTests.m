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
    XCTAssertNoThrow([VKeyboardInputAccessoryView defaultInputAccessoryViewWithDependencyManager:nil], @"should not throw excpetion for nil dependency manager");
    XCTAssertNotNil([VKeyboardInputAccessoryView defaultInputAccessoryViewWithDependencyManager:nil], @"should return a valid keyboardInputAccessoryView for nil dependency manager");
}

@end
