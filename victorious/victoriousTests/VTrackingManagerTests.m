//
//  VTrackingManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "VTrackingManager.h"

@interface VTrackingManager (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *registeredMacros;

- (NSString *)stringFromString:(NSString *)originalString byReplacingString:(NSString *)stringToReplace withValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (NSString *)stringByReplacingMacros:(NSArray *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters;
- (void)sendRequestWithUrlString:(NSString *)url;
- (NSString *)percentEncodedUrlString:(NSString *)originalUrl;

@end


@interface VTrackingManagerTests : XCTestCase

@property (nonatomic, strong) VTrackingManager *trackingManager;

@end

@implementation VTrackingManagerTests

- (void)setUp
{
    [super setUp];
    
    self.trackingManager = [[VTrackingManager alloc] init];
    id myObjectMock = OCMPartialMock( self.trackingManager  );
    OCMStub( [myObjectMock sendRequestWithUrlString:[OCMArg any]] );
    self.trackingManager = (VTrackingManager *)myObjectMock;
    
    XCTAssertNotNil( self.trackingManager.registeredMacros );
    XCTAssertNotEqual( self.trackingManager.registeredMacros.count, (NSUInteger)0 );
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTrackEvents
{
    NSArray *urls = @[ @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 0 );
    
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );
    
    urls = @[ [NSNull null], @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 1 );
    
    urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 2 );
}

- (void)testTrackEvent
{
    XCTAssert( [self.trackingManager trackEventWithUrl:@"http://www.google.com" andParameters:nil] );
    XCTAssert( [self.trackingManager trackEventWithUrl:@"http://www.google.com" andParameters:@{}] );
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    NSString *macro1 = @"%%macro1%%";
    NSString *macro2 = @"%%macro2%%";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testTrackEventValuesInvalid
{
    NSString *macro1 = @"%%macro1%%";
    NSString *macro2 = @"%%macro2%%";
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @3 , macro2 : @6 };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : [NSDate date] , macro2 : [NSDate date] };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @5.0f , macro2 : @10.0f };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testMacroReplacement
{
    NSString *macro1 = self.trackingManager.registeredMacros[0];
    NSString *macro2 = self.trackingManager.registeredMacros[1];
    NSString *macro3 = @"%%unregistered_macro%%";
    NSString *string = [NSString stringWithFormat:@"%@/%@/%@", macro1, macro2, macro3 ];
    
    NSString *output;
    NSString *expected;
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2", macro3 : @"value3" };
    output = [self.trackingManager stringByReplacingMacros:self.trackingManager.registeredMacros inString:string withCorrspondingParameters:parameters];
    expected = [string stringByReplacingOccurrencesOfString:macro1 withString:parameters[ macro1 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro2 withString:parameters[ macro2 ]];
    XCTAssertEqualObjects( output, expected, @"URL should only have registerd macros replaced." );
}

- (void)testStringFromString
{
    NSString *macro = @"%%macro%%";
    NSString *url = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    NSString *stringValue = @"__stringValue__";
    NSNumber *integerValue = @1;
    NSNumber *floatValue = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:stringValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:stringValue];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:integerValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", integerValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:floatValue];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%@", floatValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:dateValue];
    NSString *dateString = [self.trackingManager.dateFormatter stringFromDate:dateValue ];
    dateString = [self.trackingManager percentEncodedUrlString:dateString];
    expected = [url stringByReplacingOccurrencesOfString:macro withString:dateString];
    XCTAssertEqualObjects( output, expected );
}

- (void)testUrlStringFromUrlStringNoChangeToUrl
{
    NSString *macro = @"%%macro%%";
    NSString *url;
    NSString *output;

    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.trackingManager stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro not present in URL shoudl leave URL unchanged." );
    
    url = @"http://www.example.com/";
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL without macros should leave URL unchanged." );
    
    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.trackingManager stringFromString:url byReplacingString:@"some_other_macro" withValue:@"valid_value"];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL with the wrong macro should leave URL unchanged." );
}

- (void)testUrlStringFromUrlStringErrors
{
    NSString *macro = @"%%macro%%";
    NSString *urlWithMacro = [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    
    XCTAssertNil( [self.trackingManager stringFromString:urlWithMacro byReplacingString:macro withValue:@""] );
    XCTAssertNil( [self.trackingManager stringFromString:urlWithMacro byReplacingString:macro withValue:nil] );
    XCTAssertNil( [self.trackingManager stringFromString:urlWithMacro byReplacingString:macro withValue:[NSObject new]] );
    
    XCTAssertThrows( [self.trackingManager stringFromString:@"" byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [self.trackingManager stringFromString:(NSString *)[NSObject new] byReplacingString:macro withValue:@"valid_value"] );
    XCTAssertThrows( [self.trackingManager stringFromString:nil byReplacingString:macro withValue:@"valid_value"] );
}

@end
