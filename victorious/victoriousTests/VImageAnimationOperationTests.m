//
//  VImageAnimationOperationTests.m
//  victorious
//
//  Created by Vincent Ho on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "victorious-Swift.h"

@interface VImageAnimationOperationTests : XCTestCase <VImageAnimationOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic) NSInteger expectedDelegateUpdateCallbacks;
@property (nonatomic) NSInteger delegateFinish;
//delegateFinish values: -1 = not completed, 0 = initial state, 1 = completed
@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation VImageAnimationOperationTests

- (void)animation:(VImageAnimationOperation *)animation didFinishAnimating:(BOOL)completed
{
    if (self.delegateFinish == 1)
    {
        XCTAssert(completed);
        if (completed)
        {
            [self.expectation fulfill];
        }
    }
    else if(self.delegateFinish == -1)
    {
        XCTAssertFalse(completed);
        if (!completed)
        {
            [self.expectation fulfill];
        }
    }
}

- (void)animation:(VImageAnimationOperation *)animation updatedToImage:(UIImage *)image
{
    self.expectedDelegateUpdateCallbacks--;
    NSLog(@"update: %ld", (long)self.expectedDelegateUpdateCallbacks);
}

- (void)setUp
{
    [super setUp];
    _operationQueue = [NSOperationQueue new];
    _delegateFinish = 0;
}

- (void)tearDown
{
    /// Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.operationQueue cancelAllOperations];
    [super tearDown];
}

- (void)waitForExpectation
{
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error)
     {
         if (error != nil)
         {
             XCTFail(@"timeout error: %@", error);
         }
     }];
}

- (void)testValidAnimationSequence
{
    self.expectation = [self expectationWithDescription:@"Valid animation sequence"];
    
    NSArray *animationSequence = [NSArray arrayWithObjects:[UIImage new], [UIImage new], [UIImage new], [UIImage new], [UIImage new], nil];
    self.expectedDelegateUpdateCallbacks = animationSequence.count;
    
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] init];
    operation.animationDuration = 0.5;
    operation.delegate = self;
    operation.animationSequence = animationSequence;
    self.delegateFinish = 1;
    
    [self.operationQueue addOperation:operation];
    operation.completionBlock = ^
    {
        if (self.expectedDelegateUpdateCallbacks == 0)
        {
            [self.expectation fulfill];
        }
    };
    [self waitForExpectation];
}

- (void)testEmptyAnimationSequence
{
    self.expectation = [self expectationWithDescription:@"Empty animation sequence"];
    
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] init];
    operation.animationDuration = 1.0;
    operation.delegate = self;
    self.delegateFinish = 1;
    [self.operationQueue addOperation:operation];
    
    operation.completionBlock = ^
    {
        if (self.expectedDelegateUpdateCallbacks == 0)
        {
            [self.expectation fulfill];
        }
    };
    
    [self waitForExpectation];
}

- (void)testStopAnimation
{
    self.expectation = [self expectationWithDescription:@"Cancel animation sequence"];
    
    NSArray *animationSequence = [NSArray arrayWithObjects:[UIImage new], [UIImage new], [UIImage new], [UIImage new], [UIImage new], nil];
    self.expectedDelegateUpdateCallbacks = animationSequence.count;
    
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] init];
    operation.animationDuration = 5.0;
    operation.delegate = self;
    operation.animationSequence = animationSequence;
    self.delegateFinish = -1;
    
    [self.operationQueue addOperation:operation];
    
    __weak typeof(operation) weakOperation = operation;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakOperation) strongOperation = weakOperation;
        [strongOperation stopAnimating];
    });
    
    [self waitForExpectation];
}

- (void)testCancelAnimationQueue
{
    self.expectation = [self expectationWithDescription:@"Cancel animation sequence"];
    
    NSArray *animationSequence = [NSArray arrayWithObjects:[UIImage new], [UIImage new], [UIImage new], [UIImage new], [UIImage new], nil];
    self.expectedDelegateUpdateCallbacks = animationSequence.count;
    
    
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] init];
    operation.animationDuration = 5.0;
    operation.delegate = self;
    operation.animationSequence = animationSequence;
    self.delegateFinish = -1;
    
    [self.operationQueue addOperation:operation];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.operationQueue cancelAllOperations];
    });
    
    [self waitForExpectation];
}

@end
