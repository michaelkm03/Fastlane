//
//  VElapsedTimeFormatterTests.m
//  victorious
//
//  Created by Josh Hinman on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VElapsedTimeFormatter.h"

@interface VElapsedTimeFormatterTests : XCTestCase

@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;

@end

@implementation VElapsedTimeFormatterTests

- (void)setUp
{
    [super setUp];
    self.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
}

- (void)testSeconds
{
    CMTime seconds = CMTimeMakeWithSeconds(3.0, NSEC_PER_SEC);
    NSString *desired = @"0:03";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:seconds];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testTensOfSeconds
{
    CMTime seconds = CMTimeMakeWithSeconds(30.0, NSEC_PER_SEC);
    NSString *desired = @"0:30";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:seconds];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testOneMinute
{
    CMTime minute = CMTimeMakeWithSeconds(60.0, NSEC_PER_SEC);
    NSString *desired = @"1:00";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:minute];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testTensOfMinutes
{
    CMTime minutes = CMTimeMakeWithSeconds(780.0, NSEC_PER_SEC);
    NSString *desired = @"13:00";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:minutes];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testMinuteAndSeconds
{
    CMTime time = CMTimeMakeWithSeconds(90.0, NSEC_PER_SEC);
    NSString *desired = @"1:30";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:time];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testHour
{
    CMTime hour = CMTimeMakeWithSeconds(3600.0, NSEC_PER_SEC);
    NSString *desired = @"1:00:00";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:hour];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testHourAndSeconds
{
    CMTime hour = CMTimeMakeWithSeconds(3602.0, NSEC_PER_SEC);
    NSString *desired = @"1:00:02";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:hour];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testHourMinutesSeconds
{
    CMTime hour = CMTimeMakeWithSeconds(3721.0, NSEC_PER_SEC);
    NSString *desired = @"1:02:01";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:hour];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testHourTensOfMinutesSeconds
{
    CMTime hour = CMTimeMakeWithSeconds(4801.0, NSEC_PER_SEC);
    NSString *desired = @"1:20:01";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:hour];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testTensOfHours
{
    CMTime day = CMTimeMakeWithSeconds(86400.0, NSEC_PER_SEC);
    NSString *desired = @"24:00:00";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:day];
    XCTAssertEqualObjects(desired, actual);
}

- (void)testInvalid
{
    NSString *desired = @"-:--";
    NSString *actual = [self.elapsedTimeFormatter stringForCMTime:kCMTimeInvalid];
    XCTAssertEqualObjects(desired, actual);
}

@end
