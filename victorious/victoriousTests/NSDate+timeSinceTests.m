//
//  NSDate+timeSinceTests.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "victorious-Swift.h"

@interface NSDate_timeSinceTests : XCTestCase

@property (nonatomic, strong) NSDate *referenceDate;

@end

@implementation NSDate_timeSinceTests

- (void)setUp
{
    [super setUp];
    self.referenceDate = [NSDate dateWithTimeIntervalSince1970:376012800];
}

- (void)testYearsAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 365 * 3.1);//3.1 years ago - extra bit for the delay between calls
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [yearsAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"YearsAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed years ago");
}

- (void)testYearAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 365);//1 year ago
    
    // Create the NSDates
    NSDate *yearAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [yearAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastYear", @"")], @"Failed last year");
}

- (void)testMonthsAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 31 * 3);//3 months ago
    
    // Create the NSDates
    NSDate *monthsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [monthsAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"MonthsAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed months ago");
}

- (void)testMonthAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24 * 32);//1 month ago
    
    // Create the NSDates
    NSDate *monthAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [monthAgo stringDescribingTimeIntervalSince:self.referenceDate];
    //XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastMonth", @"")], @"Failed last month");
    XCTAssertEqualObjects( timeSince, NSLocalizedString(@"LastMonth", @""), @"Failed last month");
}

- (void)testWeeksAgo
{
    NSInteger timeInterval = -(3 * 7); // 3 weeks ago
    
    // Create the NSDates
    NSDate *weeksAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:timeInterval toDate:self.referenceDate options:0];
    NSString *timeSince = [weeksAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"WeeksAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Weeks ago");
}

- (void)testWeekAgo
{
    // The time interval
    NSInteger timeInterval = -7; // 1 week ago
    
    // Create the NSDates
    NSDate *weekAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:timeInterval toDate:self.referenceDate options:0];
    NSString *timeSince = [weekAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"LastWeek", @"")], @"Failed last Week");
}

- (void)testDaysAgo
{
    // The time interval
    NSInteger timeInterval = -3; // 3 Days ago
    
    // Create the NSDates
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:timeInterval toDate:self.referenceDate options:0];
    NSString *timeSince = [daysAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"DaysAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed days ago");
}

- (void)testDayAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 24);//1 Day ago
    
    // Create the NSDates
    NSDate *dayAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [dayAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Yesterday", @"")], @"Failed Yesterday");
}

- (void)testHoursAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60 * 3);//3 Hour ago
    
    // Create the NSDates
    NSDate *hoursAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [hoursAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"HoursAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Hours ago");
}

- (void)testHourAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 60);//1 Hour ago
    
    // Create the NSDates
    NSDate *hourAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [hourAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"HourAgo", @"")], @"Failed HourAgo");
}


- (void)testMinutesAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60 * 3);//3 Minute ago
    
    // Create the NSDates
    NSDate *minutesAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [minutesAgo stringDescribingTimeIntervalSince:self.referenceDate];
    NSString *testString = [NSString stringWithFormat:NSLocalizedString(@"MinutesAgo", @""), 3];
    XCTAssertTrue([timeSince isEqualToString:testString], @"Failed Minutes ago");
}

- (void)testMinuteAgo
{
    // The time interval
    NSTimeInterval theTimeInterval = -(60);//1 Minute ago
    
    // Create the NSDates
    NSDate *minuteAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [minuteAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"MinuteAgo", @"")], @"Failed HourAgo");
}

- (void)testNow
{
    // The time interval
    NSTimeInterval theTimeInterval = -(10);
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [yearsAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Now", @"")], @"Failed Now");
}

- (void)testZero
{
    // The time interval
    NSTimeInterval theTimeInterval = (0);
    
    // Create the NSDates
    NSDate *yearsAgo = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:self.referenceDate];
    NSString *timeSince = [yearsAgo stringDescribingTimeIntervalSince:self.referenceDate];
    XCTAssertTrue([timeSince isEqualToString:NSLocalizedString(@"Now", @"")], @"Failed Now");
}

@end
