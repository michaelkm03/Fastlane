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

@end

@implementation VUploadManagerURLSessionTests

- (void)setUp
{
    [super setUp];
    self.mockURLSession = [OCMockObject niceMockForClass:[NSURLSession class]];
    self.sessionWithConfigurationImp = [NSURLSession v_swizzleClassMethod:@selector(sessionWithConfiguration:delegate:delegateQueue:)
                                                                withBlock:^(id me, NSURLSessionConfiguration *configuration, id<NSURLSessionDelegate> delegate, NSOperationQueue *queue)
    {
        return self.mockURLSession;
    }];
    self.mockSessionTask = [OCMockObject niceMockForClass:[NSURLSessionTask class]];
    [[[self.mockURLSession stub] andReturn:self.mockSessionTask] uploadTaskWithRequest:OCMOCK_ANY fromFile:OCMOCK_ANY];
    [[[self.mockURLSession stub] andDo:^(NSInvocation *invocation)
    {
        void (^completion)(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks);
        [invocation getArgument:&completion atIndex:2];
        if (completion)
        {
            completion(@[], @[], @[]);
        }
    }] getTasksWithCompletionHandler:OCMOCK_ANY];
    
    self.uploadManager = [[VUploadManager alloc] initWithObjectManager:nil];
    
    NSString *filename = [[NSUUID UUID] UUIDString];
    self.bodyFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
    NSData *body = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [body writeToURL:self.bodyFileURL atomically:YES];
    
    self.uploadTask = [[VUploadTaskInformation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com/"]]
                                                         previewImage:nil
                                                          bodyFileURL:self.bodyFileURL
                                                          description:nil];
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
    NSNumber *__block expectedTotalBytes;
    NSNumber *__block expectedBytesSent;
    
    VAsyncTestHelper *async = [[VAsyncTestHelper alloc] init];
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VUploadManagerTaskBeganNotification
                                                                    object:self.uploadManager
                                                                     queue:nil
                                                                usingBlock:^(NSNotification *notification)
    {
        XCTAssertEqualObjects(self.uploadTask, notification.userInfo[VUploadManagerUploadTaskUserInfoKey]);
        [async signal];
    }];
    
    expectedTotalBytes = nil;
    expectedBytesSent = @(0);
    [self.uploadManager enqueueUploadTask:self.uploadTask onComplete:nil];
    [async waitForSignal:5.0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
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

@end
