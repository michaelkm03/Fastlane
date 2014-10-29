//
//  VTrackingManagerQueueTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VAsyncTestHelper.h"
#import "VObjectManager.h"
#import "NSObject+VMethodSwizzling.h"

#import <UIKit/UIKit.h>
#import <Nocilla/Nocilla.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#undef andReturn // to make Nocilla play well with OCMock
#undef andDo

static NSString * const kTestingUrl = @"http://www.example.com";

@interface VTrackingManagerQueueTests : XCTestCase

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) VTrackingManager *trackingManager;
@property (nonatomic, assign) NSUInteger eventCount;
@property (nonatomic, strong) VAsyncTestHelper *async;
@property (nonatomic, assign) IMP sharedManagerImp;

@end

@implementation VTrackingManagerQueueTests

- (void)setUp
{
    [super setUp];
    
    [[LSNocilla sharedInstance] stop];
    [[LSNocilla sharedInstance] start];
    
    self.eventCount = 10;
    self.trackingManager = [[VTrackingManager alloc] init];
    self.urls = @[ kTestingUrl, kTestingUrl, kTestingUrl ];
    
    self.sharedManagerImp = [VObjectManager v_swizzleClassMethod:@selector(sharedManager) withBlock:(VObjectManager *)^
                             {
                                 return [[VObjectManager alloc] init];
                             }];
}

- (void)tearDown
{
    [VObjectManager v_restoreOriginalImplementation:self.sharedManagerImp forClassMethod:@selector(sharedManager)];
    
    [[LSNocilla sharedInstance] stop];
    
    [super tearDown];
}

- (void)queueEvents:(NSUInteger)count
{
    NSDictionary *params = @{ @"param-key" : @"param-value" };
    for ( NSUInteger i = 0; i < count; i++ )
    {
        [self.trackingManager queueEventWithUrls:self.urls andParameters:params withKey:@(i)];
    }
}

- (void)testQueue
{
    [self queueEvents:self.eventCount / 2];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount / 2 );
    
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount,
                   @"Events with duplicate keys should not be added." );
    
    
    __block NSUInteger callCount = 0;
    __block NSUInteger expectedCallCount = self.eventCount * self.urls.count;
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                               NSInteger *status,
                                                               id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 XCTAssertEqual( *status, 200 );
                                                                 if ( ++callCount >= expectedCallCount )
                                                                 {
                                                                     [self.async signal];
                                                                 }
                                                             });
    
    [self.trackingManager sendQueuedTrackingEvents];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, (NSUInteger)0 );
    [self.async waitForSignal:5.0f];
}

- (void)testNoSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount );
    
    self.trackingManager.shouldIgnoreEventsInQueueOnDealloc = YES;
    
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                               NSInteger *status,
                                                               id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 XCTAssert( false, @"This should never be called" );
                                                             });
    self.trackingManager = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.async signal];
    });
    [self.async waitForSignal];
}

- (void)testSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount );
    
    XCTAssert( !self.trackingManager.shouldIgnoreEventsInQueueOnDealloc, @"Default value should be NO" );
    
    __block NSUInteger callCount = 0;
    __block NSUInteger expectedCallCount = self.eventCount * self.urls.count;
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                               NSInteger *status,
                                                               id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 XCTAssertEqual( *status, 200 );
                                                                 if ( ++callCount >= expectedCallCount )
                                                                 {
                                                                     [self.async signal];
                                                                 }
                                                             });
    
    self.trackingManager = nil;
}

@end
