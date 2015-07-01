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
    VDownloadOperation *operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(originalURL, url);
        NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string, testBody);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testDownloadFailed
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSError *err = [NSError errorWithDomain:@"really bad" code:666 userInfo:nil];

    stubRequest(@"GET", url.absoluteString).andFailWithError(err);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VDownloadOperation *operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(originalURL, url);
        XCTAssertEqualObjects(err, error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testNotOKResponseCode
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/two"];
    
    stubRequest(@"GET", url.absoluteString).andReturn(500);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VDownloadOperation *operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        XCTAssertEqualObjects(originalURL, url);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testProgressObjectCreated
{
    NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    [progress becomeCurrentWithPendingUnitCount:1];
    __unused VDownloadOperation *operation = [[VDownloadOperation alloc] initWithURL:[NSURL URLWithString:@"http://www.example.com/three"]
                                                                 completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
    }];
    [progress resignCurrent];
    XCTAssertEqual(progress.completedUnitCount, 0); // if the VDownloadOperation initializer failed to create an NSProgress object, completedUnitCount will be 1.
}

- (void)testProgressObjectUpdated
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/one"];
    NSString *testBody = @"hello world";
    
    stubRequest(@"GET", url.absoluteString).andReturn(200).withBody(testBody);

    NSProgress *progress = [NSProgress progressWithTotalUnitCount:1];
    [progress becomeCurrentWithPendingUnitCount:1];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"download callback"];
    VDownloadOperation *operation = [[VDownloadOperation alloc] initWithURL:url completion:^(NSURL *originalURL, NSError *error, NSURLResponse *response, NSURL *downloadedFile)
    {
        NSData *data = [NSData dataWithContentsOfURL:downloadedFile];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string, testBody);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [progress resignCurrent];
    XCTAssertEqual(progress.completedUnitCount, 0);
    
    [self.operationQueue addOperation:operation];
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    XCTAssertGreaterThanOrEqual(progress.completedUnitCount, progress.totalUnitCount);
}

@end
