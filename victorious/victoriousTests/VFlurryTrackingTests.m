//
//  VFlurryTrackingTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VFlurryTracking.h"

// Set in AppSpecific/Info.plist
static NSString * const kDevDefaultAPIKey = @"XXXXXXXXXX";

@interface VFlurryTracking(UnitTests)

@property (nonatomic, readonly) NSString *appVersionString;
@property (nonatomic, readonly) NSString *apiKey;

- (NSDictionary *)filteredDictionaryExcludingKeys:(NSArray *)keysToExclude fromDictionary:(NSDictionary *)dictionary;

@end

@interface VFlurryTrackingTests : XCTestCase

@property (nonatomic, strong) VFlurryTracking *flurryTracking;
@property (nonatomic, strong) NSDictionary *paramsDictionary;
@property (nonatomic, strong) NSArray *unwantedKeys;

@end

@implementation VFlurryTrackingTests

- (void)setUp
{
    [super setUp];
    
    self.flurryTracking = [[VFlurryTracking alloc] init];
    
    self.paramsDictionary = @{ @"param1" : @"value1",
                               @"param2" : @"value2",
                               @"param3" : @"value3",
                               @"param4" : @"value4",
                               @"param6" : @"value5" };
    
    self.unwantedKeys = @[ @"param2", @"param4" ];
    
    XCTAssert( self.flurryTracking.enabled );
}

- (void)testInfoPlistData
{
    NSString *apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlurryAPIKey"];
    XCTAssertNotNil( self.flurryTracking.apiKey );
    XCTAssertEqualObjects( self.flurryTracking.apiKey, apiKey );
    XCTAssertEqualObjects( self.flurryTracking.apiKey, kDevDefaultAPIKey );
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionString = [NSString stringWithFormat:@"%@ (%@)", version, build];
    XCTAssertEqualObjects( self.flurryTracking.appVersionString, versionString );
}

- (void)testFilteredDictionary
{
    NSDictionary *filtered = [self.flurryTracking filteredDictionaryExcludingKeys:self.unwantedKeys
                                                                   fromDictionary:self.paramsDictionary];
    
    XCTAssertEqualObjects( filtered[ @"param1" ], self.paramsDictionary[ @"param1" ] );
    XCTAssertNil( filtered[ @"param2" ] );
    XCTAssertEqualObjects( filtered[ @"param3" ], self.paramsDictionary[ @"param3" ] );
    XCTAssertNil( filtered[ @"param4" ] );
    XCTAssertEqualObjects( filtered[ @"param5" ], self.paramsDictionary[ @"param5" ] );
}

- (void)testFilteredDictionaryNoKeys
{
    NSDictionary *filtered;
    
    filtered = [self.flurryTracking filteredDictionaryExcludingKeys:nil
                                                     fromDictionary:self.paramsDictionary];
    XCTAssertEqualObjects( self.paramsDictionary, filtered );
    
    filtered = [self.flurryTracking filteredDictionaryExcludingKeys:@[]
                                                     fromDictionary:self.paramsDictionary];
    XCTAssertEqualObjects( self.paramsDictionary, filtered );
    
    filtered = [self.flurryTracking filteredDictionaryExcludingKeys:self.unwantedKeys
                                                     fromDictionary:nil];
    XCTAssertNil( filtered );
    
    filtered = [self.flurryTracking filteredDictionaryExcludingKeys:self.unwantedKeys
                                                     fromDictionary:@{}];
    XCTAssertEqual( filtered.count, (NSUInteger)0 );
}

@end
