//
//  VFileCacheTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "VFileCache.h"
#import "VAsyncTestHelper.h"
#import "VFileSystemTestHelpers.h"
#import "NSObject+VMethodSwizzling.h"

static NSString * const kTestingPathRoot = @"fileself.cacheself.tests";
static NSString * const kTestingFileUrl = @"http://www.google.com/";

#pragma mark - Category exposing public methods

@interface VFileCache (UnitTest)

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwite;
- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwrite withNumRetries:(NSUInteger)withNumRetries;
- (NSString *)getCachesDirectoryPathForPath:(NSString *)path;
- (BOOL)createDirectoryAtPath:(NSString *)path;
- (BOOL)downloadAndWriteFile:(NSString *)urlString toPath:(NSString *)filepath;
- (NSData *)synchronousDataFromUrl:(NSString *)urlString;

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

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;
@property (nonatomic, assign) IMP originalImplementation;

@end

@implementation VFileCacheTests

- (void)setUp
{
    [super setUp];
    
    [VFileSystemTestHelpers deleteCachesDirectory:kTestingPathRoot];
    
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
    self.fileCache = [[VFileCacheSubclass alloc] init];
    
    self.originalImplementation = [VFileCache v_swizzleMethod:@selector(synchronousDataFromUrl:) withBlock:(NSData *)^(NSString *url)
                                   {
                                       NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                                       NSURL *previewImageFileURL = [bundle URLForResource:@"sampleImage" withExtension:@"png"];
                                       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:previewImageFileURL]];
                                       return UIImagePNGRepresentation( image );
                                   }];
}

- (void)tearDown
{
    [VFileCache v_restoreOriginalImplementation:self.originalImplementation forMethod:@selector(synchronousDataFromUrl:)];
    [super tearDown];
}

/**
 Writes a file synchronously to prevent many nested asynchronous blocks for testing.
 */
- (void)writeFileSynchronousWithSavePath:(NSString *)savePath
{
    NSString *fullPath = [self.fileCache getCachesDirectoryPathForPath:savePath];
    [self.fileCache createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]];
    XCTAssert( [self.fileCache saveFile:kTestingFileUrl toPath:fullPath shouldOverwrite:YES] );
}

- (void)testSaveFile
{
    NSString *savePath = [NSString stringWithFormat:@"%@/testself.files/singleself.file.html", kTestingPathRoot];
    XCTAssert( [self.fileCache cacheFileAtUrl:kTestingFileUrl withSavePath:savePath shouldOverwrite:YES] );
    
    [self.asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:savePath];
    }];
}

- (void)testSaveFileInvalid
{
    NSString *aSavePath = @"savePath";
    XCTAssertFalse( [self.fileCache cacheFileAtUrl:kTestingFileUrl withSavePath:nil] );
    XCTAssertFalse( [self.fileCache cacheFileAtUrl:kTestingFileUrl withSavePath:@""] );
    XCTAssertFalse( [self.fileCache cacheFileAtUrl:nil withSavePath:aSavePath] );
    XCTAssertFalse( [self.fileCache cacheFileAtUrl:@"" withSavePath:aSavePath] );
}

- (void)testSaveMultipleFiles
{
    NSString *localPath = [NSString stringWithFormat:@"%@/testself.files", kTestingPathRoot];
    NSMutableArray *savePaths = [[NSMutableArray alloc] init];
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSUInteger testFilesCount = 10;
    for ( NSUInteger i = 0; i < testFilesCount; i++ )
    {
        NSString *savePath = [NSString stringWithFormat:@"%@/multiself.fileself.%lu.html", localPath, (unsigned long)i];
        [savePaths addObject:savePath];
        [urls addObject: kTestingFileUrl];
    }
    
    XCTAssert( [self.fileCache cacheFilesAtUrls:urls withSavePaths:savePaths shouldOverwrite:YES] );
    
    // If this fails occasionally, check your network settings or adjust the wait duration
    [self.asyncHelper waitForSignal:20.0f withSignalBlock:^BOOL{
        return [VFileSystemTestHelpers numberOfFilesAtPath:localPath] == testFilesCount;
    }];
}

- (void)testGetFileSynchronous
{
    // Synchronously save the file using exposed private methods
    NSString *savePath = [NSString stringWithFormat:@"%@/testself.files/singleself.file.html", kTestingPathRoot];
    [self writeFileSynchronousWithSavePath:savePath];
    
    NSData *fileLoaded = [self.fileCache getCachedFileForSavePath:savePath];
    XCTAssertNotNil( fileLoaded );
    XCTAssert( [fileLoaded isKindOfClass:[NSData class]] );
}

- (void)testGetFileSynchronousInvalidInput
{
    XCTAssertNil( [self.fileCache getCachedFileForSavePath:nil] );
    XCTAssertNil( [self.fileCache getCachedFileForSavePath:@""] );
}

- (void)testGetFileAsynchronous
{
    // Synchronously save the file using exposed private methods
    NSString *savePath = [NSString stringWithFormat:@"%@/testself.files/singleself.file.html", kTestingPathRoot];
    [self writeFileSynchronousWithSavePath:savePath];
    
    __block NSData *fileData = nil;
    BOOL result = [self.fileCache getCachedFileForSavePath:savePath completeCallback:^(NSData *data) {
        fileData = data;
    }];
    XCTAssert( result );
    
    // If this fails occasionally, check your network settings or adjust the wait duration
    [self.asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
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
    XCTAssertFalse( [self.fileCache getCachedFileForSavePath:@"someself.keyself.path" completeCallback:nil] );
    XCTAssertFalse( [self.fileCache getCachedFileForSavePath:@"" completeCallback:nil] );
    XCTAssertFalse( [self.fileCache getCachedFileForSavePath:nil completeCallback:^(NSData *data) {}]);
}

- (void)testCoderBlocks
{
    __block BOOL encoderWasCalled = NO;
    self.fileCache.encoderBlock = ^NSData *(NSData *data) {
        encoderWasCalled = YES;
        return data;
    };
    
    __block BOOL decoderWasCalled = NO;
    self.fileCache.decoderBlock = ^id (NSData *data) {
        decoderWasCalled = YES;
        return data;
    };
    
    // Synchronously save the file using exposed private methods
    NSString *savePath = [NSString stringWithFormat:@"%@/testself.files/singleself.file.html", kTestingPathRoot];
    [self writeFileSynchronousWithSavePath:savePath];
    XCTAssert( encoderWasCalled );
    
    // Synchronously load the file we just saved
    XCTAssertNotNil( [self.fileCache getCachedFileForSavePath:savePath] );
    XCTAssert( decoderWasCalled );
}

- (void)testOverwrite
{
    VFileCacheSubclass *fcs = (VFileCacheSubclass *)self.fileCache;
    
    NSString *savePath = [NSString stringWithFormat:@"%@/testself.files/fileself.overwrite.html", kTestingPathRoot];
    NSString *fullPath = [self.fileCache getCachesDirectoryPathForPath:savePath];
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
    
    XCTAssertFalse( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:0] );
    XCTAssertFalse( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:1] );
    XCTAssertFalse( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:2] );
    XCTAssert( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:3] );
    XCTAssert( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:4] );
    XCTAssert( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:5] );
    
    [VFileCache v_restoreOriginalImplementation:implementation forMethod:@selector(saveFile:toPath:shouldOverwrite:)];
}

- (void)testRetriesNone
{
    IMP implementation = [VFileCache v_swizzleMethod:@selector(saveFile:toPath:shouldOverwrite:) withBlock:^BOOL (NSString *fileUrl, NSString *filePath, BOOL shouldOverwrite )
                          {
                              return YES;
                          }];
    
    XCTAssert( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:0] );
    
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
    XCTAssertFalse( [self.fileCache saveFile:@"somefile" toPath:@"somepath" shouldOverwrite:YES withNumRetries:retries] );
    
    [VFileCache v_restoreOriginalImplementation:implementation forMethod:@selector(saveFile:toPath:shouldOverwrite:)];
}

@end
