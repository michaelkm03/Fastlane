//
//  VHashtagsTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VHashTags.h"

@interface VHashtagsTests : XCTestCase

@end

@implementation VHashtagsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPrependHashmark
{
    NSString *string = @"test";
    NSString *expected = [NSString stringWithFormat:@"#%@", string];
    
    XCTAssert( [[VHashTags stringWithPrependedHashmarkFromString:string] isEqualToString:expected] );
}

- (void)testPrependHashmarkWithHashAlreadyPresent
{
    NSString *string = @"#test";
    XCTAssert( [[VHashTags stringWithPrependedHashmarkFromString:string] isEqualToString:string] );
}

- (void)testPrependHashmarkInvalidInput
{
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:@"with space"] );
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:@"with some spaces"] );
    
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:@"with-dash"] );
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:@"with-many-dashes"] );
    
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:@""] );
    
    XCTAssertNil( [VHashTags stringWithPrependedHashmarkFromString:nil] );
}

@end
