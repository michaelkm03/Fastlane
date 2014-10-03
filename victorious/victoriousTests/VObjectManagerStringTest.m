//
//  VObjectManagerStringTest.m
//  victorious
//
//  Created by Josh Hinman on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Private.h"

#import <XCTest/XCTest.h>

/**
 Tests for the -stringFromObject: method of VObjectManager
 */
@interface VObjectManagerStringTest : XCTestCase

@property (nonatomic, strong) VObjectManager *objectManager;

@end

@implementation VObjectManagerStringTest

- (void)setUp
{
    [super setUp];
    self.objectManager = [[VObjectManager alloc] init];
}

- (void)testStringInput
{
    NSString *input = @"myString";
    NSString *output = [self.objectManager stringFromObject:input];
    XCTAssertEqualObjects(input, output);
}

- (void)testNumberInput
{
    NSNumber *input = @(42);
    NSString *output = [self.objectManager stringFromObject:input];
    XCTAssertEqualObjects(output, [input stringValue]);
}

- (void)testObjectInput
{
    NSObject *input = [[NSObject alloc] init];
    NSString *output = [self.objectManager stringFromObject:input];
    XCTAssertEqualObjects(output, [input description]);
}

@end
