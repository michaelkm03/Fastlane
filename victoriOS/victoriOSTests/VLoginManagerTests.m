//
//  VLoginManagerTests.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VAPIManager.h"
#import "VLoginManager.h"
#import "XCTestRestKit.h"

@interface VLoginManagerTests : XCTestCase
@end

@implementation VLoginManagerTests

+ (void)setUp
{
    [super setUp];

    [VAPIManager setupRestKit];
}

- (void)testCreateAccount
{
    __block NSError *resultError;
    __block NSArray *resultArray;
    XCTestRestKitStartOperation([VLoginManager createVictoriousAccountWithEmail:@"c" password:@"c" name:@"b" block:^(NSArray *categories, NSError *error){
        resultError = error;
        resultArray = categories;
        XCTestRestKitEndOperation();
    }]);

    XCTAssertNil(resultError, @"Error: %@", resultError);
}

@end
