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
    XCTAssertEqualObjects( self.flurryTracking.apiKey, apiKey );
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionString = [NSString stringWithFormat:@"%@ (%@)", version, build];
    XCTAssertEqualObjects( self.flurryTracking.appVersionString, versionString );
}

#if TARGET_IPHONE_SIMULATOR

- (void)testAppAPIKeys
{
    // See the run script build phase of the test target for how project directorty is read
    NSString *projectDir = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"ProjectDir"];
    XCTAssertNotNil( projectDir );
    projectDir = [projectDir stringByDeletingLastPathComponent];
    
    NSString *filepathFormat = [projectDir stringByAppendingPathComponent:@"configurations/%@/Info.plist"];
    NSDictionary *expectedKeys = @{@"pwnisher"          : @"D2FNJ87GGV4VBQRN57WY",
                                   @"JessLizama"        : @"BHDG4TJTJ7HBZJJQQNQ7",
                                   @"GTChannel"         : @"6X35D8W7BJY4KRF8NNWK",
                                   @"EatYourKimchi"     : @"YB44YS7TR59PT4WXKD5C",
                                   @"GlamLifeGuru"      : @"XTJ4RY2KVKC3KKD9P7GH",
                                   @"iVictorious"       : @"R5NWJQXKV594N4ZBBQB2" };
    
    __block NSUInteger checkedCount = 0;
    [expectedKeys enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop)
     {
         NSString *filepath = [NSString stringWithFormat:filepathFormat, key];
         NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:filepath];
         
         NSString *apiKey = info[ @"FlurryAPIKey" ];
         XCTAssertNotNil( apiKey );
         XCTAssertEqualObjects( value, apiKey );
         checkedCount++;
    }];
    
    XCTAssertNotEqual( checkedCount, (NSUInteger)0 );
    XCTAssertEqual( checkedCount, expectedKeys.count );
}

#endif

@end
