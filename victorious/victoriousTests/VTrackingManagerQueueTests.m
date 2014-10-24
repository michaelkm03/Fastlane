//
//  VTrackingManagerQueueTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "VTrackingManager.h"

@interface VTrackingManager (UnitTests)

- (void)sendRequestWithUrlString:(NSString *)url;

@property (nonatomic, strong) NSMutableArray *queuedTrackingEvents;

@end

@interface VTrackingManagerQueueTests : XCTestCase

@property (nonatomic, strong) VTrackingManager *trackingManager;

@end

@implementation VTrackingManagerQueueTests

- (void)setUp
{
    [super setUp];
    
    self.trackingManager = [[VTrackingManager alloc] init];
    id myObjectMock = OCMPartialMock( self.trackingManager  );
    OCMStub( [myObjectMock sendRequestWithUrlString:[OCMArg any]] );
    self.trackingManager = (VTrackingManager *)myObjectMock;
    
    self.trackingManager = [[VTrackingManager alloc] init];
}

- (void)tearDown
{
}

- (void)testQueue
{
    NSArray *urls = @[ @"url", @"url", @"url" ];
    NSDictionary *params = @{ @"param-key" : @"param-value" };
    
    NSUInteger count = 20;
    for ( NSUInteger i = 0; i < count; i++ )
    {
        [self.trackingManager queueEventWithUrls:urls andParameters:params withKey:@(i)];
    }
    
    XCTAssertEqual( self.trackingManager.queuedTrackingEvents.count, count );
    
    for ( NSUInteger i = 0; i < 10; i++ )
    {
        [self.trackingManager queueEventWithUrls:urls andParameters:params withKey:@(i)];
    }
    
    XCTAssertEqual( self.trackingManager.queuedTrackingEvents.count, count,
                   @"Events should not be added if they key already present in the queue." );
    
    [self.trackingManager sendQueuedTrackingEvents];
}

@end
