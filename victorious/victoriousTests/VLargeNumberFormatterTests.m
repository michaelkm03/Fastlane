//
//  VLargeNumberFormatterTests.m
//  victorious
//
//  Created by Josh Hinman on 6/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLargeNumberFormatter.h"

#import <XCTest/XCTest.h>

@interface VLargeNumberFormatterTests : XCTestCase

@property (nonatomic, strong) VLargeNumberFormatter *formatter;

@end

@implementation VLargeNumberFormatterTests

- (void)setUp
{
    [super setUp];
    self.formatter = [[VLargeNumberFormatter alloc] init];
}

- (void)testSmallNumber
{
    NSInteger number = 5;
    NSString *desired = @"5";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testHundreds
{
    NSInteger number = 999;
    NSString *desired = @"999";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testThousand
{
    NSInteger number = 1000;
    NSString *desired = @"1K";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testThousands
{
    NSInteger number = 5658;
    NSString *desired = @"5K";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testAlmostMillion
{
    NSInteger number = 999999;
    NSString *desired = @"999K";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testMillion
{
    NSInteger number = 1000000;
    NSString *desired = @"1M";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testMillions
{
    NSInteger number = 6525845;
    NSString *desired = @"6M";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testAlmostBillion
{
    NSInteger number = 999999999;
    NSString *desired = @"999M";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testBillion
{
    NSInteger number = 1000000000;
    NSString *desired = @"1B";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testBillions
{
    NSInteger number = 2056845232;
    NSString *desired = @"2B";
    NSString *actual = [self.formatter stringForInteger:number];
    XCTAssertEqualObjects(desired, actual);
}

@end
