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

@end

@implementation VBasicTemplateDownloaderMock

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    if ( self.mockTemplateDictionary == nil )
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        completion(self.mockTemplateDictionary, nil);
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

- (void)testDownloaderFallsBackOnCache
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

@end
