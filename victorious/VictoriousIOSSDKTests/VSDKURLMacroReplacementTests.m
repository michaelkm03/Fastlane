//
//  VSDKURLMacroReplacementTests.m
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSDKURLMacroReplacement.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VSDKURLMacroReplacementTests : XCTestCase

@property (nonatomic, strong) VSDKURLMacroReplacement *macroReplacement;

@end

@implementation VSDKURLMacroReplacementTests

- (void)setUp
{
    [super setUp];
    self.macroReplacement = [[VSDKURLMacroReplacement alloc] init];
}

- (void)testReplacementInPath
{
    NSString *expected = @"http://www.example.com/hello/wo=rld%2F";
    NSString *actual = [self.macroReplacement urlByReplacingMacrosFromDictionary:@{ @"%%HELLO%%": @"wo=rld/" }
                                                                    inURLString:@"http://www.example.com/hello/%%HELLO%%"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testReplacementInQueryString
{
    NSString *expected = @"http://www.example.com/hello?a=wo%3Drld/&b=%26mpersand&optional=";
    NSString *actual = [self.macroReplacement urlByReplacingMacrosFromDictionary:@{ @"%%HELLO%%": @"wo=rld/", @"%%B%%": @"&mpersand" }
                                                                    inURLString:@"http://www.example.com/hello?a=%%HELLO%%&b=%%B%%&optional=%%MISSING%%"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testEmptyDictionary
{
    NSString *expected = @"http://www.example.com/?key=";
    NSString *actual = [self.macroReplacement urlByReplacingMacrosFromDictionary:@{} inURLString:@"http://www.example.com/%%PATH%%?key=%%VALUE%%"];

    XCTAssertEqualObjects(expected, actual);
}

- (void)testNilDictionary
{
    NSString *expected = @"http://www.example.com/?key=";
    NSString *actual = [self.macroReplacement urlByReplacingMacrosFromDictionary:@{} inURLString:@"http://www.example.com/%%PATH%%?key=%%VALUE%%"];
    
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPartialReplacementInPath
{
    NSString *expected = @"http://www.example.com/hello/%%MISSING%%/wo=rld%2F";
    NSString *actual = [self.macroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ @"%%HELLO%%": @"wo=rld/" }
                                                                              inURLString:@"http://www.example.com/hello/%%MISSING%%/%%HELLO%%"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPartialReplacementInQueryString
{
    NSString *expected = @"http://www.example.com/hello?a=wo%3Drld/&b=%26mpersand&optional=%%MISSING%%";
    NSString *actual = [self.macroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ @"%%HELLO%%": @"wo=rld/", @"%%B%%": @"&mpersand" }
                                                                              inURLString:@"http://www.example.com/hello?a=%%HELLO%%&b=%%B%%&optional=%%MISSING%%"];
    XCTAssertEqualObjects(expected, actual);
}

@end
