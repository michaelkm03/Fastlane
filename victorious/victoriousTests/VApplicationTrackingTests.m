//
//  VApplicationTrackingTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VApplicationTracking.h"
#import "VTrackingURLRequest.h"
#import "VObjectManager.h"
#import "VObjectManager+Private.h"

@interface VApplicationTracking (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *parameterMacroMapping;

- (NSString *)stringFromString:(NSString *)originalString byReplacingString:(NSString *)stringToReplace withValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (NSString *)stringByReplacingMacros:(NSDictionary *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters;
- (void)sendRequest:(NSURLRequest *)request;
- (VObjectManager *)applicationObjectManager;
- (NSString *)percentEncodedUrlString:(NSString *)originalUrl;

@end


@interface VApplicationTrackingTests : XCTestCase

@property (nonatomic, strong) VApplicationTracking *applicaitonTracking;
@property (nonatomic, assign) IMP sendRequestImp;
@property (nonatomic, assign) IMP applicationObjectManagerImp;

@end

@implementation VApplicationTrackingTests

- (void)setUp
{
    [super setUp];
    
    self.applicationObjectManagerImp = [VApplicationTracking v_swizzleMethod:@selector(applicationObjectManager)
                                                                withBlock:(VObjectManager *)^
                                     {
                                         return [[VObjectManager alloc] init];
                                     }];
    
    self.sendRequestImp = [VApplicationTracking v_swizzleMethod:@selector(sendRequest:)
                                                                withBlock:^(NSURLRequest *request)
                                     {}];
    
    self.applicaitonTracking = [[VApplicationTracking alloc] init];
    
    XCTAssertNotNil( self.applicaitonTracking.parameterMacroMapping );
    XCTAssertNotEqual( self.applicaitonTracking.parameterMacroMapping.allKeys.count, (NSUInteger)0 );
}

- (void)tearDown
{
    [super tearDown];
    
    [VApplicationTracking v_restoreOriginalImplementation:self.applicationObjectManagerImp forMethod:@selector(applicationObjectManager)];
    [VApplicationTracking v_restoreOriginalImplementation:self.sendRequestImp forMethod:@selector(sendRequest:)];
}

- (void)testTrackEvents
{
    NSArray *urls = @[ @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:urls andParameters:nil], 0 );
    
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );
    
    urls = @[ [NSNull null], @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:urls andParameters:nil], 1 );
    
    urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [self.applicaitonTracking trackEventWithUrls:urls andParameters:nil], 2 );
}

- (void)testTrackEvent
{
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:@"http://www.google.com" andParameters:nil] );
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:@"http://www.google.com" andParameters:@{}] );
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [self.applicaitonTracking trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [self.applicaitonTracking trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [self.applicaitonTracking trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    NSString *macro1 = self.applicaitonTracking.parameterMacroMapping.allKeys[0];
    NSString *macro2 = self.applicaitonTracking.parameterMacroMapping.allKeys[1];
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testTrackEventValuesInvalid
{
    NSString *macro1 = self.applicaitonTracking.parameterMacroMapping.allKeys[0];
    NSString *macro2 = self.applicaitonTracking.parameterMacroMapping.allKeys[1];
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @3 , macro2 : @6 };
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : [NSDate date] , macro2 : [NSDate date] };
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @5.0f , macro2 : @10.0f };
    XCTAssert( [self.applicaitonTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testMacroReplacement
{
    NSString *macro1 = self.applicaitonTracking.parameterMacroMapping.allValues[0];
    NSString *macro2 = self.applicaitonTracking.parameterMacroMapping.allValues[1];
    NSString *macro3 = @"%%unregistered_macro%%";
    NSString *string = [NSString stringWithFormat:@"%@/%@/%@", macro1, macro2, macro3 ];
    
    NSString *output;
    NSString *expected;
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2", macro3 : @"value3" };
    output = [self.applicaitonTracking stringByReplacingMacros:self.applicaitonTracking.parameterMacroMapping inString:string withCorrspondingParameters:parameters];
    expected = [string stringByReplacingOccurrencesOfString:macro1 withString:parameters[ macro1 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro2 withString:parameters[ macro2 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro3 withString:@""];
    XCTAssertEqualObjects( output, expected, @"URL should only have registerd macros replaced, otherwise the macros should be removed." );
}

- (void)testStringFromString
{
    NSString *macro = @"%%macro%%";
    NSString *url = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    NSString *stringValue = @"__stringValue__";
    NSNumber *integerNumber = @1;
    NSNumber *floatNumber = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [self.applicaitonTracking stringFromString:url byReplacingString:macro withValue:stringValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:stringValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicaitonTracking stringFromString:url byReplacingString:macro withValue:integerNumber];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%i", integerNumber.intValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicaitonTracking stringFromString:url byReplacingString:macro withValue:floatNumber];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%.2f", floatNumber.floatValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.applicaitonTracking stringFromString:url byReplacingString:macro withValue:dateValue];
    NSString *dateString = [self.applicaitonTracking.dateFormatter stringFromDate:dateValue ];
    dateString = [self.applicaitonTracking percentEncodedUrlString:dateString];
    expected = [url stringByReplacingOccurrencesOfString:macro withString:dateString];
    XCTAssertEqualObjects( output, expected );
}

- (void)testUrlStringFromUrlStringNoChangeToUrl
{
    NSString *macro = @"%%macro%%";
    NSString *url;
    NSString *output;

    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.applicaitonTracking stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro not present in URL shoudl leave URL unchanged." );
    
    url = @"http://www.example.com/";
    output = [self.applicaitonTracking stringFromString:url byReplacingString:macro withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL without macros should leave URL unchanged." );
    
    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.applicaitonTracking stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL with the wrong macro should leave URL unchanged." );
}

- (void)testUrlStringFromUrlStringErrors
{
    NSString *macro = @"%%macro%%";
    NSString *urlWithMacro = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    
    XCTAssertNil( [self.applicaitonTracking stringFromString:urlWithMacro byReplacingString:macro withValue:@""] );
    XCTAssertNil( [self.applicaitonTracking stringFromString:urlWithMacro byReplacingString:macro withValue:nil] );
    XCTAssertNil( [self.applicaitonTracking stringFromString:urlWithMacro byReplacingString:macro withValue:[NSObject new]] );
    
    XCTAssertThrows( [self.applicaitonTracking stringFromString:@"" byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [self.applicaitonTracking stringFromString:(NSString *)[NSObject new] byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [self.applicaitonTracking stringFromString:nil byReplacingString:macro withValue:@"valid_value"] );
}

@end
