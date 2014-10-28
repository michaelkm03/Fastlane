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

@end

@implementation AVAsset_OrientationTests

- (void)setUp
{
    [super setUp];
}

- (AVAsset *)videoAsset:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:name withExtension:@"m4v"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    XCTAssertNotNil( asset );
    return asset;
}

- (void)testBackFacing
{
    AVAsset *asset;
    
    asset = [self videoAsset:@"landscape_left"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationLandscapeLeft );
    
    asset = [self videoAsset:@"landscape_right"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationLandscapeRight );
    
    asset = [self videoAsset:@"portrait"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationPortrait );
    
    asset = [self videoAsset:@"portrait_upsidedown"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationPortraitUpsideDown );
}

- (void)testFrontFacing
{
    AVAsset *asset;
    
    asset = [self videoAsset:@"front_landscape_left"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationLandscapeRight ); // Note: Flipped because camera is mirrored
    
    asset = [self videoAsset:@"front_landscape_right"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationLandscapeLeft ); // Note: Flipped because camera is mirrored
    
    asset = [self videoAsset:@"front_portrait"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationPortrait );
    
    asset = [self videoAsset:@"front_portrait_upsidedown"];
    XCTAssertEqual( asset.videoOrientation, UIDeviceOrientationPortraitUpsideDown );
}

@end
