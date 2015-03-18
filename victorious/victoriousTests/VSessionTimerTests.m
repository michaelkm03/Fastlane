//
//  VSessionTimerTests.m
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSessionTimer.h"
#import "VTrackingManager.h"
#import "VSettingManager.h"

@interface VSessionTimer ()

@property (nonatomic) BOOL firstLaunch;
@property (nonatomic, strong) VSettingManager *settingsManager;
@property (nonatomic) BOOL transitioningFromBackgroundToForeground;
@property (nonatomic, strong) NSMutableArray *queuedEventNames;

- (void)trackEventsInQueue;
- (void)trackEventsForSessionDidStart;
- (void)applicationDidEnterBackground:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;

@end

@interface VSessionTimerTests : XCTestCase

@property (nonatomic, strong) VSessionTimer *sessionTimer;

@end

@implementation VSessionTimerTests

- (void)setUp
{
    [super setUp];
    
    self.sessionTimer = [[VSessionTimer alloc] init];
    XCTAssertNotNil( self.sessionTimer.queuedEventNames );
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)0 );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFirstLaunch
{
    self.sessionTimer.firstLaunch = YES;
    [self.sessionTimer trackEventsForSessionDidStart];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)2, @"2 events should be queued but not sent." );
    XCTAssert( [self.sessionTimer.queuedEventNames containsObject:VTrackingEventApplicationDidLaunch] );
    XCTAssert( [self.sessionTimer.queuedEventNames containsObject:VTrackingEventApplicationFirstInstall] );
}

- (void)testLaunch
{
    self.sessionTimer.firstLaunch = NO;
    [self.sessionTimer trackEventsForSessionDidStart];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)1, @"1 event should be queued but not sent." );
    XCTAssert( [self.sessionTimer.queuedEventNames containsObject:VTrackingEventApplicationDidEnterForeground] );
}

- (void)testEnterForeground
{
    self.sessionTimer.transitioningFromBackgroundToForeground = YES;
    [self.sessionTimer applicationDidBecomeActive:nil];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)1, @"1 event should be queued but not sent." );
    XCTAssert( [self.sessionTimer.queuedEventNames containsObject:VTrackingEventApplicationDidEnterForeground] );
}

- (void)testEnterBackground
{
    [self.sessionTimer applicationDidEnterBackground:nil];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)1, @"1 event should be queued but not sent." );
    XCTAssert( [self.sessionTimer.queuedEventNames containsObject:VTrackingEventApplicationDidEnterBackground] );
}

- (void)testTrackQueuedEvents
{
    self.sessionTimer.firstLaunch = YES;
    [self.sessionTimer trackEventsForSessionDidStart];
    self.sessionTimer.firstLaunch = NO;
    [self.sessionTimer trackEventsForSessionDidStart];
    [self.sessionTimer trackEventsForSessionDidStart];
    self.sessionTimer.transitioningFromBackgroundToForeground = YES;
    [self.sessionTimer applicationDidBecomeActive:nil];
    [self.sessionTimer applicationDidEnterBackground:nil];
    
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)6,
                   @"6 events should be queued but not sent." );
    [self.sessionTimer trackEventsInQueue];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)6,
                   @"Event you try to track events in the queue, it should not work without a VSettingManager reference." );
    
    [self.sessionTimer appInitDidCompleteWithSettingsManager:[[VSettingManager alloc] init]];
    XCTAssertEqual( self.sessionTimer.queuedEventNames.count, (NSUInteger)0,
                   @"With a valid VSettingManager reference, queued evnets should be tracked and removed from queue." );
}

@end
