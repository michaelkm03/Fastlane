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

- (void)testImageArray
{
    NSURL *imageBundleURL1 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"png"];
    NSData *imageData1 = [NSData dataWithContentsOfURL:imageBundleURL1];
    UIImage *expected1 = [UIImage imageWithData:imageData1];
    
    NSURL *imageBundleURL2 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage2" withExtension:@"png"];
    NSData *imageData2 = [NSData dataWithContentsOfURL:imageBundleURL2];
    UIImage *expected2 = [[UIImage alloc] initWithData:imageData2 scale:3.0f];
    
    VDataCache *dataCache = [[VDataCache alloc] init];
    NSError *error = nil;
    [dataCache cacheDataAtURL:imageBundleURL1 forID:[NSURL URLWithString:@"http://www.example.com/testImageArrayOne"] error:&error];
    XCTAssertNil(error);
    
    error = nil;
    [dataCache cacheDataAtURL:imageBundleURL2 forID:[NSURL URLWithString:@"http://www.example.com/testImageArrayTwo"] error:&error];
    XCTAssertNil(error);
    
    NSArray *actualArray = [self.dependencyManager arrayOfValuesOfType:[UIImage class] forKey:@"myBasicImageArray"];
    XCTAssertEqual(actualArray.count, 2u);
    XCTAssert( [actualArray[0] isKindOfClass:[UIImage class]] );
    XCTAssert( [actualArray[1] isKindOfClass:[UIImage class]] );
    XCTAssert( CGSizeEqualToSize([actualArray[0] size], expected1.size) );
    XCTAssert( CGSizeEqualToSize([actualArray[1] size], expected2.size) );
    XCTAssertEqual( [(UIImage *)actualArray[1] scale], 3.0f );
}

- (void)testArrayOfLiteralImages
{
    NSURL *imageBundleURL1 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"png"];
    NSData *imageData1 = [NSData dataWithContentsOfURL:imageBundleURL1];
    UIImage *image1 = [UIImage imageWithData:imageData1];
    
    NSURL *imageBundleURL2 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage2" withExtension:@"png"];
    NSData *imageData2 = [NSData dataWithContentsOfURL:imageBundleURL2];
    UIImage *image2 = [UIImage imageWithData:imageData2];
    
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager
                                                                                configuration:@{ @"myLiteralImages": @[ image1, image2] }
                                                            dictionaryOfClassesByTemplateName:nil];

    NSArray *images = [dependencyManager arrayOfValuesOfType:[UIImage class] forKey:@"myLiteralImages"];
    XCTAssertEqual(images.count, 2u);
    XCTAssertEqualObjects(image1, images[0]);
    XCTAssertEqualObjects(image2, images[1]);
}

- (void)testImageMacro
{
    NSURL *imageBundleURL1 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"png"];
    NSData *imageData1 = [NSData dataWithContentsOfURL:imageBundleURL1];
    UIImage *image1 = [[UIImage alloc] initWithData:imageData1 scale:2.0f];
    
    NSURL *imageBundleURL2 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage2" withExtension:@"png"];
    NSData *imageData2 = [NSData dataWithContentsOfURL:imageBundleURL2];
    UIImage *image2 = [[UIImage alloc] initWithData:imageData2 scale:2.0f];
    
    VDataCache *dataCache = [[VDataCache alloc] init];
    NSError *error = nil;
    [dataCache cacheDataAtURL:imageBundleURL1 forID:[NSURL URLWithString:@"http://www.example.com/e35b3a0f-9993-47c1-845a-1429c7e4c692/tomato_00000.png"] error:&error];
    XCTAssertNil(error);
    
    error = nil;
    [dataCache cacheDataAtURL:imageBundleURL2 forID:[NSURL URLWithString:@"http://www.example.com/e35b3a0f-9993-47c1-845a-1429c7e4c692/tomato_00001.png"] error:&error];
    XCTAssertNil(error);
    
    XCTAssert([self.dependencyManager hasArrayOfImagesForKey:@"macroImages"]);
    NSArray *images = [self.dependencyManager arrayOfImagesForKey:@"macroImages"];
    
    XCTAssertEqual(images.count, 2u);
    XCTAssert( [images[0] isKindOfClass:[UIImage class]] );
    XCTAssert( [images[1] isKindOfClass:[UIImage class]] );
    XCTAssert( CGSizeEqualToSize([images[0] size], image1.size) );
    XCTAssert( CGSizeEqualToSize([images[1] size], image2.size) );
    XCTAssertEqual( [(UIImage *)images[0] scale], 2.0f );
    XCTAssertEqual( [(UIImage *)images[1] scale], 2.0f );
}

- (void)testMissingArray
{
    XCTAssertFalse( [self.dependencyManager hasArrayOfImagesForKey:@"missingMacroImages"] );
}

- (void)testPartiallyMissingArray
{
    NSURL *imageBundleURL1 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"png"];
    NSURL *imageBundleURL2 = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage2" withExtension:@"png"];
    
    VDataCache *dataCache = [[VDataCache alloc] init];
    NSError *error = nil;
    [dataCache cacheDataAtURL:imageBundleURL1 forID:[NSURL URLWithString:@"http://www.example.com/c2baabc6-3648-4684-96bd-3637201c0ba3/sup_00000.png"] error:&error];
    XCTAssertNil(error);
    
    error = nil;
    [dataCache cacheDataAtURL:imageBundleURL2 forID:[NSURL URLWithString:@"http://www.example.com/c2baabc6-3648-4684-96bd-3637201c0ba3/sup_00001.png"] error:&error];
    XCTAssertNil(error);
    
    XCTAssertFalse( [self.dependencyManager hasArrayOfImagesForKey:@"partiallyMissing"] );
}

@end
