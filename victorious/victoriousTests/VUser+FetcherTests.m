//
//  VUser+FetcherTests.m
//  victorious
//
//  Created by Michael Sena on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VUser+Fetcher.h"
#import "VDummyModels.h"

@interface VUser_FetcherTests : XCTestCase

@end

@implementation VUser_FetcherTests

- (void)testDefault
{
    VUser *user = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
    XCTAssertEqual(user.maxUploadDurationFloat, 15.0f);
}

- (void)testReturnsProperValue
{
    VUser *user = [VDummyModels objectWithEntityName:@"User" subclass:[VUser class]];
    user.maxUploadDuration = @(300);
    XCTAssertEqual(user.maxUploadDurationFloat, 300.0f);
}

@end
