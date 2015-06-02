//
//  VTemplateDownloadManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateDownloadManager.h"
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

@interface VTemplateDownloadManagerTests : XCTestCase

@end

@implementation VTemplateDownloadManagerTests

- (void)testTemplateDownload
{
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:downloader];
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        NSDictionary *expected = downloader.mockTemplateDictionary;
        XCTAssertEqualObjects(templateConfiguration, expected);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheAfterTimeout
{
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:[[VBasicTemplateDownloaderMock alloc] init]];
    manager.timeout = 0.01;
    manager.templateCacheFileLocation = templateFileURL;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheAfterError
{
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];

    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockError = [NSError errorWithDomain:@"bad" code:999 userInfo:nil];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:downloader];
    manager.templateCacheFileLocation = templateFileURL;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnBundle
{
    NSURL *templateCacheURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"this-doesnt-exist" withExtension:@"json"];
    NSURL *templateBundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateBundleURL];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:[[VBasicTemplateDownloaderMock alloc] init]];
    manager.timeout = 0.01;
    manager.templateCacheFileLocation = templateCacheURL;
    manager.templateLocationInBundle = templateBundleURL;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderSavesNewTemplate
{
    NSDictionary *expected = @{ @"hello": @"world" };
    
    VBasicTemplateDownloaderMock *downloader = [[VBasicTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = expected;

    NSURL *templateCacheURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:downloader];
    manager.templateCacheFileLocation = templateCacheURL;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        NSData *templateData = [NSData dataWithContentsOfURL:templateCacheURL];
        XCTAssertNotNil(templateData);
        
        NSDictionary *actual = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
        XCTAssertEqualObjects(expected, actual);
        
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderFallsBackOnCacheOnErrorButContinuesTryingToDownloadTemplate
{
    NSURL *templateFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"templateCache" withExtension:@"json"];
    NSData *templateData = [NSData dataWithContentsOfURL:templateFileURL];
    NSDictionary *expectedTemplateConfiguration = [VTemplateSerialization templateConfigurationDictionaryWithData:templateData];
    
    XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Download manager should keep retrying until successful download"];
    
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.failCount = 2;
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.successCompletion = ^(void)
    {
        [successExpectation fulfill];
    };
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:downloader];
    manager.templateCacheFileLocation = templateFileURL;
    manager.timeout = 0.1;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        XCTAssertEqualObjects(templateConfiguration, expectedTemplateConfiguration);
        [callbackExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDownloaderKeepsTryingToDownloadIfItHasNothingToFallBackOn
{
    VFailingTemplateDownloaderMock *downloader = [[VFailingTemplateDownloaderMock alloc] init];
    downloader.mockTemplateDictionary = @{ @"hello": @"world" };
    downloader.failCount = 3;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download manager should call its completion block"];
    
    VTemplateDownloadManager *manager = [[VTemplateDownloadManager alloc] initWithDownloader:downloader];
    manager.timeout = 0.01;
    [manager loadTemplateWithCompletion:^(NSDictionary *templateConfiguration)
    {
        NSDictionary *expected = downloader.mockTemplateDictionary;
        XCTAssertEqualObjects(templateConfiguration, expected);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
