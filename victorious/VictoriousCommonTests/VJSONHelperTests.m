//
//  VJSONHelperTests.m
//  victorious
//
//  Created by Josh Hinman on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VJSONHelper.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VJSONHelperTests : XCTestCase

@property (nonatomic, strong) VJSONHelper *jsonHelper;

@end

@implementation VJSONHelperTests

- (void)setUp
{
    [super setUp];
    self.jsonHelper = [[VJSONHelper alloc] init];
}

#pragma mark - Tests for -numberFromJSONValue:

- (void)testIntegerFromString
{
    NSString *string = @"9";
    NSNumber *expected = @(9);
    NSNumber *actual = [self.jsonHelper numberFromJSONValue:string];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testFloatFromString
{
    NSString *string = @"2.3";
    NSNumber *expected = @(2.3);
    NSNumber *actual = [self.jsonHelper numberFromJSONValue:string];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testSmallFloatFromString
{
    NSString *string = @"0.3";
    NSNumber *expected = @(0.3);
    NSNumber *actual = [self.jsonHelper numberFromJSONValue:string];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testNumberFromNumber
{
    NSNumber *expected = @(100);
    NSNumber *actual = [self.jsonHelper numberFromJSONValue:expected];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testNilFromInvalidString
{
    NSString *invalid = @"abc";
    XCTAssertNil([self.jsonHelper numberFromJSONValue:invalid]);
}

- (void)testNilFromArray
{
    NSArray *array = @[ @1, @"2", @3.3 ];
    XCTAssertNil([self.jsonHelper numberFromJSONValue:array]);
}

- (void)testNilFromDictionary
{
    NSDictionary *dict = @{ @"1": @2, @"three": @"four" };
    XCTAssertNil([self.jsonHelper numberFromJSONValue:dict]);
}

@end
