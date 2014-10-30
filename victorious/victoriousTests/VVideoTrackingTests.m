//
//  VVideoTrackingTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTracking.h"
#import "VTrackingManager.h"
#import "VDummyModels.h"
#import "VCVideoPlayerViewController.h"

@interface VCVideoPlayerViewController (UnitTest)

@property (nonatomic, strong) VTrackingManager *trackingManager;
@property (nonatomic, readonly) NSDictionary *trackingParameters;
@property (nonatomic, readonly) NSDictionary *trackingParametersForSkipEvent;

- (BOOL)didSkipFromPreviousTime:(CMTime)previousTime toCurrentTime:(CMTime)currentTime;

@end

@interface VVideoTrackingTests : XCTestCase

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayer;
@property (nonatomic, strong) VTracking *trackingItem;

@end

@implementation VVideoTrackingTests

- (void)setUp
{
    [super setUp];
    
    self.videoPlayer = [[VCVideoPlayerViewController alloc] init];
    self.trackingItem = (VTracking *)[VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEnableTracking
{
    XCTAssertNoThrow( [self.videoPlayer enableTrackingWithTrackingItem:self.trackingItem] );
    XCTAssert( self.videoPlayer.isTrackingEnabled );
    XCTAssertNotNil( self.videoPlayer.trackingManager );
}

- (void)testEnableTrackingError
{
    XCTAssertThrows( [self.videoPlayer enableTrackingWithTrackingItem:nil] );
    XCTAssertFalse( self.videoPlayer.isTrackingEnabled );
    XCTAssertNil( self.videoPlayer.trackingManager );
    
    XCTAssertThrows( [self.videoPlayer enableTrackingWithTrackingItem:(VTracking *)[NSObject new]] );
    XCTAssertFalse( self.videoPlayer.isTrackingEnabled );
    XCTAssertNil( self.videoPlayer.trackingManager );
}

- (void)testParams
{
    NSDictionary *params = self.videoPlayer.trackingParameters;
    XCTAssertNotNil( params );
    XCTAssertEqual( params.allKeys.count, (NSUInteger)1 );
    
    XCTAssertNotNil( params[ kTrackingKeyTimeCurrent ] );
    XCTAssert( [params[ kTrackingKeyTimeCurrent ] isKindOfClass:[NSNumber class]] );
}

- (void)testParamsSkip
{
    NSDictionary *params = self.videoPlayer.trackingParametersForSkipEvent;
    XCTAssertNotNil( params );
    XCTAssertEqual( params.allKeys.count, (NSUInteger)2 );
    
    XCTAssertNotNil( params[ kTrackingKeyTimeFrom ] );
    XCTAssert( [params[ kTrackingKeyTimeFrom ] isKindOfClass:[NSNumber class]] );
    
    XCTAssertNotNil( params[ kTrackingKeyTimeTo ] );
    XCTAssert( [params[ kTrackingKeyTimeTo ] isKindOfClass:[NSNumber class]] );
}

- (void)testDetectSkip
{
    CMTime current;
    CMTime previous;
    int32_t scale = 10;
    
    current = CMTimeMake( 15, scale );
    previous = CMTimeMake( 4, scale );
    XCTAssert( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
    
    current = CMTimeMake( 4, scale );
    previous = CMTimeMake( 15, scale );
    XCTAssert( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
    
    current = CMTimeMake( 15, scale );
    previous = CMTimeMake( 5, scale );
    XCTAssert( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
    
    current = CMTimeMake( 5, scale );
    previous = CMTimeMake( 15, scale );
    XCTAssert( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
    
    current = CMTimeMake( 15, scale );
    previous = CMTimeMake( 6, scale );
    XCTAssertFalse( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
    
    current = CMTimeMake( 6, scale );
    previous = CMTimeMake( 15, scale );
    XCTAssertFalse( [self.videoPlayer didSkipFromPreviousTime:previous toCurrentTime:current] );
}

@end
