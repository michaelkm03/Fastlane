//
//  VObjectManager_AnalyticsTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VObjectManager.h"
#import "VObjectManager+Analytics.h"

@interface VObjectManager (UnitTest)

+ (NSDateFormatter *)analyticsDateFormatter;
- (NSString *)urlStringFromUrlString:(NSString *)urlString byReplacingMacro:(NSString *)macro withValue:(id)value;

@end

@interface VObjectManager_AnalyticsTests : XCTestCase
{
    VObjectManager *_objectManager;
}

@end

@implementation VObjectManager_AnalyticsTests

- (void)setUp
{
    [super setUp];
    
    _objectManager = [[VObjectManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTrackEventNoValues
{
    XCTAssert( [_objectManager trackEventWithUrl:@"http://www.google.com"] );
    XCTAssert( [_objectManager trackEventWithUrl:@"http://www.google.com" andValues:nil] );
    XCTAssert( [_objectManager trackEventWithUrl:@"http://www.google.com" andValues:@{}] );
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [_objectManager trackEventWithUrl:@""] );
    XCTAssertFalse( [_objectManager trackEventWithUrl:nil] );
    XCTAssertFalse( [_objectManager trackEventWithUrl:(NSString *)[NSObject new]] );
}

- (void)testTrackEventValues
{
    NSString *macro1 = @"__macro1__";
    NSString *macro2 = @"__macro2__";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *dictionary = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [_objectManager trackEventWithUrl:urlWithMacros andValues:dictionary] );
}

- (void)testTrackEventValuesInvalid
{
    NSString *macro1 = @"__macro1__";
    NSString *macro2 = @"__macro2__";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *dictionary;
    
    dictionary = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [_objectManager trackEventWithUrl:urlWithMacros andValues:dictionary] );
    
    dictionary = @{ macro1 : @3 , macro2 : @6 };
    XCTAssert( [_objectManager trackEventWithUrl:urlWithMacros andValues:dictionary] );
    
    dictionary = @{ macro1 : [NSDate date] , macro2 : [NSDate date] };
    XCTAssert( [_objectManager trackEventWithUrl:urlWithMacros andValues:dictionary] );
    
    dictionary = @{ macro1 : @5.0f , macro2 : @10.0f };
    XCTAssert( [_objectManager trackEventWithUrl:urlWithMacros andValues:dictionary] );
}

- (void)testUrlStringFromUrlString
{
    NSString *macro = @"__macro__";
    NSString *url = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    NSString *stringValue = @"__stringValue__";
    NSNumber *integerValue = @1;
    NSNumber *floatValue = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:macro withValue:stringValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:stringValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:macro withValue:integerValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", integerValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:macro withValue:floatValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", floatValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:macro withValue:dateValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[[VObjectManager analyticsDateFormatter] stringFromDate:dateValue ]];
    XCTAssertEqualObjects( output, expected );
}

- (void)testUrlStringFromUrlStringNoChangeToUrl
{
    NSString *macro = @"__macro__";
    NSString *url;
    NSString *output;

    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro not present in URL shoudl leave URL unchanged." );
    
    url = @"http://www.example.com/";
    output = [_objectManager urlStringFromUrlString:url byReplacingMacro:macro withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL without macros should leave the URL unchanged." );
}

- (void)testUrlStringFromUrlStringErrors
{
    NSString *macro = @"__macro__";
    NSString *urlWithMacro = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    
    XCTAssertNil( [_objectManager urlStringFromUrlString:urlWithMacro byReplacingMacro:macro withValue:@""] );
    XCTAssertNil( [_objectManager urlStringFromUrlString:urlWithMacro byReplacingMacro:macro withValue:nil] );
    XCTAssertNil( [_objectManager urlStringFromUrlString:urlWithMacro byReplacingMacro:macro withValue:[NSObject new]] );
    
    XCTAssertNil( [_objectManager urlStringFromUrlString:@"" byReplacingMacro:macro withValue:@"valid_value"] );
    XCTAssertNil( [_objectManager urlStringFromUrlString:(NSString *)[NSObject new] byReplacingMacro:macro withValue:@"valid_value"] );
    XCTAssertNil( [_objectManager urlStringFromUrlString:nil byReplacingMacro:macro withValue:@"valid_value"] );
}

@end
