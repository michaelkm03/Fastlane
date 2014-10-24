//
//  AVAsset+OrientationTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AVAsset+Orientation.h"
#import "OCMock.h"

@interface AVAsset_OrientationTests : XCTestCase

@property (nonatomic, strong) AVAssetTrack *assetTrack;
@property (nonatomic, strong) id mockAssetTrack;
@property (nonatomic, strong) AVAsset* mockAsset;

@end

@implementation AVAsset_OrientationTests

- (void)setUp
{
    [super setUp];
    
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleVideo" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    self.mockAsset = OCMPartialMock( asset );
}

- (void)testUnknown
{
    OCMStub( [self.mockAsset tracksWithMediaType:[OCMArg any]] ).andReturn( @[] );
    XCTAssertEqual( self.mockAsset.videoOrientation, UIDeviceOrientationUnknown );
}

@end
