//
//  VLoginManagerTests.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VObjectManager+Login.h"
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
    XCTestRestKitStartOperation([VObjectManager createVictoriousAccountWithEmail:@"aa@a.com" password:@"a" name:@"a" block:^(VUser *user, NSError *error){
        resultUser = user;
        resultError = error;
        XCTestRestKitEndOperation();
    }]);

    XCTAssertNil(resultError, @"Error: %@", resultError);
}

@end
