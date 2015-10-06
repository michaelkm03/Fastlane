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

/**
 This should match the name of a file in the main application bundle with 
 an extension equal to the VDataCacheBundleResourceExtension constant.
 */
static NSString * const kDataCacheTestResourceName = @"VDataCacheTests";

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
    
    NSURL *localCacheURL = [self temporaryDirectory];
    self.dataCache1.localCacheURL = localCacheURL;
    self.dataCache2.localCacheURL = localCacheURL;
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

- (void)testDefaultlocalCacheURL
{
    XCTAssertNotNil( [[VDataCache alloc] init].localCacheURL );
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

- (void)testCacheFromFile
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [[NSFileManager defaultManager] createDirectoryAtPath:NSTemporaryDirectory() withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [data writeToFile:tempFile atomically:YES];
    NSString *identifier = [[NSUUID UUID] UUIDString];
    
    XCTAssert( [self.dataCache1 cacheDataAtURL:[NSURL fileURLWithPath:tempFile] forID:identifier error:nil] );

    NSData *dataOut = [self.dataCache2 cachedDataForID:identifier];
    XCTAssertEqualObjects(data, dataOut);
}

- (void)testCacheFromFileAgain
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    uint8_t moreBytes[] = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 };

    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *tempFile = [tempDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSString *anotherTempFile = [tempDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [data writeToFile:tempFile atomically:YES];
    NSString *identifier = [[NSUUID UUID] UUIDString];
    
    NSData *moreData = [NSData dataWithBytes:moreBytes length:10];
    [moreData writeToFile:anotherTempFile atomically:YES];
    
    XCTAssert( [self.dataCache1 cacheDataAtURL:[NSURL fileURLWithPath:tempFile] forID:identifier error:nil] );
    XCTAssert( [self.dataCache1 cacheDataAtURL:[NSURL fileURLWithPath:anotherTempFile] forID:identifier error:nil] );
    
    NSData *dataOut = [self.dataCache2 cachedDataForID:identifier];
    XCTAssertEqualObjects(moreData, dataOut);
}

- (void)testBackupAttributeAppliedToCacheDirectory
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    
    NSDictionary *dict = [self.dataCache1.localCacheURL resourceValuesForKeys:@[NSURLIsExcludedFromBackupKey] error:nil];
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

- (void)testApplicationBundleCaching
{
    XCTAssert( [self.dataCache1 hasCachedDataForID:kDataCacheTestResourceName] );
    
    NSURL *dataURL = [[NSBundle mainBundle] URLForResource:kDataCacheTestResourceName withExtension:VDataCacheBundleResourceExtension];
    
    NSData *expected = [NSData dataWithContentsOfURL:dataURL];
    XCTAssertNotNil(expected);
    
    NSData *actual = [self.dataCache1 cachedDataForID:kDataCacheTestResourceName];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDiskCacheOverridesAppBundle
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:kDataCacheTestResourceName error:nil] );
    NSData *dataOut = [self.dataCache2 cachedDataForID:kDataCacheTestResourceName];
    
    XCTAssertEqualObjects(data, dataOut);
}

- (void)testMissingSet
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    XCTAssert( [self.dataCache1 cacheData:data forID:identifier error:nil] );
    
    NSString *otherIdentifier = [[NSUUID UUID] UUIDString];
    
    NSSet *expected = [NSSet setWithObject:otherIdentifier];
    NSSet *actual = [self.dataCache1 setOfIDsWithoutCachedDataFromIDSet:[NSSet setWithObjects:identifier, otherIdentifier, nil]];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testDeleteCachedData
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    
    [self.dataCache1 cacheData:data forID:identifier error:nil];
    
    XCTAssert( [self.dataCache1 removeCachedDataForId:identifier error:nil] );
    XCTAssertNil( [self.dataCache1 cachedDataForID:identifier] );
}

@end
