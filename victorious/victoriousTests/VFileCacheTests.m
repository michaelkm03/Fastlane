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

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwite;
- (NSString *)getCachesDirectoryPathForPath:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path;

@end

@interface VFileCacheTests : XCTestCase
{
    VFileCache *_fileCache;
    VAsyncTestHelper *_asyncHelper;
    
    BOOL _wereFilesCreated;
}

@end

@implementation VFileCacheTests

- (void)setUp
{
    [super setUp];
    
    _wereFilesCreated = NO;
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _fileCache = [[VFileCache alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( _wereFilesCreated )
    {
        XCTAssert( [VFileSystemTestHelpers deleteCachesDirectory:kTestingPathRoot],
                  @"Error deleting contents created by last test." );
    }
}

/**
 Writes a file synchronously to prevent many nested asynchronous blocks for testing.
 */
- (void)writeFileSynchronousWithKeyPath:(NSString *)keyPath
{
    NSString *fullPath = [_fileCache getCachesDirectoryPathForPath:keyPath];
    [_fileCache createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]];
    XCTAssert( [_fileCache saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:YES] );
    
    _wereFilesCreated = YES;
}

- (void)testSaveFile
{
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    XCTAssert( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:keyPath] );
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:keyPath];
    }];
}

- (void)testSaveFileInvalid
{
    NSString *aKeyPath = @"keyPath";
    XCTAssertFalse( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:nil] );
    XCTAssertFalse( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:@""] );
    XCTAssertFalse( [_fileCache cacheFileAtUrl:nil withKeyPath:aKeyPath] );
    XCTAssertFalse( [_fileCache cacheFileAtUrl:@"" withKeyPath:aKeyPath] );
}

- (void)testSaveMultipleFiles
{
    NSString *localPath = [NSString stringWithFormat:@"%@/test_files", kTestingPathRoot];
    NSMutableArray *keyPaths = [[NSMutableArray alloc] init];
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSUInteger testFilesCount = 10;
    for ( NSUInteger i = 0; i < testFilesCount; i++ )
    {
        NSString *keyPath = [NSString stringWithFormat:@"%@/multi_file_%lu.html", localPath, (unsigned long)i];
        [keyPaths addObject:keyPath];
        [urls addObject: kTestingFileUrl];
    }
    
    XCTAssert( [_fileCache cacheFilesAtUrls:urls withKeyPaths:keyPaths] );
    
    // If this fails occasionally, check your network settings or adjust the wait duration
    [_asyncHelper waitForSignal:20.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers numberOfFilesAtPath:localPath] == testFilesCount;
    }];
    
    _wereFilesCreated = YES;
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

- (void)testGetFileSynchronousInvalidInput
{
    XCTAssertNil( [_fileCache getCachedFileForKeyPath:nil] );
    XCTAssertNil( [_fileCache getCachedFileForKeyPath:@""] );
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
    
    // If this fails occasionally, check your network settings or adjust the wait duration
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        BOOL didFileLoad = fileData != nil;
        if ( didFileLoad )
        {
            XCTAssert( [fileData isKindOfClass:[NSData class]] );
        }
        return didFileLoad;
    }];
}

- (void)testGetFileAsynchronousInvalidInput
{
    XCTAssertFalse( [_fileCache getCachedFileForKeyPath:@"some_key_path" completeCallback:nil] );
    XCTAssertFalse( [_fileCache getCachedFileForKeyPath:@"" completeCallback:nil] );
    XCTAssertFalse( [_fileCache getCachedFileForKeyPath:nil completeCallback:^(NSData *data) {}]);
}

- (void)testCoderBlocks
{
    __block BOOL encoderWasCalled = NO;
    _fileCache.encoderBlock = ^NSData *(NSData *data) {
        encoderWasCalled = YES;
        return data;
    };
    
    __block BOOL decoderWasCalled = NO;
    _fileCache.decoderBlock = ^id (NSData *data) {
        decoderWasCalled = YES;
        return data;
    };
    
    // Synchronously save the file using exposed private methods
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    [self writeFileSynchronousWithKeyPath:keyPath];
    XCTAssert( encoderWasCalled );
    
    // Synchronously load the file we just saved
    XCTAssertNotNil( [_fileCache getCachedFileForKeyPath:keyPath] );
    XCTAssert( decoderWasCalled );
}

@end
