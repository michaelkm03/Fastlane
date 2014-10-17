//
//  VFollowersTextFormatterTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowersTextFormatter.h"

#import <XCTest/XCTest.h>

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
    XCTAssert( [[VFollowersTextFormatter shortLabelWithNumberOfFollowers:1] isEqualToString: @"1 Follower"] );
}

- (void)testNone
{
    XCTAssert( [[VFollowersTextFormatter shortLabelWithNumberOfFollowers:0] isEqualToString: @"No Followers"] );
}

- (void)testPlural
{
    XCTAssert( [[VFollowersTextFormatter shortLabelWithNumberOfFollowers:9] isEqualToString: @"9 Followers"] );
    XCTAssert( [[VFollowersTextFormatter shortLabelWithNumberOfFollowers:99] isEqualToString: @"99 Followers"] );
    XCTAssert( [[VFollowersTextFormatter shortLabelWithNumberOfFollowers:999] isEqualToString: @"999 Followers"] );
}

- (void)testThousands
{
    NSString *label = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:1000];
    XCTAssert( [label isEqualToString: @"1.0K Followers"] );
    
    label = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:2500];
    XCTAssert( [label isEqualToString: @"2.5K Followers"] );
    
    label = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:5180];
    XCTAssert( [label isEqualToString: @"5.2K Followers"] );
    
    label = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:21225];
    XCTAssert( [label isEqualToString: @"21.2K Followers"] );
    
    label = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:1530500];
    XCTAssert( [label isEqualToString: @"1,530.5K Followers"] );
}

- (void)testMethods
{
    NSString *result1 = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:1];
    NSString *result2 = [VFollowersTextFormatter shortLabelWithNumberOfFollowersObject:@1];
    XCTAssert( [result1 isEqualToString:result2] );
    
    result1 = [VFollowersTextFormatter shortLabelWithNumberOfFollowers:9];
    result2 = [VFollowersTextFormatter shortLabelWithNumberOfFollowersObject:@9];
    XCTAssert( [result1 isEqualToString:result2] );
}

@end
