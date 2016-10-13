//
//  VBulkDownloadOperationTests.m
//  victorious
//
//  Created by Josh Hinman on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "FBKVOController.h"
#import "Nocilla.h"
#import "NSURL+VDataCacheID.h"
#import "VBulkDownloadOperation.h"
#import "VDataCache.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@import KVOController;

@interface VBulkDownloadOperationTests : XCTestCase

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VDataCache *dataCache;

@end

@implementation VBulkDownloadOperationTests

- (void)setUp
{
    [super setUp];
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.dataCache = [[VDataCache alloc] init];
    self.dataCache.localCacheURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
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

- (void)testDownload
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/single"];
    NSString *testBody = @"hello world";
    
    stubRequest(@"GET", url.absoluteString).andReturn(200).withBody(testBody);
    
    NSSet *urls = [NSSet setWithObject:url];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:urls
                                                            completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(originalURL, url);
        XCTAssertNil(error);
        NSData *cachedData = [NSData dataWithContentsOfURL:downloadedFile];
        NSString *stringFromData = [[NSString alloc] initWithData:cachedData encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData, testBody);
        
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testFailedDownloadWithRetriesTurnedOff
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/single"];
    NSError *err = [NSError errorWithDomain:@"really bad" code:666 userInfo:nil];
    
    stubRequest(@"GET", url.absoluteString).andFailWithError(err);
    
    NSSet *urls = [NSSet setWithObject:url];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:urls
                                                                          completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(originalURL, url);
        XCTAssertEqualObjects(err, error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testMultipleDownloads
{
    NSURL *url1 = [NSURL URLWithString:@"http://www.example.com/one"];
    NSURL *url2 = [NSURL URLWithString:@"http://www.example.com/two"];
    NSURL *url3 = [NSURL URLWithString:@"http://www.example.com/three"];
    NSURL *url4 = [NSURL URLWithString:@"http://www.example.com/four"];
    NSURL *url5 = [NSURL URLWithString:@"http://www.example.com/five"];
    NSString *testBody1 = @"hello world 1";
    NSString *testBody2 = @"hello world 2";
    NSString *testBody3 = @"hello world 3";
    NSString *testBody4 = @"hello world 4";
    NSString *testBody5 = @"hello world 5";
    
    stubRequest(@"GET", url1.absoluteString).andReturn(200).withBody(testBody1);
    stubRequest(@"GET", url2.absoluteString).andReturn(200).withBody(testBody2);
    stubRequest(@"GET", url3.absoluteString).andReturn(200).withBody(testBody3);
    stubRequest(@"GET", url4.absoluteString).andReturn(200).withBody(testBody4);
    stubRequest(@"GET", url5.absoluteString).andReturn(200).withBody(testBody5);
    
    __block BOOL downloadedUrl1 = NO;
    __block BOOL downloadedUrl2 = NO;
    __block BOOL downloadedUrl3 = NO;
    __block BOOL downloadedUrl4 = NO;
    __block BOOL downloadedUrl5 = NO;
    
    NSSet *urls = [NSSet setWithObjects:url1, url2, url3, url4, url5, nil];
    
    __block VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:urls
                                                                    completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        @synchronized(self)
        {
            if ( [originalURL isEqual:url1] )
            {
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadedFile];
                NSString *stringFromData = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects( stringFromData, testBody1);
                downloadedUrl1 = YES;
            }
            else if ( [originalURL isEqual:url2] )
            {
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadedFile];
                NSString *stringFromData = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects( stringFromData, testBody2);
                downloadedUrl2 = YES;
            }
            else if ( [originalURL isEqual:url3] )
            {
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadedFile];
                NSString *stringFromData = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects( stringFromData, testBody3);
                downloadedUrl3 = YES;
            }
            else if ( [originalURL isEqual:url4] )
            {
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadedFile];
                NSString *stringFromData = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects( stringFromData, testBody4);
                downloadedUrl4 = YES;
            }
            else if ( [originalURL isEqual:url5] )
            {
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadedFile];
                NSString *stringFromData = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
                XCTAssertEqualObjects( stringFromData, testBody5);
                downloadedUrl5 = YES;
            }
            XCTAssertFalse(operation.isFinished);
        }
    }];
    
    XCTestExpectation *operationFinishExpectation = [self expectationWithDescription:@"operation should finish"];
    [self.KVOController observe:operation keyPath:@"isFinished" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change)
    {
        BOOL newFinished = [change[NSKeyValueChangeNewKey] boolValue];
        if ( newFinished )
        {
            XCTAssert( downloadedUrl1 );
            XCTAssert( downloadedUrl2 );
            XCTAssert( downloadedUrl3 );
            XCTAssert( downloadedUrl4 );
            XCTAssert( downloadedUrl5 );
            [operationFinishExpectation fulfill];
        }
    }];
    
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testRetryDefault
{
    VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:[NSSet set] completion:nil];
    XCTAssertFalse(operation.shouldRetry);
}

- (void)testRetry
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSString *testBody = @"hello world";
    
    stubRequest(@"GET", url.absoluteString).andFailWithError([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorDNSLookupFailed userInfo:nil]);
    
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"callback on success"];
    XCTestExpectation *failureExpectation = [self expectationWithDescription:@"callback on failure"];
    VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:[NSSet setWithObject:url] completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        if ( error == nil )
        {
            NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(string, testBody);
            [successExpectation fulfill];
        }
        else
        {
            XCTAssertNil(downloadedFile);
            
            [[LSNocilla sharedInstance] clearStubs];
            stubRequest(@"GET", url.absoluteString).andReturn(200).withBody(testBody);
        
            [failureExpectation fulfill];
        }
    }];
    operation.shouldRetry = YES;
    operation.retryInterval = 0;
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testFiveRetries
{
    __block NSInteger failCount = 0;
    __block BOOL success = NO;
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSString *testBody = @"hello world";
    
    stubRequest(@"GET", url.absoluteString).andFailWithError([NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorDNSLookupFailed userInfo:nil]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VBulkDownloadOperation *operation = [[VBulkDownloadOperation alloc] initWithURLs:[NSSet setWithObject:url] completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        if ( success )
        {
            XCTAssertFalse(error);
            NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(string, testBody);
            [expectation fulfill];
        }
        else if ( failCount >= 5 )
        {
            [[LSNocilla sharedInstance] clearStubs];
            stubRequest(@"GET", url.absoluteString).andReturn(200).withBody(testBody);
            success = YES;
        }
        else
        {
            failCount++;
        }
    }];
    operation.shouldRetry = YES;
    operation.retryInterval = 0;
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

@end
