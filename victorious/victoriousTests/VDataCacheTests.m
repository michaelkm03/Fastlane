//
//  VDataCacheTests.m
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VDataCacheID.h"
#import "VDataCache.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VDataCacheTests : XCTestCase

@property (nonatomic, strong) VDataCache *dataCache1;
@property (nonatomic, strong) VDataCache *dataCache2;

@end

@implementation VDataCacheTests

- (void)setUp
{
    [super setUp];
    self.dataCache1 = [[VDataCache alloc] init];
    self.dataCache2 = [[VDataCache alloc] init];
    
    NSURL *localCachePath = [self temporaryDirectory];
    self.dataCache1.localCachePath = localCachePath;
    self.dataCache2.localCachePath = localCachePath;
}

- (NSURL *)temporaryDirectory
{
    NSString *subdirectory = [[NSUUID UUID] UUIDString];
    return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:subdirectory isDirectory:YES];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDefaultLocalCachePath
{
    XCTAssertNotNil( [[VDataCache alloc] init].localCachePath );
}

- (void)testSavingAndRetrievingData
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    NSData *dataOut = [self.dataCache2 cachedDataForID:identifier];
    
    XCTAssertEqualObjects(data, dataOut);
}

- (void)testBackupAttributeAppliedToCacheDirectory
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    
    NSDictionary *dict = [self.dataCache1.localCachePath resourceValuesForKeys:@[NSURLIsExcludedFromBackupKey] error:nil];
    XCTAssertEqualObjects( dict[NSURLIsExcludedFromBackupKey], @YES );
}

- (void)testHasCachedData
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    XCTAssert( [self.dataCache2 hasCachedDataForID:identifier] );
}

- (void)testHasNoCachedData
{
    NSString *identifier = [[NSUUID UUID] UUIDString];
    XCTAssertFalse( [self.dataCache2 hasCachedDataForID:identifier] );
    XCTAssertNil( [self.dataCache2 cachedDataForID:identifier] );
}

- (void)testHasSomeCachedDataButNotThisCachedData
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    
    NSString *otherIdentifier = [[NSUUID UUID] UUIDString];
    
    XCTAssertFalse( [self.dataCache2 hasCachedDataForID:[[NSUUID UUID] UUIDString]] );
    XCTAssertNil( [self.dataCache2 cachedDataForID:otherIdentifier] );
}

@end
