//
//  VHistogramDataSourceTests.m
//  victorious
//
//  Created by Michael Sena on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VHistogramDataSource.h"
#import "VHistogramView.h"

@interface VHistogramDataSourceTests : XCTestCase

@property (nonatomic, strong) VHistogramDataSource *histogramDataSource;

@end

@implementation VHistogramDataSourceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.histogramDataSource = [[VHistogramDataSource alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProtocolConformance
{
    XCTAssert([[[VHistogramDataSource alloc] init] conformsToProtocol:@protocol(VHistogramDataSource)], @"Pass");
    XCTAssertNoThrow([self.histogramDataSource histogramPercentageHeight:nil
                                                            forSliceIndex:0
                                                              totalSlices:0]);
}

- (void)testBadData
{
    XCTAssertThrows( [[VHistogramDataSource alloc] initWithDataPoints:@[@"badString"]] );
    NSArray *input = @[@-3];
    XCTAssertThrows( [[VHistogramDataSource alloc] initWithDataPoints:input] );
}

@end
