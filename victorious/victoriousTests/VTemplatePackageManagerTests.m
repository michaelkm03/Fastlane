//
//  VTemplatePackageManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplatePackageManager.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VTemplatePackageManagerTests : XCTestCase

@property (nonatomic, strong) VTemplatePackageManager *packageManager;
@property (nonatomic, strong) NSSet *urls;

@end

@implementation VTemplatePackageManagerTests

- (void)setUp
{
    [super setUp];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"templateWithImageURLs" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.packageManager = [[VTemplatePackageManager alloc] initWithTemplateJSON:configuration];
    self.urls = [self.packageManager referencedURLs];
}

- (void)testPlainImage
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/myImage"]] );
}

- (void)testImageSet
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/imageSetOne"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/imageSetTwo"]] );
}

- (void)testImageMacro
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00000.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00001.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00002.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00003.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00004.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00005.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00006.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00007.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00008.png"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/ballistics/tomato_00009.png"]] );
}

- (void)testSimpleArrayOfImages
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/arrayOne"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/arrayTwo"]] );
}

- (void)testImageInsideComponent
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/icon"]] );
}

- (void)testImageArrayInsideComponent
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/menuOne"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/menuTwo"]] );
}

- (void)testImagesInsideArraysOfComponents
{
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/thing"]] );
    XCTAssert( [self.urls containsObject:[NSURL URLWithString:@"http://www.example.com/other"]] );
}

@end
