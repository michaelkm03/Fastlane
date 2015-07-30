//
//  VTemplateImageSetTests.m
//  victorious
//
//  Created by Josh Hinman on 6/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateImage.h"
#import "VTemplateImageSet.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VTemplateImageSetTests : XCTestCase

@property (nonatomic, strong) NSDictionary *oneXDictionary;
@property (nonatomic, strong) NSDictionary *twoXDictionary;
@property (nonatomic, strong) NSDictionary *threeXDictionary;
@property (nonatomic, strong) NSDictionary *imageSetDictionary;
@property (nonatomic, strong) VTemplateImageSet *imageSet;

@end

@implementation VTemplateImageSetTests

- (void)setUp
{
    [super setUp];
    
    self.oneXDictionary = @{ @"imageURL": @"http://www.example.com/one-x.png",
                             @"scale": @1 };
    self.twoXDictionary = @{ @"imageURL": @"http://www.example.com/two-x.png",
                             @"scale": @2 };
    self.threeXDictionary = @{ @"imageURL": @"http://www.example.com/three-x.png",
                               @"scale": @3 };
    self.imageSetDictionary = @{ @"imageSet": @[ self.oneXDictionary, self.twoXDictionary, self.threeXDictionary ]};
    self.imageSet = [[VTemplateImageSet alloc] initWithJSON:self.imageSetDictionary];
}

- (void)testImageSetJSON
{
    XCTAssert([VTemplateImageSet isImageSetJSON:self.imageSetDictionary]);
}

- (void)testInvalidImageSet
{
    NSDictionary *invalidSet = @{ @"mo money": @"mo problems" };
    XCTAssertFalse([VTemplateImageSet isImageSetJSON:invalidSet]);
}

- (void)testAllImageURLs
{
    NSSet *imageURLs = [self.imageSet allImageURLs];
    XCTAssert([imageURLs containsObject:[NSURL URLWithString:@"http://www.example.com/one-x.png"]]);
    XCTAssert([imageURLs containsObject:[NSURL URLWithString:@"http://www.example.com/two-x.png"]]);
    XCTAssert([imageURLs containsObject:[NSURL URLWithString:@"http://www.example.com/three-x.png"]]);
}

- (void)testOneXScale
{
    VTemplateImage *expected = [[VTemplateImage alloc] initWithJSON:self.oneXDictionary];
    VTemplateImage *actual = [self.imageSet imageForScreenScale:1.0f];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testTwoXScale
{
    VTemplateImage *expected = [[VTemplateImage alloc] initWithJSON:self.twoXDictionary];
    VTemplateImage *actual = [self.imageSet imageForScreenScale:2.0f];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testOnePointFiveXScale
{
    VTemplateImage *expected = [[VTemplateImage alloc] initWithJSON:self.twoXDictionary];
    VTemplateImage *actual = [self.imageSet imageForScreenScale:1.5f];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testThreeXScale
{
    VTemplateImage *expected = [[VTemplateImage alloc] initWithJSON:self.threeXDictionary];
    VTemplateImage *actual = [self.imageSet imageForScreenScale:3.0f];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testFourXScale
{
    VTemplateImage *expected = [[VTemplateImage alloc] initWithJSON:self.threeXDictionary];
    VTemplateImage *actual = [self.imageSet imageForScreenScale:4.0f];
    XCTAssertEqualObjects(expected, actual);
}

@end
