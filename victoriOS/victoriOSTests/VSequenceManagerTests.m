//
//  VSequenceManagerTests.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VObjectManager.h"
#import "XCTestRestKit.h"

@interface VSequenceManagerTests : XCTestCase
@end

@implementation VSequenceManagerTests

+ (void)setUp
{
    [super setUp];

    [VObjectManager setupObjectManager];
}

- (void)testLoadSequenceCategories
{
    __block NSError *resultError;
//    __block NSArray *resultArray;
//    XCTestRestKitStartOperation([VSequenceManager loadSequenceCategoriesWithBlock:^(NSArray *categories, NSError *error){
//        resultError = error;
//        resultArray = categories;
//        XCTestRestKitEndOperation();
//    }]);
//
    XCTAssertNil(resultError, @"Error: %@", resultError);
}

@end
