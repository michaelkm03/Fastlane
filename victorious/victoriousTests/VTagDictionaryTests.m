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

@end

@implementation VTagDictionaryTests

- (void)setUp
{
    [super setUp];
    self.userTags = [VDummyModels createUserTags:4];
}

- (void)tearDown
{
    self.userTags = nil;
    [super tearDown];
}

- (void)testInit
{
    XCTAssertNoThrow([VTagDictionary tagDictionaryWithTags:nil], @"tag dictionary should not throw exception when a nil tag array is passed into init");
    
    VTagDictionary *tagDictionary = [VTagDictionary tagDictionaryWithTags:nil];
    XCTAssertNotNil(tagDictionary, @"tag dictionary should return an empty dictionary, not nil, when no tags are passed in");
}

- (void)testGetTagsArray
{
    VTagDictionary *tagDictionary = [[VTagDictionary alloc] init];
    XCTAssertNil([tagDictionary tags], @"tag dictionary should return a nil tags array if there are no tags stored in the dictionary");
}

- (void)testTagForKey
{
    VTagDictionary *tagDictionary = [[VTagDictionary alloc] init];
    XCTAssertNoThrow([tagDictionary tagForKey:nil], @"tag dictionary should not throw exception when nil key is passed into tagForKey");
    
    VTag *tag = [tagDictionary tagForKey:nil];
    XCTAssertNil(tag, @"tag dictionary should return nil if no tags are stored in the dictionary");
    
    tag = [tagDictionary tagForKey:@"random"];
    XCTAssertNil(tag, @"tag dictionary should return nil if no tagForKey is passed a key that doesn't match any stored tags");
}

- (void)testCount
{
    VTagDictionary *tagDictionary = [VTagDictionary tagDictionaryWithTags:self.userTags];
    XCTAssertTrue([tagDictionary count] == self.userTags.count, @"tag dictionary should contain same number of unique tags passed into init");
    
    tagDictionary = [VTagDictionary tagDictionaryWithTags:[self.userTags arrayByAddingObjectsFromArray:self.userTags]];
    XCTAssertTrue([tagDictionary count] == self.userTags.count, @"tag dictionary should not add extra entries for duplicate tags");
}

@end
