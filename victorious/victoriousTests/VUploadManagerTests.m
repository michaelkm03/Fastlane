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
#import "VUploadTaskSerializer.h"

#import <Nocilla/Nocilla.h>
#import <XCTest/XCTest.h>

@interface VUploadManagerTests : XCTestCase

@property (nonatomic, strong) VUploadManager *uploadManager;
@property (nonatomic, strong) NSURL *bodyFileURL;
@property (nonatomic, strong) NSURL *taskSaveFileURL;
@property (nonatomic, strong) VUploadTaskInformation *uploadTask;
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
    self.uploadManager.taskSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.taskSaveFileURL];
    
    NSString *bodyFilename = [[NSUUID UUID] UUIDString];
    self.bodyFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:bodyFilename]];
    self.body = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [self.body writeToURL:self.bodyFileURL atomically:YES];
    
    self.response = [@"response world" dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    self.uploadTask = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFileURL:self.bodyFileURL description:nil];
        
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
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andReturn(200).withBody(self.response);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
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
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andFailWithError([NSError errorWithDomain:@"domain" code:100 userInfo:nil]);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        XCTAssertNotNil(error);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testNotificationSentWhenTaskCompletes
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskFinishedNotification
                                                                    object:self.uploadTask
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        [async signal];
    }];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(200);
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testNotificationSentWhenTaskCompletesWithError
{
    NSError *error = [NSError errorWithDomain:@"error" code:1 userInfo:nil];
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskFailedNotification
                                                                    object:self.uploadTask
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        XCTAssertNotNil(error);
        [async signal];
    }];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError(error);
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
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
    VAsyncTestHelper *async2 = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
        {
            if (tasks.count)
            {
                XCTAssertEqualObjects(tasks[0], self.uploadTask);
            }
            else
            {
                XCTFail(@"Enqueued upload task was not present in getUploadTasksWithCompletion return value");
            }
            [async2 signal];
        }];
        XCTAssertTrue([async2 waitForSignalWithoutThrowing:5.0]);
        [async signal];
    });
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
}

- (void)testQueuedUploadTasksReturnsFailedUpload
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError([NSError errorWithDomain:@"domain" code:1 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
        {
            if (tasks.count)
            {
                XCTAssertEqualObjects(tasks[0], self.uploadTask);
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

- (void)testRetry
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError([NSError errorWithDomain:@"domain" code:1 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[LSNocilla sharedInstance] clearStubs];
            stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(200);
            [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
            {
                [async signal];
            }];
        });
    }];
    [async waitForSignal:5.0];
}

- (void)testQueuedUploadTasksDoesNotReturnSuccessfulUpload
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(200);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
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
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        BOOL isInProgress = [self.uploadManager isTaskInProgress:self.uploadTask];
        XCTAssertTrue(isInProgress);
    });
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            BOOL isInProgress = [self.uploadManager isTaskInProgress:self.uploadTask];
            XCTAssertFalse(isInProgress);
            [async signal];
        });
    }];
    [async waitForSignal:5.0];
}

- (void)testInProgessTasksSavedToDisk
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andDo(^(NSDictionary **headers, NSInteger *status, id<LSHTTPBody> *body)
    {
        VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.taskSaveFileURL];
        NSArray *tasks = [serializer uploadTasksFromDisk];
        XCTAssertTrue([tasks containsObject:self.uploadTask]);
        [async signal];
    });
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
}

- (void)testFailedTasksSavedToDisk
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError([NSError errorWithDomain:@"error" code:0 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
    {
        VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.taskSaveFileURL];
        NSArray *tasks = [serializer uploadTasksFromDisk];
        XCTAssertTrue([tasks containsObject:self.uploadTask]);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testFinishedTasksRemovedFromDisk
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFileURL:self.bodyFileURL description:nil];
    
    stubRequest(@"POST", url.absoluteString).andReturn(200);
    
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSError *error)
     {
         VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.taskSaveFileURL];
         NSArray *tasks = [serializer uploadTasksFromDisk];
         XCTAssertFalse([tasks containsObject:task]);
         [async signal];
     }];
    [async waitForSignal:5.0];
}

- (void)testReadsSavedTasksFromDisk
{
    // At this point, VUploadManager has already been initialized. But
    // it should not read the tasks from disk on init, so now is not
    // too late to create this file.
    VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.taskSaveFileURL];
    [serializer saveUploadTasks:@[self.uploadTask]];
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        XCTAssertTrue([tasks containsObject:self.uploadTask]);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

@end
