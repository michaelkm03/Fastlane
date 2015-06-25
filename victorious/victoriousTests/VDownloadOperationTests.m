//
//  VDownloadOperationTests.m
//  victorious
//
//  Created by Josh Hinman on 6/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "Nocilla.h"
#import "VDownloadOperation.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VDownloadOperationTests : XCTestCase

@property (nonatomic, strong) VDownloadOperation *operation;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation VDownloadOperationTests

- (void)setUp
{
    [super setUp];
    self.operationQueue = [[NSOperationQueue alloc] init];
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
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSString *testBody = @"hello world";
    
    stubRequest(@"GET", url.absoluteString).andReturn(200).withBody(testBody);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    self.operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string, testBody);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:self.operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDownloadFailed
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSError *err = [NSError errorWithDomain:@"really bad" code:666 userInfo:nil];

    stubRequest(@"GET", url.absoluteString).andFailWithError(err);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    self.operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(err, error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:self.operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testNotOKResponseCode
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/two"];
    
    stubRequest(@"GET", url.absoluteString).andReturn(500);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    self.operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:self.operation];
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
