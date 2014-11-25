//
//  VFollowersTextFormatterTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VFollowersTextFormatter.h"

@interface VFollowersTextFormatterTests : XCTestCase

@end

@implementation VFollowersTextFormatterTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSingular
{
    XCTAssertEqualObjects( [VFollowersTextFormatter followerTextWithNumberOfFollowers:1], @"1 Follower" );
}

- (void)testNone
{
    XCTAssertEqualObjects( [VFollowersTextFormatter followerTextWithNumberOfFollowers:0], @"No Followers" );
}

- (void)testPlural
{
    XCTAssertEqualObjects( [VFollowersTextFormatter followerTextWithNumberOfFollowers:9], @"9 Followers" );
    XCTAssertEqualObjects( [VFollowersTextFormatter followerTextWithNumberOfFollowers:99], @"99 Followers" );
    XCTAssertEqualObjects( [VFollowersTextFormatter followerTextWithNumberOfFollowers:999], @"999 Followers" );
}

- (void)testThousands
{
    NSString *label = [VFollowersTextFormatter followerTextWithNumberOfFollowers:1000];
    XCTAssertEqualObjects( label, @"1K Followers" );
    
    label = [VFollowersTextFormatter followerTextWithNumberOfFollowers:2500];
    XCTAssertEqualObjects( label, @"2K Followers" );
    
    label = [VFollowersTextFormatter followerTextWithNumberOfFollowers:5180];
    XCTAssertEqualObjects( label, @"5K Followers" );
    
    label = [VFollowersTextFormatter followerTextWithNumberOfFollowers:21225];
    XCTAssertEqualObjects( label, @"21K Followers" );
    
    label = [VFollowersTextFormatter followerTextWithNumberOfFollowers:1530500];
    XCTAssertEqualObjects( label, @"1M Followers" );
}

@end
