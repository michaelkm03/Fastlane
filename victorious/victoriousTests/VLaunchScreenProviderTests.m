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

- (void)testAddLaunchScreenToView
{
    XCTAssertThrows([VLaunchScreenProvider addLaunchScreenToView:nil]);
    
    CGRect startFrame = CGRectMake(0, 0, 200, 200);
    UIView *launchScreenContainer = [[UIView alloc] initWithFrame:startFrame];
    
    [VLaunchScreenProvider addLaunchScreenToView:launchScreenContainer];
    launchScreenContainer.bounds = CGRectMake(0, 0, 100, 100);
    
    XCTAssertEqual(launchScreenContainer.subviews.count, (NSUInteger)1, @"addLaunchScreenToView: should add the launch screen to the provided view");
    
    UIView *launchScreen = [launchScreenContainer.subviews firstObject];
    [launchScreenContainer layoutIfNeeded];
    
    XCTAssertTrue(CGRectEqualToRect(launchScreen.bounds, CGRectMake(0, 0, 100, 100)), @"addLaunchScreenToView: should add fit to parent constraints to launch screen");
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
        XCTAssertThrows([VLaunchScreenProvider addLaunchScreenToView:[[UIView alloc] init]]);
    });
}

@end
