//
//  VObjectManager+LoginTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VDummyModels.h"
#import "VSettingManager.h"
#import "VTracking.h"
#import "VObjectManager+Login.h"
#import "VThemeManager.h"

@interface VObjectManager (UnitTests)

- (void)updateTheme:(VThemeManager *)themeManager withResponsePayload:(NSDictionary *)payload;
- (void)updateSettings:(VSettingManager *)settingsManager withResponsePayload:(NSDictionary *)payload;
- (void)updateSettings:(VSettingManager *)settingsManager withResultObjects:(NSArray *)resultObjects;
- (NSArray *)filteredArrayFromArray:(NSArray *)array withObjectsOfClass:(Class)class;

@end

@interface VObjectManager_LoginTests : XCTestCase

@property (nonatomic, strong) VSettingManager *settingsManager;
@property (nonatomic, strong) VObjectManager *obejctManager;
@property (nonatomic, strong) VThemeManager *themeManager;

@end

@implementation VObjectManager_LoginTests

- (void)setUp
{
    [super setUp];
    
    self.settingsManager = [[VSettingManager alloc] init];
    self.obejctManager = [[VObjectManager alloc] init];
    self.themeManager = [[VThemeManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testUpdateTracking
{
    VTracking *tracking1 = [VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
    VTracking *tracking2 = [VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:@[ tracking1 ]];
    XCTAssertNotNil( self.settingsManager.applicationTracking );
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:@[ tracking2, tracking1 ]];
    XCTAssertNotNil( self.settingsManager.applicationTracking );
    XCTAssertEqualObjects( self.settingsManager.applicationTracking, tracking2 );
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:@[ tracking1, [NSNull null], [NSObject new] ]];
    XCTAssertNotNil( self.settingsManager.applicationTracking );
    XCTAssertEqualObjects( self.settingsManager.applicationTracking, tracking1 );
}

- (void)testUpdateVoteTypes
{
    NSArray *resultObjects = [VDummyModels createVoteTypes:5];
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:resultObjects];
    XCTAssertNotNil( self.settingsManager.voteTypes );
    XCTAssertEqual( self.settingsManager.voteTypes.count, resultObjects.count );
}

- (void)testUpdateSettingsFilter
{
    NSArray *resultObjects = [VDummyModels createVoteTypes:5];
    NSArray *nonVoteTypes = @[ [NSString new], [NSNull new], [NSDictionary new] ];
    resultObjects = [resultObjects arrayByAddingObjectsFromArray:nonVoteTypes];
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:resultObjects];
    XCTAssertNotNil( self.settingsManager.voteTypes );
    XCTAssertEqual( self.settingsManager.voteTypes.count, resultObjects.count - nonVoteTypes.count );
}

- (void)testUpdateSettingsInvalid
{
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:@[]];
    XCTAssertNil( self.settingsManager.applicationTracking );
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:nil];
    XCTAssertNil( self.settingsManager.applicationTracking );
    
    [self.obejctManager updateSettings:self.settingsManager withResultObjects:(NSArray *)@{}];
    XCTAssertNil( self.settingsManager.applicationTracking );
}

- (void)testUpdateTheme
{
    NSString *value = @"test_value";
    NSString *key = @"test_key";
    
    __block BOOL wasMethodCalled = NO;
    IMP orig = [VThemeManager v_swizzleMethod:@selector(setTheme:) withBlock:^void (VThemeManager *themeManager, NSDictionary *dictionary)
                {
                    wasMethodCalled = YES;
                    XCTAssertEqualObjects( value, dictionary[ key ] );
                }];
    
    NSDictionary *payload = @{ @"appearance" : @{ key : value } };
    [self.obejctManager updateTheme:self.themeManager withResponsePayload:payload];
    XCTAssert( wasMethodCalled );
    
    [VThemeManager v_restoreOriginalImplementation:orig forMethod:@selector(setTheme:)];
}

- (void)testArrayFilter
{
    NSArray *output = nil;
    NSArray *input = nil;
    
    input = @[ @1, @2, [NSNull new], [[NSString alloc] init] ];
    output = [self.obejctManager filteredArrayFromArray:input withObjectsOfClass:[NSNumber class]];
    XCTAssertEqual( output.count, (NSUInteger)2 );
    [output enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[NSNumber class]] );
    }];
    
    output = [self.obejctManager filteredArrayFromArray:input withObjectsOfClass:[NSString class]];
    XCTAssertEqual( output.count, (NSUInteger)1 );
    [output enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[NSString class]] );
    }];
    
    output = [self.obejctManager filteredArrayFromArray:input withObjectsOfClass:[NSDictionary class]];
    XCTAssertEqual( output.count, (NSUInteger)0, @"Should not return results for class not in input array." );
    
    XCTAssertThrows( [self.obejctManager filteredArrayFromArray:input withObjectsOfClass:nil] );
    
    output = [self.obejctManager filteredArrayFromArray:@[] withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
    
    output = [self.obejctManager filteredArrayFromArray:nil withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
    
    output = [self.obejctManager filteredArrayFromArray:(NSArray *)@{} withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
}

@end
