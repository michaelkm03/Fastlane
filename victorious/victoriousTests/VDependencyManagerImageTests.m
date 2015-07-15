//
//  VDependencyManagerImageTests.m
//  victorious
//
//  Created by Josh Hinman on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VDataCacheID.h"
#import "VDataCache.h"
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

- (void)testImageWithName
{
    UIImage *expected = [UIImage imageNamed:@"C_menu"];
    XCTAssertNotNil(expected); // This assert will fail if the "C_menu" image is ever removed from our project
    UIImage *actual = [self.dependencyManager imageForKey:@"myImage"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testImage
{
    // This test will fail if the "C_menu" image is ever removed from our project
    UIImage *sampleImage = [UIImage imageNamed:@"C_menu"];
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:@{ @"myImage": sampleImage }
                                                            dictionaryOfClassesByTemplateName:nil];
    UIImage *actual = [dependencyManager imageForKey:@"myImage"];
    XCTAssertEqualObjects(actual, sampleImage);
}

- (void)testRemoteImage
{
    NSURL *imageBundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"png"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageBundleURL];
    UIImage *expected = [UIImage imageWithData:imageData];
    
    VDataCache *dataCache = [[VDataCache alloc] init];
    NSError *error = nil;
    [dataCache cacheDataAtURL:imageBundleURL forID:[NSURL URLWithString:@"http://www.example.com/testRemoteImage"] error:&error];
    XCTAssertNil(error);
    
    UIImage *actual = [self.dependencyManager imageForKey:@"myRemoteImage"];
    XCTAssert( [actual isKindOfClass:[UIImage class]] );
    XCTAssert( CGSizeEqualToSize(expected.size, actual.size) );
}

- (void)testArrayOfImageURLs
{
    NSArray *images = [self.dependencyManager arrayOfImageURLsForKey:@"myImages"];
    XCTAssertEqual(images.count, 5u);
    XCTAssertEqualObjects(images[0], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00000.png");
    XCTAssertEqualObjects(images[1], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00001.png");
    XCTAssertEqualObjects(images[2], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00002.png");
    XCTAssertEqualObjects(images[3], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00003.png");
    XCTAssertEqualObjects(images[4], @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/6/images/tomato_00004.png");
}

@end
