//
//  VUploadManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsyncTestHelper.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"

#import <Nocilla/Nocilla.h>
#import <XCTest/XCTest.h>

@interface VUploadManagerTests : XCTestCase

@property (nonatomic, strong) VUploadManager *uploadManager;
@property (nonatomic, strong) NSURL *bodyFileURL;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) NSData *response;

@end

@implementation VUploadManagerTests

- (void)setUp
{
    [super setUp];
    self.uploadManager = [[VUploadManager alloc] initWithObjectManager:nil];
    self.uploadManager.useBackgroundSession = NO;
    
    NSString *filename = [[NSUUID UUID] UUIDString];
    self.bodyFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
    self.body = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [self.body writeToURL:self.bodyFileURL atomically:YES];
    
    self.response = [@"response world" dataUsingEncoding:NSUTF8StringEncoding];
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown
{
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [[NSFileManager defaultManager] removeItemAtURL:self.bodyFileURL error:nil];
    [super tearDown];
}

- (void)testBodyFileURL
{
    NSURL *bodyFileURL = [self.uploadManager urlForNewUploadBodyFile];
    XCTAssertNotNil(bodyFileURL);
    XCTAssertTrue(bodyFileURL.isFileURL);
}

- (void)testSingleUploadTask
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];

    stubRequest(@"POST", url.absoluteString).withBody(self.body).andReturn(200).withBody(self.response);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        XCTAssertEqualObjects(responseData, self.response);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testError
{
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).withBody(self.body).andFailWithError([NSError errorWithDomain:@"domain" code:100 userInfo:nil]);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        XCTAssertNotNil(error);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

@end
