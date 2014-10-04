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
@property (nonatomic, strong) NSURL *taskSaveFileURL;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) NSData *response;

@end

@implementation VUploadManagerTests

- (void)setUp
{
    [super setUp];
    self.uploadManager = [[VUploadManager alloc] initWithObjectManager:nil];
    self.uploadManager.useBackgroundSession = NO;
    
    NSString *taskSaveFilename = [[NSUUID UUID] UUIDString];
    self.taskSaveFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:taskSaveFilename]];
    self.uploadManager.tasksSaveFileURL = self.taskSaveFileURL;
    
    NSString *bodyFilename = [[NSUUID UUID] UUIDString];
    self.bodyFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:bodyFilename]];
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
    [[NSFileManager defaultManager] removeItemAtURL:self.taskSaveFileURL error:nil];
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
    
    BOOL bodyFileStillExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.bodyFileURL path] isDirectory:NULL];
    XCTAssertFalse(bodyFileStillExists);
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

- (void)testGetQueuedUploadTasksInitiallyEmpty
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        XCTAssertEqual(tasks.count, 0u);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testQueuedUploadTasksReturnsNewUpload
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).withBody(self.body).andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
        {
            if (tasks.count)
            {
                XCTAssertEqualObjects(tasks[0], task);
            }
            else
            {
                XCTFail(@"Enqueued upload task was not present in getUploadTasksWithCompletion return value");
            }
            [async signal];
        }];
        [async waitForSignal:5.0];
        [async signal];
    });
    
    [self.uploadManager enqueueUploadTask:task onComplete:nil];
    [async waitForSignal:5.0];
}

- (void)testQueuedUploadTasksReturnsFailedUpload
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).andFailWithError([NSError errorWithDomain:@"domain" code:1 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
        {
            if (tasks.count)
            {
                XCTAssertEqualObjects(tasks[0], task);
            }
            else
            {
                XCTFail(@"Enqueued, failed upload task was not present in getUploadTasksWithCompletion return value");
            }
            [async signal];
        }];
    }];
    [async waitForSignal:5.0];
}

- (void)testQueuedUploadTasksDoesNotReturnSuccessfulUpload
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).andReturn(200);
    
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
        {
            XCTAssertEqual(tasks.count, 0u, @"Completed upload task was still present in getUploadTasksWithCompletion return value");
            [async signal];
        }];
    }];
    [async waitForSignal:5.0];
}

- (void)testIsTaskInProgress
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        BOOL isInProgress = [self.uploadManager isTaskInProgress:task];
        XCTAssertTrue(isInProgress);
    });
    
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            BOOL isInProgress = [self.uploadManager isTaskInProgress:task];
            XCTAssertFalse(isInProgress);
            [async signal];
        });
    }];
    [async waitForSignal:5.0];
}

@end
