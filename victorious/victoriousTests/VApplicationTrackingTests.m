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
#import "VTrackingURLRequest.h"
#import "VObjectManager.h"
#import "VObjectManager+Private.h"
#import "VURLMacroReplacement.h"
#import "victorious-Swift.h"
#import "VObjectManager.h"
#import "VMockRequestScheduler.h"

@interface VApplicationTracking (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *parameterMacroMapping;
@property (nonatomic, assign) NSUInteger requestCounter;

- (NSString *)stringFromParameterValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (NSString *)stringByReplacingMacros:(NSDictionary *)macros inString:(NSString *)originalString withCorrespondingParameters:(NSDictionary *)parameters;
- (void)sendRequest:(NSURLRequest *)request;
- (VObjectManager *)applicationObjectManager;
- (void)sessionTimerDidResetSession:(VSessionTimer *)sessionTimer;

@end


@interface VApplicationTrackingTests : XCTestCase

@property (nonatomic, strong) VApplicationTracking *applicationTracking;
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
    
    self.applicationTracking = [[VApplicationTracking alloc] init];
    
    XCTAssertNotNil( self.applicationTracking.parameterMacroMapping );
    XCTAssertNotEqual( self.applicationTracking.parameterMacroMapping.allKeys.count, (NSUInteger)0 );
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown
{
    [VApplicationTracking v_restoreOriginalImplementation:self.applicationObjectManagerImp forMethod:@selector(applicationObjectManager)];
    [VApplicationTracking v_restoreOriginalImplementation:self.sendRequestImp forMethod:@selector(sendRequest:)];

    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [super tearDown];
}

- (void)testTrackEvents
{
    self.applicationTracking.requestQueue = dispatch_queue_create("VApplicationTrackingTests", DISPATCH_QUEUE_SERIAL);
    stubRequest(@"GET", @"http://www.apple.com").andReturn(200);
    stubRequest(@"GET", @"http://www.yahoo.com").andReturn(200);
    stubRequest(@"GET", @"http://www.google.com").andReturn(200);
    
    NSArray *urls = @[ @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 0 );
    
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );
    
    urls = @[ [NSNull null], @"http://www.apple.com", @"http://www.yahoo.com", @"http://www.google.com" ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 1 );
    
    urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [self.applicationTracking trackEventWithUrls:urls andParameters:nil], 2 );
    
    dispatch_sync(self.applicationTracking.requestQueue, ^{ }); // wait for tracking calls to finish!
}

- (void)testTrackEvent
{
    self.applicationTracking.requestQueue = dispatch_queue_create("VApplicationTrackingTests", DISPATCH_QUEUE_SERIAL);
    stubRequest(@"GET", @"http://www.google.com").andReturn(200);
    
    XCTAssert( [self.applicationTracking trackEventWithUrl:@"http://www.google.com" andParameters:nil] );
    XCTAssert( [self.applicationTracking trackEventWithUrl:@"http://www.google.com" andParameters:@{}] );
    
    dispatch_sync(self.applicationTracking.requestQueue, ^{ }); // wait for tracking calls to finish!
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [self.applicationTracking trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    NSString *macro1 = self.applicationTracking.parameterMacroMapping.allKeys[0];
    NSString *macro2 = self.applicationTracking.parameterMacroMapping.allKeys[1];
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testTrackEventValuesInvalid
{
    NSString *macro1 = self.applicationTracking.parameterMacroMapping.allKeys[0];
    NSString *macro2 = self.applicationTracking.parameterMacroMapping.allKeys[1];
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters;
    
    parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @3 , macro2 : @6 };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : [NSDate date] , macro2 : [NSDate date] };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
    
    parameters = @{ macro1 : @5.0f , macro2 : @10.0f };
    XCTAssert( [self.applicationTracking trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testMacroReplacement
{
    NSString *macro1 = self.applicationTracking.parameterMacroMapping.allValues[0];
    NSString *macro2 = self.applicationTracking.parameterMacroMapping.allValues[1];
    NSString *macro3 = self.applicationTracking.parameterMacroMapping.allValues[2];
    NSString *macro4 = @"%%BRAND_NEW_UNKNOWN_MACRO%%";
    NSString *macro5 = @"%%ANOTER NEW ONE%%";
    
    NSString *paramKey1 = self.applicationTracking.parameterMacroMapping.allKeys[0];
    NSString *paramKey3 = self.applicationTracking.parameterMacroMapping.allKeys[2];
    
    NSString *string = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", macro1, macro2, macro3, macro4, macro5 ];
    
    NSString *output;
    NSString *expected;
    NSDictionary *parameters;
    
    parameters = @{ paramKey1 : @"value1",
                    // macro2 is missing intentionally to test the removal of the macro
                    paramKey3 : @"value3"
                    // macro4 is missing intentionally to test the removal of the macro
                    };
    
    output = [self.applicationTracking stringByReplacingMacros:self.applicationTracking.parameterMacroMapping
                                                      inString:string
                                    withCorrespondingParameters:parameters];
    expected = [string stringByReplacingOccurrencesOfString:macro1 withString:parameters[ paramKey1 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro2 withString:@""];
    expected = [expected stringByReplacingOccurrencesOfString:macro3 withString:parameters[ paramKey3 ]];
    expected = [expected stringByReplacingOccurrencesOfString:macro4 withString:@""];
    expected = [expected stringByReplacingOccurrencesOfString:macro5 withString:@""];
    XCTAssertEqualObjects( output, expected, @"URL should only have registerd macros replaced, otherwise the macros should be removed." );
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

- (void)testUrlStringFromUrlStringNoChangeToUrl
{
    NSString *macro = @"%%macro%%";
    NSString *url;
    NSString *output;

    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.applicationTracking stringByReplacingMacros:self.applicationTracking.parameterMacroMapping
                                                      inString:url
                                   withCorrespondingParameters:@{ @"some_other_macro": @"valid_value" }];
    NSString *expected = @"http://www.example.com/";
    XCTAssertEqualObjects( output, expected, @"Attempting to replace a macro not present in URL should leave URL unchanged." );
    
    url = @"http://www.example.com/";
    output = [self.applicationTracking stringByReplacingMacros:self.applicationTracking.parameterMacroMapping
                                                      inString:url
                                   withCorrespondingParameters:@{ @"some_other_macro": @"valid_value" }];
    XCTAssertEqualObjects( output, url, @"Attempting to replace a macro in a URL without macros should leave URL unchanged." );
    
    url =  [NSString stringWithFormat:@"http://www.example.com/%@", macro];
    output = [self.applicationTracking stringByReplacingMacros:self.applicationTracking.parameterMacroMapping
                                                      inString:url
                                   withCorrespondingParameters:@{ @"some_other_macro": @"valid_value" }];
    expected = @"http://www.example.com/";
    XCTAssertEqualObjects( output, expected, @"Attempting to replace a macro in a URL with the wrong macro should leave URL unchanged." );
}

- (void)testOrderAndSessionReset
{
    NSDictionary *params = @{ VTrackingKeyUrls : @[ @"http://www.google.com?order=%%REQUEST_ORDER%%"] };
    
    VMockRequestScheduler *mockRequestScheduler = [[VMockRequestScheduler alloc] init];
    
    for ( NSInteger i = 0; i < 10; i++ )
    {
        [self.applicationTracking trackEventWithName:@"some_event" parameters:params];
        for ( NSInteger j = 0; j <= i; j++ )
        {
            NSURLRequest *request = mockRequestScheduler.requestsScheduled[i];
            NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(i+1)];
            XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
        }
    }
    
    [self.applicationTracking sessionTimerDidResetSession:nil];
    
    for ( NSInteger i = 0; i < 10; i++ )
    {
        [self.applicationTracking trackEventWithName:@"some_event" parameters:params];
        for ( NSInteger j = 0; j <= i; j++ )
        {
            NSURLRequest *request = mockRequestScheduler.requestsScheduled[i];
            NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(i+1)];
            XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
        }
    }
}

- (void)testOrderStartIndexAndReset
{
    NSDictionary *params = @{ VTrackingKeyUrls : @[ @"http://www.google.com?order=%%REQUEST_ORDER%%"] };
    
    VMockRequestScheduler *mockRequestScheduler = [[VMockRequestScheduler alloc] init];
    
    [self.applicationTracking trackEventWithName:@"some_event" parameters:params];
    {
        NSURLRequest *request = mockRequestScheduler.requestsScheduled[0];
        NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(1)];
        XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
    }
    
    self.applicationTracking.requestCounter = NSUIntegerMax;
    [self.applicationTracking trackEventWithName:@"some_event" parameters:params];
    {
        NSURLRequest *request = mockRequestScheduler.requestsScheduled[1];
        NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(1)];
        XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
    }
}

- (void)testOnlyIncrementOrderWhenMacroIsPresent
{
    NSDictionary *paramsWithMacro = @{ VTrackingKeyUrls : @[ @"http://www.google.com?order=%%REQUEST_ORDER%%"] };
    NSDictionary *paramsWithoutMacro = @{ VTrackingKeyUrls : @[ @"http://www.google.com" ] };
    
    VMockRequestScheduler *mockRequestScheduler = [[VMockRequestScheduler alloc] init];
    
    [self.applicationTracking trackEventWithName:@"some_event" parameters:paramsWithMacro];
    {
        NSURLRequest *request = mockRequestScheduler.requestsScheduled[0];
        NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(1)];
        XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
    }
    
    // Track another event in between to ensure that counter is not incremented
    [self.applicationTracking trackEventWithName:@"some_event" parameters:paramsWithoutMacro];
    
    [self.applicationTracking trackEventWithName:@"some_event" parameters:paramsWithMacro];
    {
        NSURLRequest *request = mockRequestScheduler.requestsScheduled[2];
        NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(2)];
        XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
    }
    
    // Track another event in between to ensure that counter is not incremented
    [self.applicationTracking trackEventWithName:@"some_event" parameters:paramsWithoutMacro];
    
    [self.applicationTracking trackEventWithName:@"some_event" parameters:paramsWithMacro];
    {
        NSURLRequest *request = mockRequestScheduler.requestsScheduled[4];
        NSString *expectedURL = [NSString stringWithFormat:@"http://www.google.com?order=%@", @(3)];
        XCTAssertEqualObjects( request.URL.absoluteString, expectedURL );
    }
}

@end
