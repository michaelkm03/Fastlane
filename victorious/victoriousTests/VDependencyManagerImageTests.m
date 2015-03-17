//
//  VDependencyManagerImageTests.m
//  victorious
//
//  Created by Josh Hinman on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VDependencyManagerImageTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VDependencyManagerImageTests

- (void)setUp
{
    [super setUp];

    // The presence of this "base" dependency manager (with an empty configuration dictionary) exposed a bug in a previous iteration of VDependencyManager.
    VDependencyManager *baseDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:@{} dictionaryOfClassesByTemplateName:nil];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"image-template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:baseDependencyManager configuration:configuration dictionaryOfClassesByTemplateName:nil];
}

- (void)testArrayOfImageURLs
{
    NSArray *images = [self.dependencyManager arrayOfImageURLsForKey:@"myImages"];
    XCTAssertEqual(images.count, 5u);
    XCTAssertEqualObjects(images[0], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00001.png");
    XCTAssertEqualObjects(images[1], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00002.png");
    XCTAssertEqualObjects(images[2], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00003.png");
    XCTAssertEqualObjects(images[3], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00004.png");
    XCTAssertEqualObjects(images[4], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00005.png");
}

- (void)testAllImageURLs
{
    NSArray *images = [self.dependencyManager arrayOfAllImageURLs];
    XCTAssertEqual(images.count, 18u);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00001.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00002.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00003.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00004.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00005.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00001.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00002.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00003.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00004.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00005.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00006.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00007.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00008.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00009.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00010.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00011.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00012.png"]);
    XCTAssert([images containsObject:@"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/heart_00013.png"]);
}

@end
