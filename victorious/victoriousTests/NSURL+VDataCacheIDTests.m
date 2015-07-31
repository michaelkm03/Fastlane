//
//  NSURL+VDataCacheIDTests.m
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VDataCacheID.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface NSURL_VDataCacheIDTests : XCTestCase

@end

@implementation NSURL_VDataCacheIDTests

- (void)testID
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com"];
    NSString *expected = @"dd014af5ed6b38d9130e3f466f850e46d21b951199d53a18ef29ee9341614eaf";
    NSString *actual = [url identifierForDataCache];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testCaseInsensitivity
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.GOOGLE.com"];
    NSString *expected = @"dd014af5ed6b38d9130e3f466f850e46d21b951199d53a18ef29ee9341614eaf";
    NSString *actual = [url identifierForDataCache];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testWithSlash
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com/"];
    NSString *expected = @"dd014af5ed6b38d9130e3f466f850e46d21b951199d53a18ef29ee9341614eaf";
    NSString *actual = [url identifierForDataCache];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testHTTPS
{
    NSURL *url = [[NSURL alloc] initWithString:@"HTTPS://www.google.com/"];
    NSString *expected = @"d0e196a0c25d35dd0a84593cbae0f38333aa58529936444ea26453eab28dfc86";
    NSString *actual = [url identifierForDataCache];
    XCTAssertEqualObjects(expected, actual);
}

@end
