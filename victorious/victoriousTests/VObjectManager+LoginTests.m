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
@property (nonatomic, strong) VObjectManager *objectManager;
@property (nonatomic, strong) VThemeManager *themeManager;

@end

@implementation VObjectManager_LoginTests

- (void)setUp
{
    [super setUp];
    
    self.settingsManager = [[VSettingManager alloc] init];
    self.objectManager = [[VObjectManager alloc] init];
    self.themeManager = [[VThemeManager alloc] init];
}

- (void)tearDown
{
    [super tearDown];
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
    [self.objectManager updateTheme:self.themeManager withResponsePayload:payload];
    XCTAssert( wasMethodCalled );
    
    [VThemeManager v_restoreOriginalImplementation:orig forMethod:@selector(setTheme:)];
}

- (void)testArrayFilter
{
    NSArray *output = nil;
    NSArray *input = nil;
    
    input = @[ @1, @2, [NSNull new], [[NSString alloc] init] ];
    output = [self.objectManager filteredArrayFromArray:input withObjectsOfClass:[NSNumber class]];
    XCTAssertEqual( output.count, (NSUInteger)2 );
    [output enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[NSNumber class]] );
    }];
    
    output = [self.objectManager filteredArrayFromArray:input withObjectsOfClass:[NSString class]];
    XCTAssertEqual( output.count, (NSUInteger)1 );
    [output enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[NSString class]] );
    }];
    
    output = [self.objectManager filteredArrayFromArray:input withObjectsOfClass:[NSDictionary class]];
    XCTAssertEqual( output.count, (NSUInteger)0, @"Should not return results for class not in input array." );
    
    XCTAssertThrows( [self.objectManager filteredArrayFromArray:input withObjectsOfClass:nil] );
    
    output = [self.objectManager filteredArrayFromArray:@[] withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
    
    output = [self.objectManager filteredArrayFromArray:nil withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
    
    output = [self.objectManager filteredArrayFromArray:(NSArray *)@{} withObjectsOfClass:[NSObject class]];
    XCTAssertEqual( output.count, (NSUInteger)0 );
}

@end
