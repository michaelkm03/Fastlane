//
//  VURLMacroReplacementTests.m
//  victorious
//
//  Created by Josh Hinman on 2/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VURLMacroReplacement.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VURLMacroReplacementTests : XCTestCase

@property (nonatomic, strong) VURLMacroReplacement *macroReplacement;

@end

@implementation VURLMacroReplacementTests

- (void)setUp
{
    [super setUp];
    self.macroReplacement = [[VURLMacroReplacement alloc] init];
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
    NSString *expected = @"http://www.example.com/hello?a=wo%3Drld/&b=%26mpersand";
    NSString *actual = [self.macroReplacement urlByReplacingMacrosFromDictionary:@{ @"%%HELLO%%": @"wo=rld/", @"%%B%%": @"&mpersand" }
                                                                    inURLString:@"http://www.example.com/hello?a=%%HELLO%%&b=%%B%%"];
    XCTAssertEqualObjects(expected, actual);
}

@end
