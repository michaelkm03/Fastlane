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
#import "VHistogramBarView.h"

static const CGFloat kHistogramDataSourceAccuracy = 0.01f;

@interface VHistogramDataSourceTests : XCTestCase

@property (nonatomic, strong) VHistogramBarView *histogramBarView;
@property (nonatomic, strong) VHistogramDataSource *histogramDataSource;

@end

@implementation VHistogramDataSourceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@1]];
    self.histogramBarView = [[VHistogramBarView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProtocolConformance
{
    XCTAssert([[VHistogramDataSource histogramDataSourceWithDataPoints:@[@1]] conformsToProtocol:@protocol(VHistogramBarViewDataSource)], @"Pass");
    XCTAssertNoThrow([self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                             forBarIndex:0
                                                               totalBars:1]);
}

- (void)testBadData
{
    XCTAssertThrows( [VHistogramDataSource histogramDataSourceWithDataPoints:@[]]);
    XCTAssertThrows( [VHistogramDataSource histogramDataSourceWithDataPoints:@[@"badString"]] );
    NSArray *input = @[@-3];
    XCTAssertThrows( [VHistogramDataSource histogramDataSourceWithDataPoints:input] );
}

- (void)testGoodData
{
    NSArray *goodData = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
    XCTAssertNoThrow( [VHistogramDataSource histogramDataSourceWithDataPoints:goodData] );
}

- (void)testOneDataPoint
{
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@1]];
    CGFloat oneHundredPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                              forBarIndex:0
                                                                                totalBars:1];
    XCTAssert( (oneHundredPercentHeight == 1.0f), @"%f should be 1.0f", oneHundredPercentHeight);
    
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@999]];
    oneHundredPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                      forBarIndex:0
                                                                        totalBars:1];
    XCTAssert( (oneHundredPercentHeight == 1.0f), @"%f should be 1.0f", oneHundredPercentHeight);
}

- (void)testTwoDataPoints
{
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@1, @2]];
    CGFloat fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                         forBarIndex:0
                                                                           totalBars:2];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    CGFloat oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                             forBarIndex:1
                                                                               totalBars:2];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
}

- (void)testFewerDataPointsThanBars
{
    CGFloat fiftyPercentHeight;
    CGFloat oneHunderPercentHeight;
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@1, @2]];
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:0
                                                                   totalBars:4];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:1
                                                                   totalBars:4];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:2
                                                                   totalBars:4];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
    oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:3
                                                                       totalBars:4];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
    
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:0
                                                                   totalBars:3];
    XCTAssert( (fiftyPercentHeight == 0.5f) );

    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:0
                                                                   totalBars:3];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                             forBarIndex:1
                                                               totalBars:3];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    
    oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:2
                                                                       totalBars:3];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
    
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:0
                                                                   totalBars:5];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:1
                                                                   totalBars:5];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    
    fiftyPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                 forBarIndex:2
                                                                   totalBars:5];
    XCTAssert( (fiftyPercentHeight == 0.5f) );
    
    oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:3
                                                                       totalBars:5];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
    
    oneHunderPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:4
                                                                       totalBars:5];
    XCTAssert( (oneHunderPercentHeight == 1.0f) );
    
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:@[@1, @2, @3, @2, @1]];
    CGFloat beginningPoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:0
                                                                       totalBars:10];
    XCTAssertEqualWithAccuracy(beginningPoint, 0.33, kHistogramDataSourceAccuracy);
    CGFloat middlePoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                  forBarIndex:5
                                                                    totalBars:10];
    XCTAssert( (middlePoint == 1.0f), @"%f", middlePoint );
    CGFloat endPoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                               forBarIndex:9
                                                                 totalBars:10];
    XCTAssertEqualWithAccuracy(endPoint, 0.33, kHistogramDataSourceAccuracy);
    
}

- (void)testMoreDataPointsThanBars
{
    // Hitogram data source should average data sources if we have more data points than bars
    NSArray *dataPoints = @[@1, @2, @3];
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:dataPoints];
    CGFloat average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                              forBarIndex:0
                                                                totalBars:1];
    XCTAssertEqualWithAccuracy(average, 0.66, kHistogramDataSourceAccuracy);

    dataPoints = @[@1, @1, @2, @2];
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:dataPoints];
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:0
                                                        totalBars:2];
    XCTAssertEqualWithAccuracy(average, 0.5f, kHistogramDataSourceAccuracy);
    
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:1
                                                        totalBars:2];
    XCTAssertEqualWithAccuracy(average, 1.0f, kHistogramDataSourceAccuracy);

    dataPoints = @[@0, @100,@1,@1];
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:dataPoints];
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:0
                                                        totalBars:2];
    XCTAssert( average == 0.5f );
    
    dataPoints = @[@0, @0, @100, @0, @0, @0, @0, @0, @0];
    self.histogramDataSource = [VHistogramDataSource histogramDataSourceWithDataPoints:dataPoints];
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:0
                                                        totalBars:3];
    XCTAssertEqualWithAccuracy(average, 0.33f, kHistogramDataSourceAccuracy);
}

@end

