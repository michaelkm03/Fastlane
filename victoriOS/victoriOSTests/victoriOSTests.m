//
//  victoriOSTests.m
//  victoriOSTests
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VAPIManager.h"

@interface victoriOSTests : XCTestCase

@end

@implementation victoriOSTests

- (void)setUp
{
    [super setUp];

    [VAPIManager setupRestKit];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
