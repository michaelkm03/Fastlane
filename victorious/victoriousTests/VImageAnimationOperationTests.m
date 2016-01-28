//
//  VImageAnimationOperationTests.m
//  victorious
//
//  Created by Vincent Ho on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "victorious-Swift.h"

@interface VImageAnimationOperationTests : XCTestCase

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation VImageAnimationOperationTests

- (void)setUp
{
    [super setUp];
    _operationQueue = [NSOperationQueue new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.operationQueue cancelAllOperations];
    [super tearDown];
}

- (void)testSingleNilAnimationSequence
{
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    // Don't set any animation sequence
    XCTAssertFalse([operation isAnimating]);
    XCTAssert([operation completedAnimation]);
    
    [self.operationQueue addOperation:operation];
    
    // Should not have started animating
    XCTAssertFalse([operation isAnimating]);
    XCTAssert([operation completedAnimation]);
    XCTAssertFalse(operation.executing);
}

- (void)testSingleValidAnimationSequence
{
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    operation.animationSequence = [NSArray arrayWithObjects:[UIImage new], [UIImage new], [UIImage new], [UIImage new], [UIImage new], nil];
    operation.animationDuration = 1.0;
    
    [self.operationQueue addOperation:operation];
    
    __weak typeof(operation) wOperation = operation;
    operation.completionBlock = ^{
        __strong typeof(wOperation) sOperation = wOperation;
        XCTAssertFalse([sOperation isAnimating]);
        XCTAssert([sOperation completedAnimation]);
    };
}

- (void)testSingleEmptyAnimationSequence
{
    VImageAnimationOperation *operation = [[VImageAnimationOperation alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    operation.animationSequence = [NSArray new];
    operation.animationDuration = 1.0;
    
    [self.operationQueue addOperation:operation];
    
    __weak typeof(operation) wOperation = operation;
    operation.completionBlock = ^{
        __strong typeof(wOperation) sOperation = wOperation;
        XCTAssertFalse([sOperation isAnimating]);
        XCTAssert([sOperation completedAnimation]);
    };
}

@end
