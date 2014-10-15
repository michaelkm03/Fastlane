//
//  VFileCacheTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFileCache.h"
#import "VAsyncTestHelper.h"
#import "VFileSystemTestHelpers.h"

static NSString * const kTestingPathRoot = @"file_cache_tests";
static NSString * const kTestingFileUrl = @"http://www.google.com/";


// Simply exposes private methods and prpperties
@interface VFileCache (UnitTest)

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath;
- (NSString *)getCachesDirectoryPathForPath:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path;

@end

@interface VFileCacheTests : XCTestCase
{
    VFileCache *_fileCache;
    VAsyncTestHelper *_asyncHelper;
}

@end

@implementation VFileCacheTests

- (void)setUp
{
    [super setUp];
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _fileCache = [[VFileCache alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    XCTAssert( [VFileSystemTestHelpers deleteCachesDirectory:kTestingPathRoot], @"Error deleting contents created by last test." );
}

/**
 Writes a file synchronously to prevent many nested asynchronous blocks for testing.
 */
- (void)writeFileSynchronousWithKeyPath:(NSString *)keyPath
{
    NSString *fullPath = [_fileCache getCachesDirectoryPathForPath:keyPath];
    [_fileCache createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]];
    XCTAssert( [_fileCache saveFile:kTestingFileUrl toPath:fullPath] );
}

- (void)testSaveFile
{
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    XCTAssert( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:keyPath] );
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:keyPath];
    }];
}

- (void)testSaveMultipleFiles
{
    NSString *localPath = [NSString stringWithFormat:@"%@/test_files", kTestingPathRoot];
    NSUInteger testFilesCount = 10;
    for ( NSUInteger i = 0; i < testFilesCount; i++ )
    {
        NSString *keyPath = [NSString stringWithFormat:@"%@/multi_file_%lu.html", localPath, (unsigned long)i];
        XCTAssert( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:keyPath] );
    }
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers numberOfFilesAtPath:localPath] == testFilesCount;
    }];
}

- (void)testGetFileSynchronous
{
    // Synchronously save the file using exposed private methods
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    [self writeFileSynchronousWithKeyPath:keyPath];
    
    NSData *fileLoaded = [_fileCache getCachedFileForKeyPath:keyPath];
    XCTAssertNotNil( fileLoaded );
    XCTAssert( [fileLoaded isKindOfClass:[NSData class]] );
}

- (void)testGetFileAsynchronous
{
    // Synchronously save the file using exposed private methods
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    [self writeFileSynchronousWithKeyPath:keyPath];
    
    __block NSData *fileData = nil;
    BOOL result = [_fileCache getCachedFileForKeyPath:keyPath completeCallback:^(NSData *data) {
        fileData = data;
    }];
    XCTAssert( result );
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        BOOL didFileLoad = fileData != nil;
        if ( didFileLoad )
        {
            XCTAssert( [fileData isKindOfClass:[NSData class]] );
        }
        return didFileLoad;
    }];
}

@end
