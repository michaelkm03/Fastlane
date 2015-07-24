//
//  VBundleWriterDataCacheTests.m
//  victorious
//
//  Created by Josh Hinman on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VDataCacheID.h"
#import "VBundleWriterDataCache.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VBundleWriterDataCacheTests : XCTestCase

@property (nonatomic, strong) VBundleWriterDataCache *dataCache;
@property (nonatomic, strong) NSURL *temporaryPath;

@end

@implementation VBundleWriterDataCacheTests

- (void)setUp
{
    [super setUp];
    
    NSString *temporary = NSTemporaryDirectory();
    temporary = [temporary stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSURL *temporaryURL = [NSURL fileURLWithPath:temporary];
    [[NSFileManager defaultManager] createDirectoryAtURL:temporaryURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.dataCache = [[VBundleWriterDataCache alloc] initWithBundleURL:[NSURL fileURLWithPath:temporary]];
}

- (void)testCacheData
{
    uint8_t bytes[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSData *data = [NSData dataWithBytes:bytes length:10];
    NSURL *expectedPath = [[self.dataCache.bundleURL URLByAppendingPathComponent:identifier] URLByAppendingPathExtension:VDataCacheBundleResourceExtension];
    
    XCTAssert( [self.dataCache cacheData:data forID:identifier error:nil] );
    NSData *dataOut = [NSData dataWithContentsOfURL:expectedPath];
    
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
    
    XCTAssert( [self.dataCache cacheDataAtURL:[NSURL fileURLWithPath:tempFile] forID:identifier error:nil] );
    
    NSURL *expectedPath = [[self.dataCache.bundleURL URLByAppendingPathComponent:identifier] URLByAppendingPathExtension:VDataCacheBundleResourceExtension];
    
    NSData *dataOut = [NSData dataWithContentsOfURL:expectedPath];
    XCTAssertEqualObjects(data, dataOut);
}

@end
