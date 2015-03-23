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
#import "VDummyModels.h"
#import "VCVideoPlayerViewController.h"

@interface VCVideoPlayerViewController (UnitTest)

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
}

- (void)testEnableTrackingError
{
    [self.videoPlayer enableTrackingWithTrackingItem:nil];
    XCTAssertFalse( self.videoPlayer.isTrackingEnabled );
    
    XCTAssertThrows( [self.videoPlayer enableTrackingWithTrackingItem:(VTracking *)[NSObject new]] );
    XCTAssertFalse( self.videoPlayer.isTrackingEnabled );
}

@end
