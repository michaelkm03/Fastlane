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

@end

@interface VFlurryTrackingTests : XCTestCase

@property (nonatomic, strong) VFlurryTracking *flurryTracking;

@end

@implementation VFlurryTrackingTests

- (void)setUp
{
    [super setUp];
    
    self.flurryTracking = [[VFlurryTracking alloc] init];
    
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

@end
