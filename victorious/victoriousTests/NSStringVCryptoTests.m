//
//  NSStringVCryptoTests.m
//  victorious
//
//  Created by Josh Hinman on 9/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VCrypto.h"

#import <XCTest/XCTest.h>

@interface NSStringVCryptoTests : XCTestCase

@property (nonatomic, copy) NSString *input;

@end

@implementation NSStringVCryptoTests

- (void)setUp
{
    [super setUp];
    self.input = @"Rubber Baby Buggy Bumpers";
}

- (void)testSHA256
{
    NSString *hash = [self.input v_sha256];
    XCTAssertEqualObjects(hash, @"f0fe71e6da618e2a02b89a91a836b26525d9dc0495ef6ee2b29cb1f31e9ad90c");
}

@end
