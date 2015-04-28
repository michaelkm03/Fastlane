//
//  VLaunchScreenProviderTests.m
//  victorious
//
//  Created by Sharif Ahmed on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VLaunchScreenProvider.h"

@interface VLaunchScreenProviderTests : XCTestCase

@end

@implementation VLaunchScreenProviderTests

- (void)testLaunchScreen
{
    UIView *launchScreen = [VLaunchScreenProvider launchScreen];
    XCTAssert([launchScreen isKindOfClass:[UIView class]], @"launchScreen should return a UIView");
}

- (void)testScreenshotLaunchScreen
{
    CGSize size = CGSizeMake(200, 200);
    UIImage *screenShot = [VLaunchScreenProvider screenshotOfLaunchScreenAtSize:size];
    XCTAssertTrue(CGSizeEqualToSize(size, screenShot.size), @"screenshotOfLaunchScreenAtSize: should return a screenshot of the provided size");
}

- (void)testCallFromBackgroundThreads
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        XCTAssertThrows([VLaunchScreenProvider screenshotOfLaunchScreenAtSize:CGSizeMake(20, 20)]);
        XCTAssertThrows([VLaunchScreenProvider launchScreen]);
    });
}

@end
