//
//  VTimerManagerTests.m
//  victorious
//
//  Created by Sharif Ahmed on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTimerManager.h"

@interface VTimerManagerTests : XCTestCase

@property (nonatomic, assign) BOOL fired;
@property (nonatomic, assign) NSTimeInterval timerInterval;
@property (nonatomic, assign) NSTimeInterval testInterval;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSRunLoop *backgroundRunLoop;

@end

@implementation VTimerManagerTests

- (void)setUp
{
    [super setUp];
    self.timerInterval = 0.2f;
    self.testInterval = 0.1f;
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Scheduled timer tests

- (void)testBadScheduledInitParameters
{
    NSDictionary *userInfo = [NSDictionary dictionary];
    XCTAssertThrows([VTimerManager scheduledTimerManagerWithTimeInterval:0.0f
                                                                  target:nil
                                                                selector:@selector(testBadScheduledInitParameters)
                                                                userInfo:userInfo
                                                                 repeats:NO], @"should throw error for nil target");
    XCTAssertThrows([VTimerManager scheduledTimerManagerWithTimeInterval:0.0f
                                                                  target:self
                                                                selector:nil
                                                                userInfo:userInfo
                                                                 repeats:NO], @"should throw error for no selector");
    
    //Clang lines suppress "undeclared selector" warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    XCTAssertThrows([VTimerManager scheduledTimerManagerWithTimeInterval:0.0f
                                                                  target:self
                                                                selector:@selector(badSelector)
                                                                userInfo:userInfo
                                                                 repeats:NO], @"should throw error for selector that target does not respond to");
#pragma clang diagnostic pop
    
    XCTAssertThrows([VTimerManager scheduledTimerManagerWithTimeInterval:0.0f
                                                                  target:self
                                                                selector:@selector(selectorWithTwo:parameters:)
                                                                userInfo:userInfo
                                                                 repeats:NO], @"should throw error for selector with more than one parameter");
}

- (void)testScheduledInitWithNoParams
{
    [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                  target:self
                                                selector:@selector(selectorWithNoParams)
                                                userInfo:nil
                                                 repeats:NO];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertTrue(self.fired, @"timer should have fired");
}

- (void)testScheduledInitWithOneParam
{
    [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                  target:self
                                                selector:@selector(selectorWithOneParameter:)
                                                userInfo:nil
                                                 repeats:NO];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertTrue(self.fired, @"timer should have fired");
}

- (void)testScheduledWeakReference
{
    __weak VTimerManagerTests *wTester;
    @autoreleasepool
    {
        VTimerManagerTests *tester = [[VTimerManagerTests alloc] init];
        [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                      target:tester
                                                    selector:@selector(setFireToTesterInTimer:)
                                                    userInfo:self
                                                     repeats:NO];
        wTester = tester;
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertNil(wTester, @"tester should have been deallocated by now, test is invalid");
    XCTAssertFalse(self.fired, @"the tester should have been deallocated and released before the timer fired");
}

#pragma mark - Non-scheduled timer tests

- (void)testBadUnscheduledInitParameters
{
    NSDictionary *userInfo = [NSDictionary dictionary];
    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:nil
                                                          selector:@selector(testBadUnscheduledInitParameters)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:[NSRunLoop currentRunLoop]
                                                       withRunMode:NSRunLoopCommonModes], @"should throw error for nil target");
    
    //Clang lines suppress "undeclared selector" warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:self
                                                          selector:@selector(badSelector)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:[NSRunLoop currentRunLoop]
                                                       withRunMode:NSRunLoopCommonModes], @"should throw error for selector that target does not respond to");
#pragma clang diagnostic pop

    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:nil
                                                          selector:@selector(selectorWithTwo:parameters:)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:[NSRunLoop currentRunLoop]
                                                       withRunMode:NSRunLoopCommonModes], "should throw error for selector with more than one parameter");
    
    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:nil
                                                          selector:@selector(testBadUnscheduledInitParameters)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:nil
                                                       withRunMode:NSRunLoopCommonModes], @"should throw error for nil runLoop");
    
    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:nil
                                                          selector:@selector(testBadUnscheduledInitParameters)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:[NSRunLoop currentRunLoop]
                                                       withRunMode:NSRunLoopCommonModes], @"should throw error for invalid runMode");
    XCTAssertThrows([VTimerManager addTimerManagerWithTimeInterval:0.0f
                                                            target:nil
                                                          selector:@selector(testBadUnscheduledInitParameters)
                                                          userInfo:userInfo
                                                           repeats:NO
                                                         toRunLoop:[NSRunLoop currentRunLoop]
                                                       withRunMode:NSRunLoopCommonModes], @"should throw error for nil target");
    XCTAssertThrows([VTimerManager scheduledTimerManagerWithTimeInterval:0.0f
                                                                  target:self
                                                                selector:nil
                                                                userInfo:userInfo
                                                                 repeats:NO], @"should throw error for no selector");
    
}

- (void)testUnscheduledInitWithNoParams
{
    [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                  target:self
                                                selector:@selector(selectorWithNoParams)
                                                userInfo:nil
                                                 repeats:NO];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertTrue(self.fired, @"timer should have fired");
}

- (void)testUnscheduledInitWithOneParam
{
    [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                  target:self
                                                selector:@selector(selectorWithOneParameter:)
                                                userInfo:nil
                                                 repeats:NO];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertTrue(self.fired, @"timer should have fired");
}

- (void)testUnscheduledWeakReference
{
    __weak VTimerManagerTests *wTester;
    @autoreleasepool
    {
        VTimerManagerTests *tester = [[VTimerManagerTests alloc] init];
        [VTimerManager scheduledTimerManagerWithTimeInterval:self.timerInterval
                                                      target:tester
                                                    selector:@selector(setFireToTesterInTimer:)
                                                    userInfo:self
                                                     repeats:NO];
        wTester = tester;
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.timerInterval + self.testInterval]];
    XCTAssertNil(wTester, @"tester should have been deallocated by now, test is invalid");
    XCTAssertFalse(self.fired, @"the tester should have been deallocated and released before the timer fired");
}

#pragma mark - timer repsonse functions

- (void)selectorWithTwo:(int)two parameters:(int)parameters
{
    
}

- (void)selectorWithNoParams
{
    self.fired = YES;
}

- (void)selectorWithOneParameter:(NSTimer *)oneParameter
{
    XCTAssertNotNil(oneParameter, @"timer retured from firing should not be nil");
    self.fired = YES;
}

- (void)setFireToTesterInTimer:(NSTimer *)timer
{
    XCTAssertNotNil(timer, @"timer retured from firing should not be nil");
    ((VTimerManagerTests *)timer.userInfo).fired = YES;
}

@end
