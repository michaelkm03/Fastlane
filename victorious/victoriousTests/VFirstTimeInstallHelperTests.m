//
//  VFirstTimeInstallHelperTests.m
//  victorious
//
//  Created by Lawrence Leach on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VFirstTimeInstallHelper.h"

static NSString * const VDidPlayFirstTimeUserVideo = @"com.getvictorious.settings.didPlayFirstTimeUserVideo";

@interface VFirstTimeInstallHelperTests : XCTestCase

@end

@implementation VFirstTimeInstallHelperTests

- (void)setUp
{
    [super setUp];
    [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:VDidPlayFirstTimeUserVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)testFirstTimeHelper
{
    VFirstTimeInstallHelper *ftInstallHelper = [[VFirstTimeInstallHelper alloc] init];
    XCTAssertFalse([ftInstallHelper hasBeenShown]);
    [ftInstallHelper savePlaybackDefaults];
    XCTAssert([ftInstallHelper hasBeenShown]);
    
    VFirstTimeInstallHelper *postTestInstallHelper = [[VFirstTimeInstallHelper alloc] init];
    XCTAssert([postTestInstallHelper hasBeenShown]);
}

@end
