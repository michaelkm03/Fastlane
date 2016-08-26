//
//  VUploadManagerURLSessionTests.m
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSObject+VMethodSwizzling.h"
#import "VAsyncTestHelper.h"
#import "VUploadManager.h"
#import "VUploadTaskInformation.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

/**
 This test suite uses a mocked NSURLSession object to test the
 specific implementation of the session delegate methods
 on VUploadManager
 */
@interface VUploadManagerURLSessionTests : XCTestCase

@property (nonatomic, strong) id mockURLSession;
@property (nonatomic, strong) id mockSessionTask;
@property (nonatomic) IMP sessionWithConfigurationImp;
@property (nonatomic, strong) VUploadManager *uploadManager;
@property (nonatomic, strong) VUploadTaskInformation *uploadTask;
@property (nonatomic, strong) NSURL *bodyFileURL;
@property (nonatomic) BOOL urlSessionHasBeenInitialized;

@end

@implementation VUploadManagerURLSessionTests

- (void)setUp
{
    [super setUp];
    self.urlSessionHasBeenInitialized = NO;
    self.mockURLSession = [OCMockObject niceMockForClass:[NSURLSession class]];
    self.sessionWithConfigurationImp = [NSURLSession v_swizzleClassMethod:@selector(sessionWithConfiguration:delegate:delegateQueue:)
                                                                withBlock:^(id me, NSURLSessionConfiguration *configuration, id<NSURLSessionDelegate> delegate, NSOperationQueue *queue)
    {
        return self.mockURLSession;
    }];
    self.mockSessionTask = [OCMockObject niceMockForClass:[NSURLSessionTask class]];
    [[[self.mockURLSession stub] andDo:^(NSInvocation *invocation)
    {
        NSURLSessionTask *__autoreleasing returnValue = self.mockSessionTask;
        [invocation setReturnValue:&returnValue];
    }] uploadTaskWithRequest:OCMOCK_ANY fromFile:OCMOCK_ANY];
    [[[self.mockURLSession stub] andDo:^(NSInvocation *invocation)
    {
        void (^completion)(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks);
        [invocation getArgument:&completion atIndex:2];
        if (completion)
        {
            completion(@[], @[], @[]);
        }
        self.urlSessionHasBeenInitialized = YES;
    }] getTasksWithCompletionHandler:OCMOCK_ANY];
    
    self.uploadManager = [[VUploadManager alloc] init];
    
    self.bodyFileURL = [self.uploadManager urlForNewUploadBodyFile];
    NSURL *bodyFileDirectoryURL = [self.bodyFileURL URLByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtURL:bodyFileDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSData *body = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [body writeToURL:self.bodyFileURL atomically:YES];
    
    self.uploadTask = [[VUploadTaskInformation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com/"]]
                                                         previewImage:nil
                                                         bodyFilename:[self.bodyFileURL lastPathComponent]
                                                          description:nil
                                                                isGif:nil];
}

- (void)tearDown
{
    [NSURLSession v_restoreOriginalImplementation:self.sessionWithConfigurationImp forClassMethod:@selector(sessionWithConfiguration:delegate:delegateQueue:)];
    [[NSFileManager defaultManager] removeItemAtURL:self.bodyFileURL error:nil];
    [super tearDown];
}

- (void)testTaskIsStarted
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [[[self.mockSessionTask expect] andDo:^(NSInvocation *invocation)
    {
        [async signal];
    }] resume];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    [self.mockSessionTask verify];
}

- (void)testNotificationSentAtStart
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskBeganNotification
                                                                    object:self.uploadManager
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        [async signal];
    }];
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testErrorReturnedWhenBodyFileDoesntExist
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [[NSFileManager defaultManager] removeItemAtURL:self.bodyFileURL error:nil];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error)
    {
        XCTAssertEqualObjects(error.domain, VUploadManagerErrorDomain);
        XCTAssertEqual(error.code, VUploadManagerCouldNotStartUploadErrorCode);
        [async signal];
    }];
    [async waitForSignal:10.0];
}

- (void)testTaskFailsWhenNSURLSessionReturnsNoTask
{
    BOOL __block beginNotificationFired = NO;
    BOOL __block failNotificationFired = NO;
    
    self.mockSessionTask = nil;
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskBeganNotification
                                                                     object:self.uploadManager
                                                                      queue:nil
                                                                 usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        XCTAssertFalse(failNotificationFired);
        beginNotificationFired = YES;
        [async signal];
    }];
    id observer2 = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskFailedNotification
                                                                     object:self.uploadTask
                                                                      queue:nil
                                                                 usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        XCTAssertNotNil(notification.userInfo[VUploadManagerErrorUserInfoKey]);
        XCTAssertTrue(beginNotificationFired);
        failNotificationFired = YES;
        [async signal];
    }];

    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    
    [async waitForSignal:5.0];
    [async waitForSignal:5.0];
    
    XCTAssertTrue(failNotificationFired);
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer1];
    [[NSNotificationCenter defaultCenter] removeObserver:observer2];
}

- (void)testProgressNotificationSentPeriodically
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    NSNumber *__block expectedTotalBytes;
    NSNumber *__block expectedBytesSent;
    
    [[[self.mockSessionTask expect] andDo:^(NSInvocation *invocation)
    {
        [async signal];
    }] resume];
    
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskProgressNotification
                                                                    object:self.uploadTask
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(expectedTotalBytes, notification.userInfo[VUploadManagerTotalBytesUserInfoKey]);
        XCTAssertEqualObjects(expectedBytesSent, notification.userInfo[VUploadManagerBytesSentUserInfoKey]);
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        [async signal];
    }];
    
    expectedTotalBytes = @(10);
    expectedBytesSent = @(1);
    [(id)self.uploadManager URLSession:self.mockURLSession task:self.mockSessionTask didSendBodyData:1 totalBytesSent:1 totalBytesExpectedToSend:10];
    [async waitForSignal:5.0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testCancel
{
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    [[[self.mockSessionTask expect] andDo:^(NSInvocation *invocation)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
        {
            [(id)self.uploadManager URLSession:self.mockURLSession
                                          task:self.mockSessionTask
                          didCompleteWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
            [async signal];
        });
    }] cancel];
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0 withSignalBlock:^(void)
    {
        return self.urlSessionHasBeenInitialized;
    }];
    [self.uploadManager cancelUploadTask:self.uploadTask];
    [async waitForSignal:5.0];
    
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        BOOL containsTask = [tasks containsObject:self.uploadTask];
        XCTAssertFalse(containsTask);
        [async signal];
    }];
    [async waitForSignal:5.0];
    
    BOOL bodyFileStillExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.bodyFileURL path] isDirectory:NULL];
    XCTAssertFalse(bodyFileStillExists);
}

@end
