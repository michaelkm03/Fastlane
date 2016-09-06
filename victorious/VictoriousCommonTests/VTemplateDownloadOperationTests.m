//
//  VTemplateDownloadOperationTests.m
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "FBKVOController.h"
#import "Nocilla.h"
#import "NSString+VDataCacheID.h"
#import "NSURL+VDataCacheID.h"
#import "VTemplateDownloadOperation.h"
#import "VTemplateSerialization.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@import VictoriousCommon;

@interface VBasicTemplateDownloaderMock : NSObject <VTemplateDownloader>

@property (nonatomic, strong) NSDictionary *mockTemplateDictionary;
@property (nonatomic, strong) NSError *mockError;
@property (nonatomic, strong, readonly) dispatch_queue_t privateQueue;

@end

@implementation VBasicTemplateDownloaderMock

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _privateQueue = dispatch_queue_create("VFailingTemplateDownloaderMock", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    if ( self.mockTemplateDictionary == nil && self.mockError == nil )
    {
        return;
    }
    dispatch_async(self.privateQueue, ^(void)
    {
        NSData *templateData = nil;
        if ( self.mockTemplateDictionary != nil )
        {
            templateData = [NSJSONSerialization dataWithJSONObject:@{ @"payload": self.mockTemplateDictionary } options:0 error:nil];
        }
        completion(templateData, self.mockError);
    });
}

@end

#pragma mark -

/**
 This mock will fail a set number of times before it succeeds
 */
@interface VFailingTemplateDownloaderMock : NSObject <VTemplateDownloader>

@property (nonatomic, strong) NSDictionary *mockTemplateDictionary;
@property (nonatomic, copy) void (^successCompletion)(); ///< Will be called on success
@property (nonatomic) NSInteger failCount;
@property (nonatomic, strong, readonly) dispatch_queue_t privateQueue;

@end

@implementation VFailingTemplateDownloaderMock

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _privateQueue = dispatch_queue_create("VFailingTemplateDownloaderMock", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    if ( self.mockTemplateDictionary == nil )
    {
        return;
    }
    dispatch_async(self.privateQueue, ^(void)
    {
        if ( self.failCount > 0 )
        {
            self.failCount--;
            completion(nil, [NSError errorWithDomain:@"really bad" code:999 userInfo:nil]);
        }
        else
        {
            completion([NSJSONSerialization dataWithJSONObject:@{ @"payload": self.mockTemplateDictionary } options:0 error:nil], nil);
            if ( self.successCompletion != nil )
            {
                self.successCompletion();
            }
        }
    });
}

@end

#pragma mark -

@interface VTemplateDownloadOperationTests : XCTestCase

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VDataCache *dataCache;
@property (nonatomic, strong) NSString *buildNumber;

@end

@implementation VTemplateDownloadOperationTests

- (void)setUp
{
    [super setUp];
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSString *subdirectory = [[NSUUID UUID] UUIDString];
    NSURL *temporaryDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:subdirectory isDirectory:YES];

    self.dataCache = [[VDataCache alloc] init];
    self.dataCache.localCacheURL = temporaryDirectory;
    
    [[LSNocilla sharedInstance] start];
    
    self.buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    //Ideally, this implementation detail would be taken care of by a different setup step sent to the template download operation.
    [[NSUserDefaults standardUserDefaults] setObject:self.buildNumber forKey:@"com.victorious.currentBuildNumber"];
}

- (void)tearDown
{
    [self.operationQueue cancelAllOperations];
    [self.operationQueue waitUntilAllOperationsAreFinished];
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [super tearDown];
}

- (void)testDefaultCache
{
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    VTemplateDownloadOperation *operation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    XCTAssertNotNil(operation.dataCache);
}

- (void)testTemplateDownload
{
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    [self.operationQueue addOperations:@[downloadOperation] waitUntilFinished:YES];
    
    NSDictionary *expected = downloader.mockTemplateDictionary;
    XCTAssertEqualObjects(downloadOperation.templateConfiguration, expected);
}

- (void)testDownloaderSavesNewTemplate
{
    NSDictionary *expected = @{ @"hello": @"world" };
    
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = expected;
    
    VEnvironment *environment = [[VEnvironment alloc] initWithName:@"acme" baseURL:[NSURL URLWithString:@"http://www.example.com"] appID:@1];
    TemplateCache *templateCache = [[TemplateCache alloc] initWithDataCache:self.dataCache environment:environment buildNumber:@"1"];
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    downloadOperation.templateCache = templateCache;
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperations:@[downloadOperation] waitUntilFinished:YES];
    
    NSData *templateData = [templateCache cachedTemplateData];
    XCTAssertNotNil(templateData);
    
    if ( templateData != nil )
    {
        NSDictionary *actual = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
        XCTAssertEqualObjects(expected, actual);
    }
}

- (void)testDownloaderRetriesOnError
{
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Download manager should keep retrying until successful download"];
    
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.failCount = 2;
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.successCompletion = ^(void)
    {
        [successExpectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    downloadOperation.dataCache = self.dataCache;
    downloadOperation.templateDownloadTimeout = 0.1;
    
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testRetryDefault
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    XCTAssertTrue(downloadOperation.shouldRetry);
}

- (void)testNoRetry
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.failCount = 1;
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    downloadOperation.templateDownloadTimeout = 0.01;
    downloadOperation.shouldRetry = NO;
    [self.operationQueue addOperations:@[downloadOperation] waitUntilFinished:YES];
    
    XCTAssertNil(downloadOperation.templateConfiguration);
}

- (void)testImageDownload
{
    NSURL *imageURL = [NSURL URLWithString:@"http://www.example.com/testImageDownload"];
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"image": @{ @"imageURL": imageURL.absoluteString } };
    
    char bytes[] = { 1, 2, 3, 4, 5 };
    NSData *imageData = [NSData dataWithBytes:bytes length:5];
    stubRequest(@"GET", imageURL.absoluteString).andReturn(200).withBody(imageData);
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader];
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperations:@[downloadOperation] waitUntilFinished:YES];
    
    NSDictionary *expected = downloader.mockTemplateDictionary;
    XCTAssertEqualObjects(downloadOperation.templateConfiguration, expected);
    
    NSData *imageDataFromCache = [self.dataCache cachedDataForID:imageURL];
    XCTAssertEqualObjects(imageData, imageDataFromCache);
}

@end
