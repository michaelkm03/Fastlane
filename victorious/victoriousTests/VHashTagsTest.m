//
//  VHashTagsTest.m
//  victorious
//
//  Created by Patrick Lynch on 10/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VHashTags.h"
#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>

@interface VHashTagsTest : XCTestCase
{
    NSString *stringWithHashTag_;
    NSString *stringWithOutHashTag_;
    NSString *stringWith3HashTags_;
    NSDictionary *testAttributes_;
}

@end

@implementation VHashTagsTest

- (void)setUp
{
    [super setUp];
    
    stringWithOutHashTag_ = @"This is text without a hash tag";
    stringWithHashTag_ = @"This is text with a #hashtag";
    stringWith3HashTags_  = @"This is text with #hashtag1 #hashtag2 #hashtag3";
    
    testAttributes_ = @{ NSForegroundColorAttributeName: [UIColor redColor] };
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)stringWithNumberOfHashTags:(NSUInteger)numTags
{
    NSString *output = [[NSString alloc] init];
    for ( NSUInteger t = 0; t < numTags; t++ )
    {
        NSString *hashTag = [NSString stringWithFormat:@"#tag_%lu ", (unsigned long)t];
        output = [output stringByAppendingString:hashTag];
    }
    return output;
}

- (void)testHashTag
{
    NSArray *hashTags = [VHashTags detectHashTags:stringWithHashTag_];
    XCTAssertEqual( hashTags.count, (NSUInteger)1 );
    NSRange resultRange = ((NSValue *)hashTags[0]).rangeValue;
    NSRange expectedRange = [stringWithHashTag_ rangeOfString:@"hashtag"];
    XCTAssertEqual( resultRange.location, expectedRange.location );
    XCTAssertEqual( resultRange.length, expectedRange.length );
}

- (void)test3HashTags
{
    NSArray *hashTags = [VHashTags detectHashTags:stringWith3HashTags_];
    NSArray *expectedHashTags = @[ @"hashtag1",  @"hashtag2",  @"hashtag3" ];
    XCTAssertEqual( hashTags.count, expectedHashTags.count );
    for ( NSUInteger i = 0; i < expectedHashTags.count; i++ )
    {
        NSRange resultRange = ((NSValue *)hashTags[i]).rangeValue;
        NSRange expectedRange = [stringWith3HashTags_ rangeOfString:expectedHashTags[i]];
        XCTAssertEqual( resultRange.location, expectedRange.location );
        XCTAssertEqual( resultRange.length, expectedRange.length );
    }
}

- (void)testNoHashTag
{
    NSArray *hashTags = [VHashTags detectHashTags:stringWithOutHashTag_];
    XCTAssertNotNil( hashTags );
    XCTAssertEqual( hashTags.count, (NSUInteger)0 );
}

- (void)testMultipleHashTags
{
    NSUInteger numTests = 50;
    for ( NSUInteger i = 0; i < numTests; i++ )
    {
        NSUInteger numTags = arc4random() % 100;
        NSString *str = [self stringWithNumberOfHashTags:numTags];
        NSArray *hashTags = [VHashTags detectHashTags:str];
        XCTAssertEqual( hashTags.count, numTags );
    }
}

- (void)testInvalidInput
{
    NSArray *hashTags = [VHashTags detectHashTags:nil];
    XCTAssertNil( hashTags );
}

- (void)testEmptyInput
{
    NSArray *hashTags = [VHashTags detectHashTags:@""];
    XCTAssertEqual( hashTags.count, (NSUInteger)0 );
    XCTAssertNotNil( hashTags );
}

- (void)testFormat
{
    NSString *string = @"Caption that includes a #hashtag";
    NSArray *hashTags = [VHashTags detectHashTags:string];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    XCTAssert( [VHashTags formatHashTagsInString:attributedString withTagRanges:hashTags attributes:testAttributes_] );
    
    NSRange expectedAttributedRange = [string rangeOfString:@"#hashtag"];
    for ( NSUInteger i = 0; i < attributedString.length; i++ )
    {
        NSRange range;
        NSDictionary *attributes = [attributedString attributesAtIndex:i effectiveRange:&range];
        XCTAssertNotNil( attributes);
        
        if ( NSLocationInRange( i, expectedAttributedRange) )
        {
            XCTAssertEqual( attributes.allKeys.count, (NSUInteger)1, @"Expecting attributes at index: %lu", (unsigned long)i );
            for ( NSString *key in attributes.allKeys )
            {
                XCTAssertEqual( key, NSForegroundColorAttributeName );
            }
        }
        else
        {
            XCTAssertEqual( attributes.allKeys.count, (NSUInteger)0, @"NOT expecting attributes at index: %lu", (unsigned long)i );
        }
    }
}

- (void)testFormatInvalidInputs
{
    NSString *string = @"Caption that includes a #hashtag";
    NSArray *hashTags = [VHashTags detectHashTags:string];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableAttributedString *emptyString = [[NSMutableAttributedString alloc] init];
    
    // Make sure no errors
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:nil withTagRanges:hashTags attributes:testAttributes_] );
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:emptyString withTagRanges:hashTags attributes:testAttributes_] );
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:attributedString withTagRanges:nil attributes:testAttributes_] );
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:attributedString withTagRanges:@[] attributes:testAttributes_] );
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:attributedString withTagRanges:hashTags attributes:nil] );
    XCTAssertNoThrow( [VHashTags formatHashTagsInString:attributedString withTagRanges:hashTags attributes:@{}] );
    
    // Make sure return values are false
    XCTAssertFalse( [VHashTags formatHashTagsInString:nil withTagRanges:hashTags attributes:testAttributes_] );
    XCTAssertFalse( [VHashTags formatHashTagsInString:emptyString withTagRanges:hashTags attributes:testAttributes_] );
    XCTAssertFalse( [VHashTags formatHashTagsInString:attributedString withTagRanges:nil attributes:testAttributes_] );
    XCTAssertFalse( [VHashTags formatHashTagsInString:attributedString withTagRanges:@[] attributes:testAttributes_] );
    XCTAssertFalse( [VHashTags formatHashTagsInString:attributedString withTagRanges:hashTags attributes:nil] );
    XCTAssertFalse( [VHashTags formatHashTagsInString:attributedString withTagRanges:hashTags attributes:@{}] );
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
