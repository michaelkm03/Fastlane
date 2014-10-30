//
//  VTrackingManagerQueueTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VTrackingManager.h"

@interface VTrackingManager (UnitTests)

- (void)sendRequestWithUrlString:(NSString *)url;

@end

@interface VTrackingManagerQueueTests : XCTestCase

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) VTrackingManager *trackingManager;
@property (nonatomic, assign) IMP sendRequestImp;
@property (nonatomic, assign) NSUInteger eventCount;

@end

@implementation VTrackingManagerQueueTests

- (void)setUp
{
    [super setUp];
    
    self.trackingManager = [[VTrackingManager alloc] init];
    
    self.eventCount = 20;
    
    self.urls = @[ @"url", @"url", @"url" ];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( self.sendRequestImp )
    {
        [VTrackingManager v_restoreOriginalImplementation:self.sendRequestImp forMethod:@selector(sendRequestWithUrlString:)];
    }
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
    self.sendRequestImp = [VTrackingManager v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    [self.trackingManager sendQueuedTrackingEvents];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, (NSUInteger)0 );
    XCTAssertEqual( callCount, self.eventCount * self.urls.count );
}

- (void)testNoSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount );
    
    self.trackingManager.shouldIgnoreEventsInQueueOnDealloc = YES;
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VTrackingManager v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    self.trackingManager = nil;
    XCTAssertEqual( callCount, (NSUInteger)0);
}

- (void)testSendOnDealloc
{
    [self queueEvents:self.eventCount];
    XCTAssertEqual( self.trackingManager.numberOfQueuedEvents, self.eventCount );
    
    XCTAssert( !self.trackingManager.shouldIgnoreEventsInQueueOnDealloc, @"Default value should be NO" );
    
    __block NSUInteger callCount = 0;
    self.sendRequestImp = [VTrackingManager v_swizzleMethod:@selector(sendRequestWithUrlString:) withBlock:^void(NSString *url)
                           {
                               callCount++;
                           }];
    
    self.trackingManager = nil;
    XCTAssertEqual( callCount, self.eventCount * self.urls.count );
}

@end
