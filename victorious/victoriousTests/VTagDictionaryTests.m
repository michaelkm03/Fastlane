//
//  VTagDictionaryTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTagDictionary.h"
#import "VTag.h"
#import "VDummyModels.h"

//Open to any suggestions for better ways to define the API contract or split up testing functionality

@interface VTagDictionaryTests : XCTestCase

@property (nonatomic) NSArray *userTags;
@property (nonatomic) NSArray *hashtagTags;
@property (nonatomic) NSArray *testTags;

@end

@implementation VTagDictionaryTests

- (void)setUp
{
    [super setUp];
    self.userTags = [VDummyModels createUserTags:4];
    self.hashtagTags = [VDummyModels createHashtagTags:2];
    self.testTags = [self.userTags arrayByAddingObject:[self.hashtagTags lastObject]];
}

- (void)tearDown
{
    self.userTags = nil;
    self.hashtagTags = nil;
    self.testTags = nil;
    [super tearDown];
}

- (void)testInit
{
    XCTAssertNoThrow([VTagDictionary tagDictionaryWithTags:nil], @"tag dictionary should not throw exception when a nil tag array is passed into init");
    
    VTagDictionary *tagDictionary = [VTagDictionary tagDictionaryWithTags:nil];
    XCTAssertNotNil(tagDictionary, @"tag dictionary should return an empty dictionary, not nil, when no tags are passed in");

    for ( VTag *testTag in self.testTags )
    {
        tagDictionary = [VTagDictionary tagDictionaryWithTags:@[testTag]];
        XCTAssertNotNil(tagDictionary, @"tag dictionary should not be nil when valid tags array is passed in");
    }
}

- (void)testIncrementTag
{
    for ( VTag *testTag in self.testTags)
    {
        VTagDictionary *tagDictionary = [[VTagDictionary alloc] init];
        [tagDictionary incrementTag:testTag];
        XCTAssertTrue([tagDictionary count] == 1, @"tag dictionary should only contain the single added tag after increment");
        
        [tagDictionary incrementTag:testTag];
        XCTAssertTrue([tagDictionary count] == 1, @"tag dictionary shouldn't add a separate entry after incrementing an already present tag");
        
        XCTAssertNoThrow([tagDictionary incrementTag:nil], @"tag dictionary should not throw an exception when trying to increment nil tag");
    }
}

- (void)testDecrementTag
{
    for ( VTag *testTag in self.testTags)
    {
        VTagDictionary *tagDictionary = [VTagDictionary tagDictionaryWithTags:@[testTag, testTag]];
        NSString *tagKey = [VTagDictionary keyForTag:testTag];
        [tagDictionary decrementTagWithKey:tagKey];
        XCTAssertTrue([tagDictionary count] == 1, @"tag dictionary should not remove tag when its numberOfOccurrences is > 0");
        
        [tagDictionary decrementTagWithKey:tagKey];
        XCTAssertTrue([tagDictionary count] == 0, @"tag dictionary should remove tag when its numberOfOccurrences is 0");
        
        XCTAssertNoThrow([tagDictionary decrementTagWithKey:tagKey], @"tag dictionary should not throw an exception when trying to decrement tag that is not in the dictionary");
        XCTAssertNoThrow([tagDictionary decrementTagWithKey:nil], @"tag dictionary should not throw an exception when trying to decrement tag with nil key");
    }
}

- (void)testGetTagsArray
{
    VTagDictionary *tagDictionary = [[VTagDictionary alloc] init];
    XCTAssertNil([tagDictionary tags], @"tag dictionary should return a nil tags array if there are no tags stored in the dictionary");
    
    for ( VTag *testTag in self.testTags)
    {
        tagDictionary = [VTagDictionary tagDictionaryWithTags:@[testTag, testTag]];
        NSArray *tags = [tagDictionary tags];
        XCTAssertTrue(tags.count == 1, @"tag dictionary should not have duplicate entries for tags that have been passed in more than once");
        XCTAssertTrue([[tags lastObject] isEqual:testTag], @"returned tag should be the tag stored in the dictionary");
    }
}

- (void)testTagForKey
{
    VTagDictionary *tagDictionary = [[VTagDictionary alloc] init];
    XCTAssertNoThrow([tagDictionary tagForKey:nil], @"tag dictionary should not throw exception when nil key is passed into tagForKey");
    
    VTag *tag = [tagDictionary tagForKey:nil];
    XCTAssertNil(tag, @"tag dictionary should return nil if no tags are stored in the dictionary");
    
    tag = [tagDictionary tagForKey:@"random"];
    XCTAssertNil(tag, @"tag dictionary should return nil if no tagForKey is passed a key that doesn't match any stored tags");
    
    for ( VTag *testTag in self.testTags )
    {
        tagDictionary = [VTagDictionary tagDictionaryWithTags:@[testTag, testTag]];
        NSString *key = [VTagDictionary keyForTag:testTag];
        XCTAssertTrue([[tagDictionary tagForKey:key] isEqual:testTag], @"tag returned by tagForKey should be equivalent to tag stored in dictionary");
    }
}

- (void)testKeyForTag
{
    for ( VTag *testTag in self.testTags )
    {
        NSString *key = [VTagDictionary keyForTag:testTag];
        XCTAssertTrue([key isEqualToString:testTag.displayString.string], @"key should be the display string of the provided tag");
    }
}

- (void)testCount
{
    VTagDictionary *tagDictionary = [VTagDictionary tagDictionaryWithTags:self.userTags];
    XCTAssertTrue([tagDictionary count] == self.userTags.count, @"tag dictionary should contain same number of unique tags passed into init");
    
    tagDictionary = [VTagDictionary tagDictionaryWithTags:[self.userTags arrayByAddingObjectsFromArray:self.userTags]];
    XCTAssertTrue([tagDictionary count] == self.userTags.count, @"tag dictionary should not add extra entries for duplicate tags");
}

@end
