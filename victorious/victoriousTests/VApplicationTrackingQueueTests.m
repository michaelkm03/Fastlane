//
//  VApplicationTrackingQueueTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VApplicationTracking.h"

@interface VApplicationTracking (UnitTests)

@property (nonatomic, strong) NSMutableArray *queuedTrackingEvents;
@property (nonatomic, readonly) NSUInteger numberOfQueuedUrls;

- (void)sendRequestWithUrlString:(NSString *)url;
- (void)sendQueuedTrackingEventUrlsIfExceedMaximumCount:(NSUInteger)maxUrlsCount;

@end

@interface VApplicationTrackingQueueTests : XCTestCase

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) VApplicationTracking *applicaitonTracking;
@property (nonatomic, assign) IMP sendRequestImp;
@property (nonatomic, assign) NSUInteger eventCount;

@end

@implementation VApplicationTrackingQueueTests

- (void)setUp
{
    [super setUp];
    
    self.applicaitonTracking = [[VApplicationTracking alloc] init];
    
    self.eventCount = 20;
    
    self.urls = @[ @"url", @"url", @"url" ];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( self.sendRequestImp )
    {
        [VApplicationTracking v_restoreOriginalImplementation:self.sendRequestImp forMethod:@selector(sendRequestWithUrlString:)];
    }
}

- (void)queueEvents:(NSUInteger)count
{
    NSDictionary *params = @{ @"param-key" : @"param-value" };
    for ( NSUInteger i = 0; i < count; i++ )
    {
        [self.applicaitonTracking queueEventWithUrls:self.urls andParameters:params withKey:@(i)];
    }
}

- (void)testQueue
{
    [self queueEvents:self.eventCount / 2];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, self.eventCount / 2 );
    
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, self.eventCount,
                   @"Events with duplicate keys should not be added." );
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VApplicationTracking v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    [self.applicaitonTracking sendQueuedTrackingEvents];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, (NSUInteger)0 );
    XCTAssertEqual( callCount, self.eventCount * self.urls.count );
}

- (void)testNoSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, self.eventCount );
    
    self.applicaitonTracking.shouldIgnoreEventsInQueueOnDealloc = YES;
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VApplicationTracking v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    self.applicaitonTracking = nil;
    XCTAssertEqual( callCount, (NSUInteger)0);
}

- (void)testSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, self.eventCount );
    
    XCTAssert( !self.applicaitonTracking.shouldIgnoreEventsInQueueOnDealloc, @"Default value should be NO" );
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VApplicationTracking v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    self.applicaitonTracking = nil;
    XCTAssertEqual( callCount, self.eventCount * self.urls.count );
}

- (void)testLimitQueuedUrls
{
    NSUInteger eventCount = 30;
    for ( NSUInteger i = 0; i < eventCount; i++ )
    {
        NSArray *urls = @[ @"some_url", @"some_other_url", @"yet_another_url" ];
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithUrls:urls parameters:nil key:@(i)];
        [self.applicaitonTracking.queuedTrackingEvents addObject:event];
    }
    
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedUrls, eventCount * 3 );
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VApplicationTracking v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    callCount = 0;
    [self.applicaitonTracking sendQueuedTrackingEventUrlsIfExceedMaximumCount:eventCount * 3];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, eventCount );
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedUrls, (NSUInteger)eventCount * 3 );
    XCTAssertEqual( callCount, (NSUInteger)0 );
    
    callCount = 0;
    [self.applicaitonTracking sendQueuedTrackingEventUrlsIfExceedMaximumCount:eventCount * 3 - 1];
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedEvents, eventCount );
    XCTAssertEqual( self.applicaitonTracking.numberOfQueuedUrls, (NSUInteger)0 );
    XCTAssertEqual( callCount, (NSUInteger)eventCount * 3 );
}

@end
