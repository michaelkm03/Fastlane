//
//  VBulkDownloaderTests.m
//  victorious
//
//  Created by Josh Hinman on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "FBKVOController.h"
#import "Nocilla.h"
#import "NSURL+VDataCacheID.h"
#import "VBulkDownloader.h"
#import "VDataCache.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VBulkDownloaderTests : XCTestCase

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) VDataCache *dataCache;

@end

@implementation VBulkDownloaderTests

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
    VBulkDownloader *operation = [[VBulkDownloader alloc] initWithURLs:urls
                                                            completion:^(void)
    {
        VDataCache *dataCache = [[VDataCache alloc] init];
        NSData *cachedData = [dataCache cachedDataForID:url];
        NSString *stringFromData = [[NSString alloc] initWithData:cachedData encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData, testBody);
        
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testOperationFinishes
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
    
    NSSet *urls = [NSSet setWithObjects:url1, url2, url3, url4, url5, nil];
    
    VBulkDownloader *operation = [[VBulkDownloader alloc] initWithURLs:urls completion:nil];
    
    XCTestExpectation *operationFinishExpectation = [self expectationWithDescription:@"operation should finish"];
    [self.KVOController observe:operation keyPath:@"isFinished" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change)
    {
        BOOL newFinished = [change[NSKeyValueChangeNewKey] boolValue];
        if ( newFinished )
        {
            [operationFinishExpectation fulfill];
        }
    }];
    
    operation.dataCache = self.dataCache;
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
    
    NSSet *urls = [NSSet setWithObjects:url1, url2, url3, url4, url5, nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VBulkDownloader *operation = [[VBulkDownloader alloc] initWithURLs:urls
                                                            completion:^(void)
    {
        NSData *cachedData1 = [self.dataCache cachedDataForID:url1];
        NSString *stringFromData1 = [[NSString alloc] initWithData:cachedData1 encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData1, testBody1);
        
        NSData *cachedData2 = [self.dataCache cachedDataForID:url2];
        NSString *stringFromData2 = [[NSString alloc] initWithData:cachedData2 encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData2, testBody2);
        
        NSData *cachedData3 = [self.dataCache cachedDataForID:url3];
        NSString *stringFromData3 = [[NSString alloc] initWithData:cachedData3 encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData3, testBody3);
        
        NSData *cachedData4 = [self.dataCache cachedDataForID:url4];
        NSString *stringFromData4 = [[NSString alloc] initWithData:cachedData4 encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData4, testBody4);
        
        NSData *cachedData5 = [self.dataCache cachedDataForID:url5];
        NSString *stringFromData5 = [[NSString alloc] initWithData:cachedData5 encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects( stringFromData5, testBody5);
        
        [expectation fulfill];
    }];
    operation.dataCache = self.dataCache;
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}
/*
 - (void)testRetry
 {
 __block BOOL failedOnce = NO;
 NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
 NSString *testBody = @"hello world";
 
 stubRequest(@"GET", url.absoluteString).andDo(^(NSDictionary * __autoreleasing *headers, NSInteger *status, id<LSHTTPBody> __autoreleasing *body)
 {
 if ( failedOnce )
 {
 *status = 200;
 *body = testBody;
 }
 else
 {
 *status = 500;
 failedOnce = YES;
 }
 });
 
 XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
 self.operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *downloadedFile)
 {
 NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
 NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 XCTAssertEqualObjects(string, testBody);
 [expectation fulfill];
 }];
 self.operation.retryInterval = 0;
 [self.operationQueue addOperation:self.operation];
 [self waitForExpectationsWithTimeout:2.0 handler:nil];
 }
 
 - (void)testFiveRetries
 {
 __block NSInteger failCount = 0;
 NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
 NSString *testBody = @"hello world";
 
 stubRequest(@"GET", url.absoluteString).andDo(^(NSDictionary * __autoreleasing *headers, NSInteger *status, id<LSHTTPBody> __autoreleasing *body)
 {
 if ( failCount >= 5 )
 {
 *status = 200;
 *body = testBody;
 }
 else
 {
 *status = 500;
 failCount++;
 }
 });
 
 XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
 self.operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *downloadedFile)
 {
 NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
 NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 XCTAssertEqualObjects(string, testBody);
 [expectation fulfill];
 }];
 self.operation.retryInterval = 0;
 [self.operationQueue addOperation:self.operation];
 [self waitForExpectationsWithTimeout:2.0 handler:nil];
 }
 */

@end
