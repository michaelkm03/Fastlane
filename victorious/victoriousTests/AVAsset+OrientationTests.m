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
    return [AVAsset assetWithURL:url];
}

- (void)test
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

@end
