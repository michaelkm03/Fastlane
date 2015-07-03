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

@interface VBasicTemplateDownloaderMock : NSObject <VTemplateDownloader>

@property (nonatomic, strong) NSDictionary *mockTemplateDictionary;
@property (nonatomic, strong) NSError *mockError;

@end

@implementation VBasicTemplateDownloaderMock

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    if ( self.mockTemplateDictionary == nil && self.mockError == nil )
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void)
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

@interface VTemplateDownloadOperationTestDelegate : NSObject <VTemplateDownloadOperationDelegate>

@property (nonatomic, copy) void (^didFinishLoadingWithTemplateConfiguration)(NSDictionary *configuration);
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation VTemplateDownloadOperationTestDelegate

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
{
    self = [super init];
    if ( self != nil)
    {
        _operationQueue = operationQueue;
    }
    return self;
}

- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation didFinishLoadingTemplateConfiguration:(NSDictionary *)configuration
{
    if ( self.didFinishLoadingWithTemplateConfiguration != nil )
    {
        self.didFinishLoadingWithTemplateConfiguration(configuration);
    }
}

- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation needsAnOperationAddedToTheQueue:(NSOperation *)operation
{
    [self.operationQueue addOperation:operation];
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

@end

@implementation VFailingTemplateDownloaderMock

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    if ( self.mockTemplateDictionary == nil )
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void)
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
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    VTemplateDownloadOperation *operation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    XCTAssertNotNil(operation.dataCache);
}

- (void)testTemplateDownload
{
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        NSDictionary *expected = downloader.mockTemplateDictionary;
        XCTAssertEqualObjects(templateConfiguration, expected);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = [[NSUUID UUID] UUIDString];
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheAfterTimeout
{
    NSString *templateCacheID = [[NSUUID UUID] UUIDString];
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    [self.dataCache cacheData:templateData forID:templateCacheID error:nil];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:[[VBasicTemplateDownloaderMock alloc] init]
                                                                                               andDelegate:delegate];
    downloadOperation.shouldRetry = NO;
    downloadOperation.templateDownloadTimeout = 0.01;
    downloadOperation.templateConfigurationCacheID = templateCacheID;
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheAfterError
{
    NSString *templateCacheID = [[NSUUID UUID] UUIDString];
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    [self.dataCache cacheData:templateData forID:templateCacheID error:nil];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];

    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockError = [NSError errorWithDomain:@"bad" code:999 userInfo:nil];

    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = templateCacheID;
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderSavesNewTemplate
{
    NSDictionary *expected = @{ @"hello": @"world" };
    
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = expected;

    NSString *templateCacheID = [[NSUUID UUID] UUIDString];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        NSData *templateData = [self.dataCache cachedDataForID:templateCacheID];
        XCTAssertNotNil(templateData);
        
        if ( templateData != nil )
        {
            NSDictionary *actual = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
            XCTAssertEqualObjects(expected, actual);
        }
        
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = templateCacheID;
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheOnErrorButContinuesTryingToDownloadTemplate
{
    NSString *templateCacheID = [[NSUUID UUID] UUIDString];
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    [self.dataCache cacheData:templateData forID:templateCacheID error:nil];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"Delegate callback"];
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Download manager should keep retrying until successful download"];
    
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.failCount = 2;
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.successCompletion = ^(void)
    {
        [successExpectation fulfill];
    };
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [callbackExpectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = templateCacheID;
    downloadOperation.templateDownloadTimeout = 0.1;
    
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderKeepsTryingToDownloadIfItHasNothingToFallBackOn
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.failCount = 3;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        NSDictionary *expected = downloader.mockTemplateDictionary;
        XCTAssertEqualObjects(templateConfiguration, expected);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateDownloadTimeout = 0.01;
    downloadOperation.templateConfigurationCacheID = [[NSUUID UUID] UUIDString];
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testRetryDefault
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:nil];
    XCTAssertTrue(downloadOperation.shouldRetry);
}

- (void)testNoRetry
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.failCount = 1;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertNil(templateConfiguration);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateDownloadTimeout = 0.01;
    downloadOperation.shouldRetry = NO;
    downloadOperation.templateConfigurationCacheID = [[NSUUID UUID] UUIDString];
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testOperationFinishesAtTheRightTime
{
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    
    __block VTemplateDownloadOperation *downloadOperation;
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertFalse(downloadOperation.isFinished);
        [completionExpectation fulfill];
    };
    
    downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = [[NSUUID UUID] UUIDString];
    
    XCTestExpectation *finishExpectation = [self expectationWithDescription:@"isFinished KVO notification"];
    [self.KVOController observe:downloadOperation
                        keyPath:NSStringFromSelector(@selector(isFinished))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
    {
        BOOL isFinished = [change[NSKeyValueChangeNewKey] boolValue];
        if ( isFinished )
        {
            [finishExpectation fulfill];
        }
    }];
    
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testImageDownload
{
    NSURL *imageURL = [NSURL URLWithString:@"http://www.example.com/myImage"];
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"image": @{ @"imageURL": imageURL.absoluteString } };
    
    char bytes[] = { 1, 2, 3, 4, 5 };
    NSData *imageData = [NSData dataWithBytes:bytes length:5];
    stubRequest(@"GET", imageURL.absoluteString).andReturn(200).withBody(imageData);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        NSDictionary *expected = downloader.mockTemplateDictionary;
        XCTAssertEqualObjects(templateConfiguration, expected);
        
        NSData *imageDataFromCache = [self.dataCache cachedDataForID:imageURL];
        XCTAssertEqualObjects(imageData, imageDataFromCache);
        
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = [[NSUUID UUID] UUIDString];
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheAfterImageDownloadError
{
    NSString *templateCacheID = [[NSUUID UUID] UUIDString];
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    [self.dataCache cacheData:templateData forID:templateCacheID error:nil];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://www.example.com/myImage"];
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"image": @{ @"imageURL": imageURL.absoluteString } };
    
    stubRequest(@"GET", imageURL.absoluteString).andFailWithError([NSError errorWithDomain:@"really bad" code:666 userInfo:nil]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate callback"];
    
    VTemplateDownloadOperationTestDelegate *delegate = [[VTemplateDownloadOperationTestDelegate alloc] initWithOperationQueue:self.operationQueue];
    delegate.didFinishLoadingWithTemplateConfiguration = ^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    };
    
    VTemplateDownloadOperation *downloadOperation = [[VTemplateDownloadOperation alloc] initWithDownloader:downloader andDelegate:delegate];
    downloadOperation.templateConfigurationCacheID = templateCacheID;
    downloadOperation.dataCache = self.dataCache;
    [self.operationQueue addOperation:downloadOperation];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
