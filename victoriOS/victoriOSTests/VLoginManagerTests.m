//
//  VLoginManagerTests.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "VObjectManager+Login.h"
#import "VObjectManager.h"
#import "XCTestRestKit.h"
#import "VUser+RestKit.h"

@interface VLoginManagerTests : XCTestCase
@end

@implementation VLoginManagerTests

+ (void)setUp
{
    [super setUp];

    [VObjectManager setupObjectManager];
}

- (void)testCreateAccount
{
    __block VUser *resultUser;
    __block NSError *resultError;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    RKManagedObjectRequestOperation *o =
    [VObjectManager createVictoriousAccountWithEmail:@"aa@a.com" password:@"a" name:@"a" block:^(VUser *user, NSError *error){
        resultUser = user;
        resultError = error;
        dispatch_semaphore_signal(semaphore);
    }];

    o.failureCallbackQueue = queue;
    o.successCallbackQueue = queue;
    [o start];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    XCTFail(@"Fail");
//    XCTAssertNil(resultError, @"Error: %@", resultError);
}

@end
