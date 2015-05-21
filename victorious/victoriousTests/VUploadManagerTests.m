//
//  VUploadManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsyncTestHelper.h"
#import "VConstants.h"
#import "VObjectManager+Login.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"
#import "VUploadTaskSerializer.h"

#import <Nocilla/Nocilla.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#undef andReturn // to make Nocilla play well with OCMock
#undef andDo

@interface VUploadManagerTests : XCTestCase

@property (nonatomic, strong) id objectManagerMock;
@property (nonatomic, strong) VUploadManager *uploadManager;
@property (nonatomic, strong) NSURL *bodyFileURL;
@property (nonatomic, strong) NSURL *inProgressTaskSaveFileURL;
@property (nonatomic, strong) NSURL *pendingTaskSaveFileURL;
@property (nonatomic, strong) VUploadTaskSerializer *pendingTaskSerializer;
@property (nonatomic, strong) VUploadTaskInformation *uploadTask;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) NSData *response;

@end

@implementation VUploadManagerTests

- (void)setUp
{
    [super setUp];
    
    self.objectManagerMock = [OCMockObject niceMockForClass:[VObjectManager class]];
    [[[self.objectManagerMock stub] andReturnValue:@(YES)] authorized];
    
    self.uploadManager = [[VUploadManager alloc] init];
    self.uploadManager.objectManager = self.objectManagerMock;
    self.uploadManager.useBackgroundSession = NO;
    
    NSString *taskSaveFilename = [[NSUUID UUID] UUIDString];
    self.inProgressTaskSaveFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:taskSaveFilename]];
    self.uploadManager.tasksInProgressSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.inProgressTaskSaveFileURL];
    
    taskSaveFilename = [[NSUUID UUID] UUIDString];
    self.pendingTaskSaveFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:taskSaveFilename]];
    self.pendingTaskSerializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.pendingTaskSaveFileURL];
    self.uploadManager.tasksPendingSerializer = self.pendingTaskSerializer;
    
    self.bodyFileURL = [self.uploadManager urlForNewUploadBodyFile];
    NSURL *bodyFileDirectoryURL = [self.bodyFileURL URLByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtURL:bodyFileDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.body = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [self.body writeToURL:self.bodyFileURL atomically:YES];
    
    self.response = [@"response world" dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    self.uploadTask = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFilename:[self.bodyFileURL lastPathComponent] description:nil];
    
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown
{
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
    [[NSFileManager defaultManager] removeItemAtURL:self.bodyFileURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:self.inProgressTaskSaveFileURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:self.pendingTaskSaveFileURL error:nil];
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
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        XCTAssertEqualObjects(responseData, self.response);
        [async signal];
    }];
    [async waitForSignal:5.0];
    
    BOOL bodyFileStillExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.bodyFileURL path] isDirectory:NULL];
    XCTAssertFalse(bodyFileStillExists);
}

- (void)testQueueingMultipleUploads
{
    NSURL *bodyFileURL2 = [self.uploadManager urlForNewUploadBodyFile];
    NSData *body2 = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [body2 writeToURL:bodyFileURL2 atomically:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example2.com/"]];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *upload2 = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFilename:[bodyFileURL2 lastPathComponent] description:nil];

    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];

    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andDo(^(NSDictionary * __autoreleasing *headers, NSInteger *status, id<LSHTTPBody> __autoreleasing *body)
    {
        [self.uploadManager enqueueUploadTask:upload2 onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error)
        {
            [async signal];
        }];
    });
    stubRequest(@"POST", upload2.request.URL.absoluteString).andReturn(200);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
}

- (void)testCancelQueuedUpload
{
    NSString *bodyFilename = [[NSUUID UUID] UUIDString];
    NSURL *bodyFileURL2 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:bodyFilename]];
    NSData *body2 = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [body2 writeToURL:bodyFileURL2 atomically:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example2.com/"]];
    [request setHTTPMethod:@"POST"];
    VUploadTaskInformation *upload2 = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFilename:[bodyFileURL2 lastPathComponent] description:nil];
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andDo(^(NSDictionary * __autoreleasing *headers, NSInteger *status, id<LSHTTPBody> __autoreleasing *body)
    {
        [self.uploadManager enqueueUploadTask:upload2 onComplete:nil];
        [self.uploadManager cancelUploadTask:upload2];
    });
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        // Wait for half a second to see if the cancelled upload tries to start.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
        {
            [async signal];
        });
    }];
    [async waitForSignal:5.0];
    
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        XCTAssertFalse([tasks containsObject:upload2]);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testError
{
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).withBody(self.body).andFailWithError([NSError errorWithDomain:@"domain" code:100 userInfo:nil]);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        XCTAssertNotNil(error);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testHTTPError
{
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(404);
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, VUploadManagerErrorDomain);
        XCTAssertEqual(error.code, VUploadManagerBadHTTPResponseErrorCode);
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
        XCTAssertNotNil(notification.userInfo[VUploadManagerErrorUserInfoKey]);
        [async signal];
    }];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError(error);
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testVictoriousErrorsTreatedAsErrors
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskFailedNotification
                                                                    object:self.uploadTask
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        
        NSError *error = notification.userInfo[VUploadManagerErrorUserInfoKey];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, kVictoriousErrorDomain);
        XCTAssertEqual(error.code, 400);
        
        [async signal];
    }];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(200).withBody(@"{"
                                                                                             "\"error\": 400,"
                                                                                             "\"message\": \"400 - Bad Request\","
                                                                                             "\"api_version\": \"2\","
                                                                                             "\"host\": \"dev.getvictorious.com\","
                                                                                             "\"app_id\": \"1\","
                                                                                             "\"user_id\": \"403\","
                                                                                             "\"page_number\": 1,"
                                                                                             "\"total_pages\": 1,"
                                                                                             "\"payload\": []"
                                                                                             "}");
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error)
    {
        XCTAssertNotNil(jsonResponse);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, kVictoriousErrorDomain);
        XCTAssertEqual(error.code, 400);
        [async signal];
    }];
    [async waitForSignal:5.0];
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
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
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

- (void)testFailedTasksCanBeCancelled
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError([NSError errorWithDomain:@"domain" code:1 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [self.uploadManager cancelUploadTask:self.uploadTask];
            [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
            {
                XCTAssertFalse([tasks containsObject:self.uploadTask]);
                [async signal];
            }];
        });
    }];
    [async waitForSignal:5.0];
}

- (void)testRetry
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    
    stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andFailWithError([NSError errorWithDomain:@"domain" code:1 userInfo:nil]);
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[LSNocilla sharedInstance] clearStubs];
            stubRequest(@"POST", self.uploadTask.request.URL.absoluteString).andReturn(200);
            [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
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
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
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
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
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
        VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.inProgressTaskSaveFileURL];
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
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
    {
        VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.inProgressTaskSaveFileURL];
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
    VUploadTaskInformation *task = [[VUploadTaskInformation alloc] initWithRequest:request previewImage:nil bodyFilename:[self.bodyFileURL lastPathComponent] description:nil];
    
    stubRequest(@"POST", url.absoluteString).andReturn(200);
    
    [self.uploadManager enqueueUploadTask:task onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonDictionary, NSError *error)
     {
         VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.inProgressTaskSaveFileURL];
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
    VUploadTaskSerializer *serializer = [[VUploadTaskSerializer alloc] initWithFileURL:self.inProgressTaskSaveFileURL];
    [serializer saveUploadTasks:@[self.uploadTask]];
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        XCTAssertTrue([tasks containsObject:self.uploadTask]);
        [async signal];
    }];
    [async waitForSignal:5.0];
}

- (void)testSavedTasksWithoutValidBodyFilesAreRejected
{
    NSURLRequest *request1 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.request1.com/"]];
    NSURLRequest *request2 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.request2.com/"]];
    NSURL *bodyFileURL1 = [self.uploadManager urlForNewUploadBodyFile];
    NSURL *bodyFileURL2 = [self.uploadManager urlForNewUploadBodyFile];
    NSString *description1 = @"fileDescription1";
    NSString *description2 = @"fileDescription2";
    VUploadTaskInformation *uploadTask1 = [[VUploadTaskInformation alloc] initWithRequest:request1 previewImage:nil bodyFilename:[bodyFileURL1 lastPathComponent] description:description1];
    VUploadTaskInformation *uploadTask2 = [[VUploadTaskInformation alloc] initWithRequest:request2 previewImage:nil bodyFilename:[bodyFileURL2 lastPathComponent] description:description2];
    
    NSURL *bodyFileDirectory = [bodyFileURL2 URLByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtURL:bodyFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    uint8_t bytes[] = { 0, 1, 2 };
    NSData *bodyData = [NSData dataWithBytes:bytes length:3];
    [bodyData writeToURL:bodyFileURL2 atomically:YES];
    
    if (![self.pendingTaskSerializer saveUploadTasks:@[uploadTask1, uploadTask2]])
    {
        XCTFail(@"failed to save uploads");
        return;
    }
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        XCTAssertEqual(tasks.count, 1u);
        XCTAssertEqualObjects([(VUploadTaskInformation *)tasks[0] request], request2);
        XCTAssertEqualObjects([(VUploadTaskInformation *)tasks[0] bodyFilename], [bodyFileURL2 lastPathComponent]);
        XCTAssertEqualObjects([(VUploadTaskInformation *)tasks[0] uploadDescription], description2);
        XCTAssertEqualObjects([(VUploadTaskInformation *)tasks[0] identifier], uploadTask2.identifier);
        
        [async signal];
    }];
    
    [async waitForSignal:5];
    [[NSFileManager defaultManager] removeItemAtURL:bodyFileURL2 error:nil];
}

@end
