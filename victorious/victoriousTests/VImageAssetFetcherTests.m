//
//  VImageAssetFetcherTests.m
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VImageAsset+Fetcher.h"
#import "VDummyModels.h"
#import "NSArray+VMap.h"

@interface VImageAssetFetcherTests : XCTestCase

@property (nonatomic, strong) NSSet *testImageAssets;
@property (nonatomic, strong) NSArray *ascendingImageAssetsByArea;

@end

@implementation VImageAssetFetcherTests

- (void)setUp
{
    [super setUp];
    
    NSArray *imageAssets = [VDummyModels objectsWithEntityName:@"ImageAsset" subclass:[VImageAsset class] count:10];
    for ( NSInteger i = 0; i < (NSInteger)imageAssets.count; i++ )
    {
        VImageAsset *imageAsset = imageAssets[i];
        imageAsset.width = @((i+1) * 10);
        imageAsset.height = @((i+1) * 20);
    }
    
    self.testImageAssets = [NSSet setWithArray:imageAssets];
    self.ascendingImageAssetsByArea = [VImageAsset arrayAscendingByAreaFromAssets:self.testImageAssets];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testLargest
{
    NSInteger numAssets = (NSInteger)self.testImageAssets.count;
    VImageAsset *imageAsset = [VImageAsset largestAssetFromAssets:self.testImageAssets];
    XCTAssertEqual( imageAsset.width.integerValue, numAssets * 10 );
    XCTAssertEqual( imageAsset.height.integerValue, numAssets * 20 );
}

- (void)testSmallest
{
    VImageAsset *imageAsset = [VImageAsset smallestAssetFromAssets:self.testImageAssets];
    XCTAssertEqual( imageAsset.width.integerValue, 10 );
    XCTAssertEqual( imageAsset.height.integerValue, 20 );
}

- (void)testMinSize
{
    CGSize minSize;
    VImageAsset *imageAsset;
    NSInteger indexOfAsset;
    VImageAsset *nextImageAsset;
    
    minSize = CGSizeMake( 30, 30 );
    imageAsset = [VImageAsset assetWithPreferredMinimumSize:minSize fromAssets:self.testImageAssets];
    XCTAssertGreaterThanOrEqual( imageAsset.width.floatValue, minSize.width );
    XCTAssertGreaterThanOrEqual( imageAsset.height.floatValue, minSize.height );
    
    indexOfAsset = [self.ascendingImageAssetsByArea indexOfObject:imageAsset];
    nextImageAsset = self.ascendingImageAssetsByArea[ indexOfAsset + 1 ];
    XCTAssertLessThan( imageAsset.width.floatValue, nextImageAsset.width.floatValue );
    XCTAssertLessThan( imageAsset.height.floatValue, nextImageAsset.height.floatValue );
    
    minSize = CGSizeMake( 50, 80 );
    imageAsset = [VImageAsset assetWithPreferredMinimumSize:minSize fromAssets:self.testImageAssets];
    XCTAssertGreaterThanOrEqual( imageAsset.width.floatValue, minSize.width );
    XCTAssertGreaterThanOrEqual( imageAsset.height.floatValue, minSize.height );
    
    indexOfAsset = [self.ascendingImageAssetsByArea indexOfObject:imageAsset];
    nextImageAsset = self.ascendingImageAssetsByArea[ indexOfAsset + 1 ];
    XCTAssertLessThan( imageAsset.width.floatValue, nextImageAsset.width.floatValue );
    XCTAssertLessThan( imageAsset.height.floatValue, nextImageAsset.height.floatValue );
    
    minSize = CGSizeMake( 10000, 10000 ); // Larger than any assets in the set
    imageAsset = [VImageAsset assetWithPreferredMinimumSize:minSize fromAssets:self.testImageAssets];
    VImageAsset *largestAsset = [VImageAsset largestAssetFromAssets:self.testImageAssets];
    XCTAssertEqualObjects( imageAsset, largestAsset );
}

- (void)testMaxSize
{
    CGSize maxSize;
    VImageAsset *imageAsset;
    NSInteger indexOfAsset;
    VImageAsset *previousImageAsset;
    
    maxSize = CGSizeMake( 50, 80 );
    imageAsset = [VImageAsset assetWithPreferredMaximumSize:maxSize fromAssets:self.testImageAssets];
    XCTAssertLessThanOrEqual( imageAsset.width.floatValue, maxSize.width );
    XCTAssertLessThanOrEqual( imageAsset.height.floatValue, maxSize.height );
    
    indexOfAsset = [self.ascendingImageAssetsByArea indexOfObject:imageAsset];
    previousImageAsset = self.ascendingImageAssetsByArea[ indexOfAsset - 1 ];
    XCTAssertGreaterThan( imageAsset.width.floatValue, previousImageAsset.width.floatValue );
    XCTAssertGreaterThan( imageAsset.height.floatValue, previousImageAsset.height.floatValue );
    
    maxSize = CGSizeMake( 80, 100 );
    imageAsset = [VImageAsset assetWithPreferredMaximumSize:maxSize fromAssets:self.testImageAssets];
    XCTAssertLessThanOrEqual( imageAsset.width.floatValue, maxSize.width );
    XCTAssertLessThanOrEqual( imageAsset.height.floatValue, maxSize.height );
    
    indexOfAsset = [self.ascendingImageAssetsByArea indexOfObject:imageAsset];
    previousImageAsset = self.ascendingImageAssetsByArea[ indexOfAsset - 1 ];
    XCTAssertGreaterThan( imageAsset.width.floatValue, previousImageAsset.width.floatValue );
    XCTAssertGreaterThan( imageAsset.height.floatValue, previousImageAsset.height.floatValue );
    
    maxSize = CGSizeMake( 1, 2 ); // Smaller than any assets in the set
    imageAsset = [VImageAsset assetWithPreferredMaximumSize:maxSize fromAssets:self.testImageAssets];
    VImageAsset *smallestAsset = [VImageAsset smallestAssetFromAssets:self.testImageAssets];
    XCTAssertEqualObjects( imageAsset, smallestAsset );
}

@end
