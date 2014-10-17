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
#import "NSObject+VMethodSwizzling.h"

static NSString * const kTestingPathRoot = @"file_cache_tests";
static NSString * const kTestingFileUrl = @"http://www.google.com/";

#pragma mark - Category exposing public methods

@interface VFileCache (UnitTest)

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwite;
- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwrite withNumRetries:(NSUInteger)withNumRetries;
- (NSString *)getCachesDirectoryPathForPath:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path;
- (BOOL)downloadAndWriteFile:(NSString *)urlString toPath:(NSString *)filepath;

@end

#pragma mark - Subclass with some test-specific functionality added

@interface VFileCacheSubclass : VFileCache

@property (nonatomic, assign) BOOL downloadAndWriteWasCalled;

@end

#pragma mark - Test cases

@implementation VFileCacheSubclass

- (BOOL)downloadAndWriteFile:(NSString *)fileUrl toPath:(NSString *)filepath
{
    self.downloadAndWriteWasCalled = YES;
    return [super downloadAndWriteFile:fileUrl toPath:filepath];
}

@end

@interface VFileCacheTests : XCTestCase
{
    VFileCache *_fileCache;
    VAsyncTestHelper *_asyncHelper;
    IMP _originalImplementation;
}

@end

@implementation VFileCacheTests

- (void)setUp
{
    [super setUp];
    
    [VFileSystemTestHelpers deleteCachesDirectory:kTestingPathRoot];
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _fileCache = [[VFileCacheSubclass alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

/**
 Writes a file synchronously to prevent many nested asynchronous blocks for testing.
 */
- (void)writeFileSynchronousWithKeyPath:(NSString *)keyPath
{
    NSString *fullPath = [_fileCache getCachesDirectoryPathForPath:keyPath];
    [_fileCache createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]];
    XCTAssert( [_fileCache saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:YES] );
}

- (void)testSaveFile
{
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/single_file.html", kTestingPathRoot];
    XCTAssert( [_fileCache cacheFileAtUrl:kTestingFileUrl withKeyPath:keyPath shouldOverwrite:YES] );
    
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
    
    XCTAssert( [_fileCache cacheFilesAtUrls:urls withKeyPaths:keyPaths shouldOverwrite:YES] );
    
    // If this fails occasionally, check your network settings or adjust the wait duration
    [_asyncHelper waitForSignal:20.0f withSignalBlock:^BOOL{
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

- (void)testOverwrite
{
    VFileCacheSubclass *fcs = (VFileCacheSubclass *)_fileCache;
    
    NSString *keyPath = [NSString stringWithFormat:@"%@/test_files/file_overwrite.html", kTestingPathRoot];
    NSString *fullPath = [_fileCache getCachesDirectoryPathForPath:keyPath];
    [fcs createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]];
    
    fcs.downloadAndWriteWasCalled = NO;
    XCTAssert( [fcs saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:YES] );
    XCTAssert( fcs.downloadAndWriteWasCalled );
    
    fcs.downloadAndWriteWasCalled = NO; // set to NO and test that it stays NO, i.e. 'downloadAndWriteFile:toPath:' is not called
    XCTAssert( [fcs saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:NO] );
    XCTAssertFalse( fcs.downloadAndWriteWasCalled );
    
    fcs.downloadAndWriteWasCalled = NO;
    XCTAssert( [fcs saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:YES] );
    XCTAssert( fcs.downloadAndWriteWasCalled );
}

- (void)testRetries
{
    __block NSUInteger attempt = 0;
    IMP implementation = [VFileCache v_swizzleMethod:@selector(saveFile:toPath:shouldOverwrite:) withBlock:^BOOL (NSString *fileUrl, NSString *filePath, BOOL shouldOverwrite )
                          {
                              BOOL shouldSucceed = attempt >= 3;
                              attempt++;
                              return shouldSucceed;
                          }];
    
    XCTAssertFalse( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:0] );
    XCTAssertFalse( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:1] );
    XCTAssertFalse( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:2] );
    XCTAssert( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:3] );
    XCTAssert( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:4] );
    XCTAssert( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:5] );
    
    [VFileCache v_restoreOriginalImplementation:implementation forMethod:@selector(saveFile:toPath:shouldOverwrite:)];
}

- (void)testRetriesNone
{
    IMP implementation = [VFileCache v_swizzleMethod:@selector(saveFile:toPath:shouldOverwrite:) withBlock:^BOOL (NSString *fileUrl, NSString *filePath, BOOL shouldOverwrite )
                          {
                              return YES;
                          }];
    
    XCTAssert( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:0] );
    
    [VFileCache v_restoreOriginalImplementation:implementation forMethod:@selector(saveFile:toPath:shouldOverwrite:)];
}

- (void)testRetriesMax
{
    __block NSUInteger attempt = 0;
    IMP implementation = [VFileCache v_swizzleMethod:@selector(saveFile:toPath:shouldOverwrite:) withBlock:^BOOL (NSString *fileUrl, NSString *filePath, BOOL shouldOverwrite )
                          {
                              return ++attempt > VFileCacheMaximumSaveFileRetries;
                          }];
    
    NSUInteger retries = VFileCacheMaximumSaveFileRetries * 2;
    XCTAssertFalse( [_fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:retries] );
    
    [VFileCache v_restoreOriginalImplementation:implementation forMethod:@selector(saveFile:toPath:shouldOverwrite:)];
}

@end
