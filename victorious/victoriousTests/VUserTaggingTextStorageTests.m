//
//  VUserTaggingTextStorageTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VUserTaggingTextStorage.h"
#import "VDummyModels.h"
#import "VUser.h"
#import "VHashtag.h"

@interface VUserTaggingTextStorageTests : XCTestCase

@property (nonatomic) NSString *testStringFormat;
@property (nonatomic) NSString *displayFormattedString;
@property (nonatomic) NSString *databaseFormattedString;

@end

@implementation VUserTaggingTextStorageTests

- (void)setUp
{
    [super setUp];
    VUser *user = [[VDummyModels createUsers:1] lastObject];
    VHashtag *hashtag = [[VDummyModels createHashtags:1] lastObject];
    self.testStringFormat = @"test user : %@, test hashtag : %@";
    
    char cString[] = "\u200B";
    NSData *data = [NSData dataWithBytes:cString length:strlen(cString)];
    NSString *delimiterString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *wrappedUser = [[delimiterString stringByAppendingString:user.name] stringByAppendingString:delimiterString];
    NSString *wrappedHashtag = [[delimiterString stringByAppendingString:[NSString stringWithFormat:@"#%@", hashtag.tag]] stringByAppendingString:delimiterString];
    self.displayFormattedString = [NSString stringWithFormat:self.testStringFormat, wrappedUser, wrappedHashtag];
    self.databaseFormattedString = [NSString stringWithFormat:self.testStringFormat, [NSString stringWithFormat:@"@{%@:%@}", [user.remoteId stringValue], user.name], [NSString stringWithFormat:@"#%@", hashtag.tag]];
}

- (void)tearDown
{
    self.testStringFormat = nil;
    self.displayFormattedString = nil;
    self.databaseFormattedString = nil;
    [super tearDown];
}

- (void)testInit
{
    XCTAssertNoThrow([[VUserTaggingTextStorage alloc] initWithString:nil
                                                            textView:nil
                                                     taggingDelegate:nil], @"should not throw error for nil init fields");
    
    UITextView *textView = [[UITextView alloc] init];
    VUserTaggingTextStorage *textStorage = [[VUserTaggingTextStorage alloc] initWithString:self.databaseFormattedString
                                                                                  textView:textView
                                                                           taggingDelegate:nil];
    XCTAssertTrue([self.displayFormattedString isEqualToString:textStorage.string], @"text storage didn't automatically create display-formatted string after init with string");
}

- (void)testDatabaseFormattedString
{
    //Would love to get the init taken out of here, but how the string is formatted is tied to this init call
    VUserTaggingTextStorage *textStorage = [[VUserTaggingTextStorage alloc] initWithString:self.databaseFormattedString
                                                                                  textView:nil
                                                                           taggingDelegate:nil];
    
    NSString *resultString = [textStorage databaseFormattedString];
    XCTAssertNil(resultString, @"Database formatted string should return nil when textView is nil");
    
    UITextView *textView = [[UITextView alloc] init];
    textStorage = [[VUserTaggingTextStorage alloc] initWithString:self.databaseFormattedString
                                                         textView:textView
                                                  taggingDelegate:nil];
    
    resultString = [textStorage databaseFormattedString];
    XCTAssertTrue([resultString isEqualToString:self.databaseFormattedString], @"creation of database formatted string failed");
}

@end
