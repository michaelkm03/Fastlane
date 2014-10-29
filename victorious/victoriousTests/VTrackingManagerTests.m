//
//  VTrackingManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VAsyncTestHelper.h"
#import "VObjectManager.h"
#import "NSObject+VMethodSwizzling.h"

#import <Nocilla/Nocilla.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#undef andReturn // to make Nocilla play well with OCMock
#undef andDo


static NSString * const kTestingUrl = @"http://www.example.com/";


@interface VObjectManager ()

- (void)updateHTTPHeadersInRequest:(NSMutableURLRequest *)request;

@end

@interface VTrackingManager (UnitTest)

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *registeredMacros;

- (NSString *)stringFromString:(NSString *)originalString byReplacingString:(NSString *)stringToReplace withValue:(id)value;
- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters;
- (NSString *)stringByReplacingMacros:(NSArray *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters;
- (void)sendRequestWithUrlString:(NSString *)url;
- (NSURLRequest *)requestWithUrl:(NSString *)url objectManager:(VObjectManager *)objectManager;
- (NSString *)percentEncodedUrlString:(NSString *)originalUrl;

@end


@interface VTrackingManagerTests : XCTestCase


@property (nonatomic, strong) VAsyncTestHelper *async;
@property (nonatomic, strong) VTrackingManager *trackingManager;

@end

@implementation VTrackingManagerTests

- (void)setUp
{
    [super setUp];
    
    [[LSNocilla sharedInstance] start];
    
    self.trackingManager = [[VTrackingManager alloc] init];
    self.async = [[VAsyncTestHelper alloc] init];
    
    XCTAssertNotNil( self.trackingManager.registeredMacros );
    XCTAssertNotEqual( self.trackingManager.registeredMacros.count, (NSUInteger)0 );
}

- (void)tearDown
{
    [[LSNocilla sharedInstance] stop];
    
    [super tearDown];
}

- (void)testATrackEvents
{
    __block NSInteger responseCount = 0;
    NSArray *urls = @[ kTestingUrl, kTestingUrl, kTestingUrl, kTestingUrl ];
    
    stubRequest( @"GET", kTestingUrl ).andReturn( 200 );
    
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 0 );
    //[self.async waitForSignal:5.0f];
}

- (void)testTrackEventsInvalid
{
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:nil andParameters:nil], -1 );
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:@[] andParameters:nil], -1 );
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:(NSArray *)[NSObject new] andParameters:nil], -1 );
    
    NSArray *urls = @[ [NSNull null], [NSNull null] ];
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 2 );
}

- (void)testATrackEventsSomeValid
{
    __block NSInteger responseCount = 0;
    __block NSInteger expected = 0;
    NSArray *urls = @[ kTestingUrl, kTestingUrl, kTestingUrl, kTestingUrl ];
    
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                               NSInteger *status,
                                                               id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 *status = 200;
                                                                 if ( ++responseCount == expected )
                                                                 {
                                                                     [self.async signal];
                                                                 }
                                                             });
    
    urls = @[ [NSNull null], kTestingUrl, kTestingUrl, kTestingUrl ];
    expected = 3;
    XCTAssertEqual( [self.trackingManager trackEventWithUrls:urls andParameters:nil], 1 );
    //[self.async waitForSignal:5.0f];
}

- (void)testRequest
{
    NSURLRequest *request = [self.trackingManager requestWithUrl:kTestingUrl objectManager:[VObjectManager new]];
    XCTAssertNotNil( request );
    XCTAssertEqualObjects( request.URL.absoluteString, kTestingUrl );
    XCTAssertNotNil( [request valueForHTTPHeaderField:@"Authorization"] );
    XCTAssertNotNil( [request valueForHTTPHeaderField:@"User-Agent"] );
    XCTAssertNotNil( [request valueForHTTPHeaderField:@"Date"] );
    
    request = [self.trackingManager requestWithUrl:kTestingUrl objectManager:nil];
    XCTAssertNil( request );
}

- (void)testPercentEncode
{
    NSString *expected = @"2014%2D10%2D27%2019%3A57%3A30";
    NSString *unencoded = @"2014-10-27 19:57:30";
    XCTAssertEqualObjects( expected, [self.trackingManager percentEncodedUrlString:unencoded] );
    
    XCTAssertNil( [self.trackingManager percentEncodedUrlString:nil] );
}

- (void)testTrackEvent
{
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                       NSInteger *status,
                                                       id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 *status = 200;
                                                         [self.async signal];
                                                     });
    
    XCTAssert( [self.trackingManager trackEventWithUrl:kTestingUrl andParameters:nil] );
    //[self.async waitForSignal:5.0f];
}

- (void)testATrackEventNoParams
{
    stubRequest( @"GET", kTestingUrl ).withBody( nil ).andDo(^(NSDictionary * __autoreleasing *headers,
                                                               NSInteger *status,
                                                               id<LSHTTPBody> __autoreleasing *body)
                                                             {
                                                                 *status = 200;
                                                                 [self.async signal];
                                                             });
    XCTAssert( [self.trackingManager trackEventWithUrl:kTestingUrl andParameters:@{}] );
    //[self.async waitForSignal:5.0f];
}

- (void)testTrackEventNoValuesInvalid
{
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:@"" andParameters:nil] );
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:nil andParameters:nil] );
    XCTAssertFalse( [self.trackingManager trackEventWithUrl:(NSString *)[NSObject new] andParameters:nil] );
}

- (void)testTrackEventValues
{
    // Any of the registered tracking macros will work for this test
    NSString *macro1 = kTrackingKeyBallisticsCount;
    NSString *macro2 = kTrackingKeyNavigiationFrom;
    NSString *urlWithMacros = [NSString stringWithFormat:@"http://www.example.com/%@/%@", macro1, macro2];
    
    NSDictionary *parameters = @{ macro1 : @"value1" , macro2 : @"value2" };
    XCTAssert( [self.trackingManager trackEventWithUrl:urlWithMacros andParameters:parameters] );
}

- (void)testTrackEventParams
{
    NSString *macro1 = kTrackingKeyBallisticsCount;
    NSString *macro2 = kTrackingKeyNavigiationFrom;
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
    NSString *macro = kTrackingKeySequenceId;
    NSString *url = [NSString stringWithFormat:@
                     "http://www.example.com/%@", macro];
    NSString *string = @"__stringValue__";
    NSNumber *integeNumber = @1;
    NSNumber *floatNumber = @2.0f;
    NSDate *dateValue = [NSDate date];
    
    NSString *output;
    NSString *expected;
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:string];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:string];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:integeNumber];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%i", integeNumber.intValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:floatNumber];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:[NSString stringWithFormat:@"%.2f", floatNumber.floatValue]];
    XCTAssertEqualObjects( output, expected );
    
    output = [self.trackingManager stringFromString:url byReplacingString:macro withValue:dateValue];
    NSString *dateString = [self.trackingManager percentEncodedUrlString:[self.trackingManager.dateFormatter stringFromDate:dateValue ]];
    expected = [url stringByReplacingOccurrencesOfString:macro
                                              withString:dateString];
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
