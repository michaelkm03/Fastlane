//
//  VTrackingManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VTrackingManager.h"
#import "VAsyncTestHelper.h"
#import "VTrackingEvent.h"

@interface VTrackingManager()

@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableDictionary *durationEvents;
@property (nonatomic, readonly) NSUInteger numberOfQueuedEvents;

- (NSUInteger)numberOfQueuedEventsForEventName:(NSString *)eventName;
- (NSDictionary *)addSessionParameters:(NSDictionary *)sessionParameters toDictionary:(NSDictionary *)dictionary;

@end

@interface VTestDelegate : NSObject <VTrackingDelegate>

@property (nonatomic, strong) NSDictionary *paramsReceived;
@property (nonatomic, strong) NSString *eventNameReceived;
@property (nonatomic, assign) NSUInteger trackedEventCount;
@property (nonatomic, assign) BOOL startCalled;
@property (nonatomic, assign) BOOL endCalled;
@property (nonatomic, assign) NSTimeInterval durationReceived;

@end

@implementation VTestDelegate

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    self.paramsReceived = parameters;
    self.eventNameReceived = eventName;
    self.trackedEventCount++;
}

- (void)eventStarted:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    self.eventNameReceived = eventName;
    self.startCalled = YES;
}

- (void)eventEnded:(NSString *)eventName parameters:(NSDictionary *)parameters duration:(NSTimeInterval)duration
{
    self.eventNameReceived = eventName;
    self.durationReceived = duration;
    self.endCalled = YES;
}


- (void)resetTrackedEventCount
{
    self.trackedEventCount = 0;
}

@end

@interface VTrackingManagerTests : XCTestCase

@property (nonatomic, strong) VTrackingManager *trackingMgr;
@property (nonatomic, strong) VAsyncTestHelper *async;

@end

@implementation VTrackingManagerTests

- (void)setUp
{
    [super setUp];
    
    self.trackingMgr = [VTrackingManager sharedInstance];
    self.async = [[VAsyncTestHelper alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    [[VTrackingManager sharedInstance] removeAllDelegates];
}

- (void)testShardInstance
{
    VTrackingManager *trackingManager1 = [VTrackingManager sharedInstance];
    VTrackingManager *trackingManager2 = [VTrackingManager sharedInstance];
    VTrackingManager *trackingManager3 = [[VTrackingManager alloc] init];
    XCTAssertNotNil( trackingManager1 );
    XCTAssertNotNil( trackingManager2 );
    XCTAssertEqualObjects( trackingManager1, trackingManager2 );
    XCTAssertNotEqualObjects( trackingManager1, trackingManager3 );
    XCTAssertNotEqualObjects( trackingManager2, trackingManager3 );
}

- (void)testDelegates
{
    VTestDelegate *delegate1 = [[VTestDelegate alloc] init];
    VTestDelegate *delegate2 = [[VTestDelegate alloc] init];
    
    [self.trackingMgr addDelegate:delegate1];
    XCTAssertEqual( self.trackingMgr.delegates.count, 1u );
    
    [self.trackingMgr addDelegate:delegate2];
    XCTAssertEqual( self.trackingMgr.delegates.count, 2u );
    
    [self.trackingMgr removeDelegate:delegate2];
    XCTAssertEqual( self.trackingMgr.delegates.count, 1u );
    XCTAssertEqualObjects( self.trackingMgr.delegates[0], delegate1 );
    
    [self.trackingMgr addDelegate:delegate2];
    XCTAssertEqual( self.trackingMgr.delegates.count, 2u );
    
    [self.trackingMgr addDelegate:delegate2];
    XCTAssertEqual( self.trackingMgr.delegates.count, 2u, @"Should not add twice." );
    
    [self.trackingMgr removeAllDelegates];
    XCTAssertEqual( self.trackingMgr.delegates.count, 0u );
    
}

- (void)testTrackEvent
{
    VTestDelegate *delegate1 = [[VTestDelegate alloc] init];
    VTestDelegate *delegate2 = [[VTestDelegate alloc] init];
    [self.trackingMgr addDelegate:delegate1];
    [self.trackingMgr addDelegate:delegate2];
    
    [self.trackingMgr trackEvent:nil parameters:nil];
    XCTAssertEqual( delegate1.trackedEventCount, 0u );
    XCTAssertEqual( delegate2.trackedEventCount, 0u );
    
    [self.trackingMgr trackEvent:@"" parameters:nil];
    XCTAssertEqual( delegate1.trackedEventCount, 0u );
    XCTAssertEqual( delegate2.trackedEventCount, 0u );
    
    NSString *event = @"some_event";
    NSDictionary *params = @{ @"param_key" : @"param_value" };
    [self.trackingMgr trackEvent:event parameters:params];
    XCTAssertEqual( delegate1.trackedEventCount, 1u );
    XCTAssertEqual( delegate2.trackedEventCount, 1u );
    XCTAssertEqualObjects( event, delegate1.eventNameReceived );
    XCTAssertEqualObjects( event, delegate2.eventNameReceived );
    XCTAssertEqualObjects( params[ @"param_key" ], delegate1.paramsReceived[ @"param_key" ] );
}

- (void)testSessionParameter
{
    NSString * const paramKey = @"abc";
    NSString * const paramValue = @"def";
    
    VTestDelegate *delegate = [[VTestDelegate alloc] init];
    [self.trackingMgr addDelegate:delegate];
    
    [self.trackingMgr setValue:paramValue forSessionParameterWithKey:paramKey];
    [self.trackingMgr trackEvent:@"some_event"];
    XCTAssertEqualObjects(paramValue, delegate.paramsReceived[paramKey]);
}

- (void)testClearSessionParameters
{
    NSString * const param1Key = @"abc";
    NSString * const param1Value = @"def";
    NSString * const param2Key = @"xyz";
    NSString * const param2Value = @"zyx";

    VTestDelegate *delegate = [[VTestDelegate alloc] init];
    [self.trackingMgr addDelegate:delegate];
    
    [self.trackingMgr setValue:param1Value forSessionParameterWithKey:param1Key];
    [self.trackingMgr setValue:param2Value forSessionParameterWithKey:param2Key];
    [self.trackingMgr clearAllSessionParameterValues];
    
    [self.trackingMgr trackEvent:@"some_event"];
    XCTAssertNil(delegate.paramsReceived[param1Key]);
    XCTAssertNil(delegate.paramsReceived[param2Key]);
}

- (void)testAddSessionParamsToDictionary
{
    NSString * const param1Key = @"abc";
    NSString * const param1Value = @"def";
    NSString * const param2Key = @"xyz";
    NSString * const param2Value = @"zyx";
    
    NSString * const session1Value = @"jkl";
    NSString * const session2Key = @"mno";
    NSString * const session2Value = @"pqr";
    
    [self.trackingMgr setValue:session1Value forSessionParameterWithKey:param1Key];
    [self.trackingMgr setValue:session2Value forSessionParameterWithKey:session2Key];
    
    NSDictionary *sessionParameters = @{ param1Key : session1Value, session2Key : session2Value };
    NSDictionary *eventParams = @{ param1Key : param1Value, param2Key : param2Value };
    
    NSDictionary *combinedParams = [self.trackingMgr addSessionParameters: sessionParameters toDictionary:eventParams];
    
    XCTAssertEqualObjects( combinedParams[ param1Key ], param1Value,
                          @"Session parameters should not override event parameters with same key" );
    XCTAssertNotEqualObjects( combinedParams[ param1Key ], session1Value,
                             @"Session parameters should not override event parameters with same key" );
    XCTAssertEqualObjects( combinedParams[ param2Key ], param2Value );
    XCTAssertEqualObjects( combinedParams[ session2Key ], session2Value );
}

- (void)testDurationEvents
{
    VTestDelegate *delegate = [[VTestDelegate alloc] init];
    [self.trackingMgr addDelegate:delegate];
    
    NSString *eventName = @"duration_event";
    [self.trackingMgr startEvent:eventName];
    XCTAssert( delegate.startCalled );
    XCTAssertEqualObjects( delegate.eventNameReceived, eventName );
    XCTAssertNotNil( self.trackingMgr.durationEvents[ eventName ] );
    XCTAssert( [self.trackingMgr.durationEvents[ eventName ] isKindOfClass:[VTrackingEvent class]] );
    
    NSTimeInterval duration = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.async signal];
    });
    
    [self.async waitForSignal:10.0f];
    
    [self.trackingMgr endEvent:eventName];
    XCTAssert( delegate.endCalled );
    XCTAssertEqualObjects( delegate.eventNameReceived, eventName );
    XCTAssertNil( self.trackingMgr.durationEvents[ eventName ] );
    XCTAssertEqualWithAccuracy( delegate.durationReceived, duration, 0.2 );
}

- (void)testQueuedEvents
{
    VTestDelegate *delegate = [[VTestDelegate alloc] init];
    [self.trackingMgr addDelegate:delegate];
    
    NSString *eventName1 = @"queue_event_1";
    NSString *eventName2 = @"queue_event_2";
    NSUInteger numEvents1 = 10 + arc4random() % 10;
    NSUInteger numEvents2 = 40 + arc4random() % 10;
    NSUInteger totalEvents = numEvents1 + numEvents2;
    
    [delegate resetTrackedEventCount];
    for ( NSUInteger i = 0; i < numEvents1; i++ )
    {
        [self.trackingMgr queueEvent:eventName1 parameters:nil eventId:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    XCTAssertEqual( delegate.trackedEventCount, (NSUInteger)numEvents1, @"Events should be tracked when queued." );
    
    [delegate resetTrackedEventCount];
    for ( NSUInteger i = 0; i < numEvents2; i++ )
    {
        [self.trackingMgr queueEvent:eventName2 parameters:nil eventId:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    XCTAssertEqual( delegate.trackedEventCount, (NSUInteger)numEvents2, @"Events should be tracked when queued." );
    
    XCTAssertEqual( self.trackingMgr.numberOfQueuedEvents, totalEvents );
    NSUInteger eventsCount1 = [self.trackingMgr numberOfQueuedEventsForEventName:eventName1];
    XCTAssertEqual( eventsCount1, numEvents1 );
    NSUInteger eventsCount2 = [self.trackingMgr numberOfQueuedEventsForEventName:eventName2];
    XCTAssertEqual( eventsCount2, numEvents2 );
    
    [delegate resetTrackedEventCount];
    [self.trackingMgr clearQueuedEventsWithName:eventName1];
    XCTAssertEqual( self.trackingMgr.numberOfQueuedEvents, totalEvents - numEvents1 );
    XCTAssertEqual( delegate.trackedEventCount, 0u, @"No events should be tracked whened queue is cleared." );
    
    delegate.trackedEventCount = 0;
    [self.trackingMgr clearQueuedEventsWithName:eventName2];
    XCTAssertEqual( self.trackingMgr.numberOfQueuedEvents, 0u );
    XCTAssertEqual( delegate.trackedEventCount, 0u, @"No events should be tracked whened queue is cleared." );
    
    
    for ( NSUInteger i = 0; i < numEvents1; i++ )
    {
        [self.trackingMgr queueEvent:eventName1 parameters:nil eventId:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    for ( NSUInteger i = 0; i < numEvents1; i++ )
    {
        [self.trackingMgr queueEvent:eventName1 parameters:nil eventId:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    XCTAssertEqual( self.trackingMgr.numberOfQueuedEvents, numEvents1, @"Should not allow duplicates with same eventId" );
}

@end
