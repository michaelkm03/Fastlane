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
    self.histogramDataSource = [[VHistogramDataSource alloc] init];
    self.histogramBarView = [[VHistogramBarView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// This isn't a perfect comparison function but will do for our purposes.
- (BOOL)compare:(CGFloat)firstPoint
  toSecondPoint:(CGFloat)secondPoint
   withAccuracy:(CGFloat)accuracy
{
    if (fabsf(firstPoint - secondPoint) < accuracy)
    {
        return YES;
    }
    return NO;
}

- (void)testProtocolConformance
{
    XCTAssert([[[VHistogramDataSource alloc] init] conformsToProtocol:@protocol(VHistogramBarViewDataSource)], @"Pass");
    XCTAssertNoThrow([self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                             forBarIndex:0
                                                               totalBars:1]);
}

- (void)testBadData
{
    XCTAssertThrows( [[VHistogramDataSource alloc] initWithDataPoints:@[]]);
    XCTAssertThrows( [[VHistogramDataSource alloc] initWithDataPoints:@[@"badString"]] );
    NSArray *input = @[@-3];
    XCTAssertThrows( [[VHistogramDataSource alloc] initWithDataPoints:input] );
}

- (void)testGoodData
{
    NSArray *goodData = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
    XCTAssertNoThrow( [[VHistogramDataSource alloc] initWithDataPoints:goodData] );
}

- (void)testOneDataPoint
{
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:@[@1]];
    CGFloat oneHundredPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                              forBarIndex:0
                                                                                totalBars:1];
    XCTAssert( (oneHundredPercentHeight == 1.0f), @"%f should be 1.0f", oneHundredPercentHeight);
    
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:@[@999]];
    oneHundredPercentHeight = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                      forBarIndex:0
                                                                        totalBars:1];
    XCTAssert( (oneHundredPercentHeight == 1.0f), @"%f should be 1.0f", oneHundredPercentHeight);
}

- (void)testTwoDataPoints
{
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:@[@1, @2]];
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
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:@[@1, @2]];
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
    
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:@[@1, @2, @3, @2, @1]];
    CGFloat beginningPoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                     forBarIndex:0
                                                                       totalBars:10];
    XCTAssert( [self compare:beginningPoint
               toSecondPoint:0.33
                withAccuracy:kHistogramDataSourceAccuracy] );
    CGFloat middlePoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                                  forBarIndex:5
                                                                    totalBars:10];
    XCTAssert( (middlePoint == 1.0f), @"%f", middlePoint );
    CGFloat endPoint = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                               forBarIndex:9
                                                                 totalBars:10];
    XCTAssert( [self compare:endPoint
               toSecondPoint:0.33
                withAccuracy:kHistogramDataSourceAccuracy] );
    
}

- (void)testMoreDataPointsThanBars
{
    // Hitogram data source should average data sources if we have more data points than bars
    NSArray *dataPoints = @[@1, @2, @3];
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:dataPoints];
    CGFloat average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                              forBarIndex:0
                                                                totalBars:1];
    XCTAssert( [self compare:average
               toSecondPoint:0.66
                withAccuracy:kHistogramDataSourceAccuracy], @"%f should equal 0.66f", average );
    
    dataPoints = @[@1, @1, @2, @2];
    self.histogramDataSource = [[VHistogramDataSource alloc] initWithDataPoints:dataPoints];
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:0
                                                        totalBars:2];
    XCTAssert( [self compare:average
               toSecondPoint:0.5f
                withAccuracy:kHistogramDataSourceAccuracy], @"%f should equal 0.5f", average );
    
    average = [self.histogramDataSource histogramPercentageHeight:self.histogramBarView
                                                      forBarIndex:1
                                                        totalBars:2];
    XCTAssert( [self compare:average
               toSecondPoint:1.0f
                withAccuracy:kHistogramDataSourceAccuracy], @"%f should equal 1.0f", average );
}

@end

