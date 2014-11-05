//
//  NSDate+timeSinceTests.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NSDate+timeSince.h"

@interface NSDate_timeSinceTests : XCTestCase

@end

@implementation NSDate_timeSinceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testYearsAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 365 * 3.1);//3.1 years ago - extra bit for the delay between calls
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [yearsAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"YearsAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed years ago");
}

- (void)testYearAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 365);//1 year ago
    
    // Create the NSDates
    NSDate *yearAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [yearAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastYear", @"")], @"Failed last year");
}

- (void)testMonthsAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 31 * 3);//3 months ago
    
    // Create the NSDates
    NSDate *monthsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [monthsAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"MonthsAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed months ago");
}

- (void)testMonthAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 31);//1 month ago
    
    // Create the NSDates
    NSDate *monthAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [monthAgo timeSince];
    //XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastMonth", @"")], @"Failed last month");
    XCTAssertEqualObjects( timeSince, NSLocalizedString(@"LastMonth", @""), @"Failed last month");
}

- (void)testWeeksAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 7 * 3);//3 months ago
    
    // Create the NSDates
    NSDate *weeksAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [weeksAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"WeeksAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Weeks ago");
}

- (void)testWeekAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 7);//1 Week ago
    
    // Create the NSDates
    NSDate *weekAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [weekAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastWeek", @"")], @"Failed last Week");
}

- (void)testDaysAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 3);//3 Day ago
    
    // Create the NSDates
    NSDate *daysAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [daysAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"DaysAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed days ago");
}

- (void)testDayAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24);//1 Day ago
    
    // Create the NSDates
    NSDate *dayAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [dayAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Yesterday", @"")], @"Failed Yesterday");
}

- (void)testHoursAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 3);//3 Hour ago
    
    // Create the NSDates
    NSDate *hoursAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [hoursAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"HoursAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Hours ago");
}

- (void)testHourAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60);//1 Hour ago
    
    // Create the NSDates
    NSDate *hourAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [hourAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"HourAgo", @"")], @"Failed HourAgo");
}


- (void)testMinutesAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 3);//3 Minute ago
    
    // Create the NSDates
    NSDate *minutesAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [minutesAgo timeSince];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"MinutesAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Minutes ago");
}

- (void)testMinuteAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60);//1 Minute ago
    
    // Create the NSDates
    NSDate *minuteAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [minuteAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"MinuteAgo", @"")], @"Failed HourAgo");
}

- (void)testNow
{
    // The time interval
    NSTimeInterval theTimeInterval = -(10);
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [yearsAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Now", @"")], @"Failed Now");
}

- (void)testZero
{
    // The time interval
    NSTimeInterval theTimeInterval = (0);
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:[NSDate date]];
    NSString *timeSince = [yearsAgo timeSince];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Now", @"")], @"Failed Now");
}

@end
