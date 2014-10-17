//
//  VAnalyticsManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "VAnalyticsManager.h"

@interface VAnalyticsManager (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *registeredMacros;

- (NSString *)stringFromString:(NSString *)originalString byReplacingString:(NSString *)stringToReplace withValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (NSString *)stringByReplacingMacros:(NSArray *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters;

@end


@interface VAnalyticsManagerTests : XCTestCase
{
    VAnalyticsManager *_analyticsManager;
}

@end

@implementation VAnalyticsManagerTests

- (void)setUp
{
    [super setUp];
    
    _analyticsManager = [[VAnalyticsManager alloc] init];
    XCTAssertNotNil( _analyticsManager.registeredMacros );
    XCTAssertNotEqual( _analyticsManager.registeredMacros.count, (NSUInteger)0 );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTrackEvents
{
    NSArray *urls = @[ @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:urls andParameters:nil], 0 );
    
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );
    
    urls = @[ [NSNull null], @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:urls andParameters:nil], 1 );
    
    urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [_analyticsManager trackEventWithUrls:urls andParameters:nil], 2 );
}

- (void)testTrackEvent
{
    XCTAssert( [_analyticsManager trackEventWithUrl:@"http://www.google.com" andParameters:nil] );
    XCTAssert( [_analyticsManager trackEventWithUrl:@"http://www.google.com" andParameters:@{}] );
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [_analyticsManager trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [_analyticsManager trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [_analyticsManager trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    NSString *macro1 = @"__macro1__";
    NSString *macro2 = @"__macro2__";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [_analyticsManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testTrackEventValuesInvalid
{
    NSString *macro1 = @"__macro1__";
    NSString *macro2 = @"__macro2__";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [_analyticsManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @3 , macro2 : @6 };
    XCTAssert( [_analyticsManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : [NSDate date] , macro2 : [NSDate date] };
    XCTAssert( [_analyticsManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @5.0f , macro2 : @10.0f };
    XCTAssert( [_analyticsManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testMacroReplacement
{
    NSString *macro1 = _analyticsManager.registeredMacros[0];
    NSString *macro2 = _analyticsManager.registeredMacros[1];
    NSString *macro3 = @"unregistered_macro";
    NSString *string = [NSString stringWithFormat:@"%@/%@/%@", macro1, macro2, macro3 ];
    
    NSString *output;
    NSString *expected;
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2", macro3 : @"value3" };
    output = [_analyticsManager stringByReplacingMacros:_analyticsManager.registeredMacros inString:string withCorrspondingParameters:parameters];
    expected = [string stringByReplacingOccurrencesOfString:macro1 withString:parameters[ macro1 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro2 withString:parameters[ macro2 ]];
    XCTAssertEqualObjects( output, expected, @"URL should only have registerd macros replaced." );
}

- (void)testStringFromString
{
    NSString *macro = @"__macro__";
    NSString *url = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    NSString *stringValue = @"__stringValue__";
    NSNumber *integerValue = @1;
    NSNumber *floatValue = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [_analyticsManager stringFromString:url byReplacingString:macro withValue:stringValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:stringValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [_analyticsManager stringFromString:url byReplacingString:macro withValue:integerValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", integerValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [_analyticsManager stringFromString:url byReplacingString:macro withValue:floatValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", floatValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [_analyticsManager stringFromString:url byReplacingString:macro withValue:dateValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[_analyticsManager.dateFormatter stringFromDate:dateValue ]];
    XCTAssertEqualObjects( output, expected );
}

- (void)testUrlStringFromUrlStringNoChangeToUrl
{
    NSString *macro = @"__macro__";
    NSString *url;
    NSString *output;

    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [_analyticsManager stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro not present in URL shoudl leave URL unchanged." );
    
    url = @"http://www.example.com/";
    output = [_analyticsManager stringFromString:url byReplacingString:macro withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL without macros should leave URL unchanged." );
    
    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [_analyticsManager stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL with the wrong macro should leave URL unchanged." );
}

- (void)testUrlStringFromUrlStringErrors
{
    NSString *macro = @"__macro__";
    NSString *urlWithMacro = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    
    XCTAssertThrows( [_analyticsManager stringFromString:urlWithMacro byReplacingString:macro withValue:@""] );
    XCTAssertThrows( [_analyticsManager stringFromString:urlWithMacro byReplacingString:macro withValue:nil] );
    XCTAssertThrows( [_analyticsManager stringFromString:urlWithMacro byReplacingString:macro withValue:[NSObject new]] );
    
    XCTAssertThrows( [_analyticsManager stringFromString:@"" byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [_analyticsManager stringFromString:(NSString *)[NSObject new] byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [_analyticsManager stringFromString:nil byReplacingString:macro withValue:@"valid_value"] );
}

@end
