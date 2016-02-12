//
//  VApplicationTrackingTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Nocilla.h"
#import "NSObject+VMethodSwizzling.h"
#import "VApplicationTracking.h"
#import "VSDKURLMacroReplacement.h"
#import "victorious-Swift.h"
#import "VMockRequestRecorder.h"

@interface VApplicationTracking (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *parameterMacroMapping;
@property (nonatomic, assign) NSUInteger requestCounter;

- (NSString *)stringFromParameterValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (void)sessionTimerDidResetSession:(VSessionTimer *)sessionTimer;

@end


@interface VApplicationTrackingTests : XCTestCase

@property (nonatomic, strong) VApplicationTracking *applicationTracking;

@end

@implementation VApplicationTrackingTests

- (void)setUp
{
    [super setUp];
    
    self.applicationTracking = [[VApplicationTracking alloc] init];
    
    XCTAssertNotNil( self.applicationTracking.parameterMacroMapping );
    XCTAssertNotEqual( self.applicationTracking.parameterMacroMapping.allKeys.count, 0u );
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown
{
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [super tearDown];
}

- (void)testTrackEvents
{
    XCTestExpectation *apple = [self expectationWithDescription:@"apple"];
    XCTestExpectation *yahoo = [self expectationWithDescription:@"yahoo"];
    XCTestExpectation *google = [self expectationWithDescription:@"google"];
    
    stubRequest(@"GET", @"http://www.apple.com").withHeader(@"X-Client-Event-Index", @"1").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [apple fulfill];
    });
    stubRequest(@"GET", @"http://www.yahoo.com").withHeader(@"X-Client-Event-Index", @"2").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [yahoo fulfill];
    });
    stubRequest(@"GET", @"http://www.google.com").withHeader(@"X-Client-Event-Index", @"3").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [google fulfill];
    });
    
    NSArray *urls = @[ @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 0 );
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testInvalidURLs
{
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );

    NSArray *urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 2 );
}

- (void)testOneInvalidURL
{
    XCTestExpectation *apple = [self expectationWithDescription:@"apple"];
    XCTestExpectation *yahoo = [self expectationWithDescription:@"yahoo"];
    XCTestExpectation *google = [self expectationWithDescription:@"google"];
    
    stubRequest(@"GET", @"http://www.apple.com").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [apple fulfill];
    });
    stubRequest(@"GET", @"http://www.yahoo.com").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [yahoo fulfill];
    });
    stubRequest(@"GET", @"http://www.google.com").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [google fulfill];
    });
    
    NSArray *urls = @[ [NSNull null], @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 1 );
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testTrackEventWithNilParameters
{
    XCTestExpectation *exepectation = [self expectationWithDescription:@""];
    stubRequest(@"GET", @"http://www.google.com").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [exepectation fulfill];
    });
    
    XCTAssert( [self.applicationTracking trackEventWithUrl:@"http://www.google.com" andParameters:nil] );
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testTrackEventWithEmptyDictionaryForParameters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    stubRequest(@"GET", @"http://www.google.com").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [expectation fulfill];
    });
    
    XCTAssert( [self.applicationTracking trackEventWithUrl:@"http://www.google.com" andParameters:@{}] );
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    stubRequest(@"GET", @"http://www.example.com/value1/value2").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [expectation fulfill];
    });

    NSString *macro1 = self.applicationTracking.parameterMacroMapping.allKeys[0];
    NSString *macro2 = self.applicationTracking.parameterMacroMapping.allKeys[1];
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", self.applicationTracking.parameterMacroMapping[macro1], self.applicationTracking.parameterMacroMapping[macro2]];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testStringFromParameterValue
{
    NSString *stringValue = @"__stringValue__";
    NSNumber *integerNumber = @1;
    NSNumber *floatNumber = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [self.applicationTracking stringFromParameterValue:stringValue];
    expected = stringValue;
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicationTracking stringFromParameterValue:integerNumber];
    expected = [NSString stringWithFormat:@"%i", integerNumber.intValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicationTracking stringFromParameterValue:floatNumber];
    expected = [NSString stringWithFormat:@"%.2f", floatNumber.floatValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicationTracking stringFromParameterValue:dateValue];
    expected = [self.applicationTracking.dateFormatter stringFromDate:dateValue];
    XCTAssertEqualObjects( output, expected );
}

- (void)testOrderAndSessionReset
{
    XCTestExpectation *apple = [self expectationWithDescription:@"apple"];
    XCTestExpectation *yahoo = [self expectationWithDescription:@"yahoo"];
    stubRequest(@"GET", @"http://www.apple.com").withHeader(@"X-Client-Event-Index", @"1").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [apple fulfill];
    });
    stubRequest(@"GET", @"http://www.yahoo.com").withHeader(@"X-Client-Event-Index", @"1").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [yahoo fulfill];
    });
    
    [self.applicationTracking trackEventWithUrl:@"http://www.apple.com" andParameters:nil];
    [self.applicationTracking sessionTimerDidResetSession:nil];
    [self.applicationTracking trackEventWithUrl:@"http://www.yahoo.com" andParameters:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testOrderStartIndexAndReset
{
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    NSString *trackingURL = @"http://www.google.com";
    stubRequest(@"GET", @"http://www.google.com").withHeader(@"X-Client-Event-Index", @"1").andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [expectation fulfill];
    });
    
    self.applicationTracking.requestCounter = NSUIntegerMax;
    [self.applicationTracking trackEventWithUrl:trackingURL andParameters:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

@end
