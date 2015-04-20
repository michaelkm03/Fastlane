//
//  VVCreationInfoContainerTests.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VCreationInfoContainer.h"

@interface VVCreationInfoContainerTests : XCTestCase

@property (nonatomic, strong) VCreationInfoContainer *containerView;

@end

@implementation VVCreationInfoContainerTests

- (void)setUp
{
    [super setUp];
    
    self.containerView = [[VCreationInfoContainer alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.containerView layoutIfNeeded];
    [self.containerView updateConstraintsIfNeeded];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
