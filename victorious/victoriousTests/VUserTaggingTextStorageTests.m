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
#import "victorious-Swift.h"

@interface VUserTaggingTextStorageTests : XCTestCase

@property (nonatomic) NSString *testStringFormat;
@property (nonatomic) NSString *displayFormattedString;
@property (nonatomic) NSString *databaseFormattedString;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIFont *defaultFont;

@end

@implementation VUserTaggingTextStorageTests

- (void)setUp
{
    [super setUp];
    VUser *user = [[VDummyModels createUsers:1] lastObject];
    self.testStringFormat = @"test user : %@, test hashtag : %@";
    
    char cString[] = "\u200B";
    NSData *data = [NSData dataWithBytes:cString length:strlen(cString)];
    NSString *delimiterString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *sampleTag = @"tag";
    NSString *wrappedUser = [[delimiterString stringByAppendingString:user.name] stringByAppendingString:delimiterString];
    NSString *wrappedHashtag = [[delimiterString stringByAppendingString:[NSString stringWithFormat:@"#%@", sampleTag]] stringByAppendingString:delimiterString];
    self.displayFormattedString = [NSString stringWithFormat:self.testStringFormat, wrappedUser, wrappedHashtag];
    self.databaseFormattedString = [NSString stringWithFormat:self.testStringFormat, [NSString stringWithFormat:@"@{%@:%@}", [user.remoteId stringValue], user.name], [NSString stringWithFormat:@"#%@", sampleTag]];
    
    self.textView = [[UITextView alloc] init];
    self.defaultFont = [UIFont systemFontOfSize:13.0f];
    self.textView.text = self.databaseFormattedString;
}

- (void)tearDown
{
    self.testStringFormat = nil;
    self.displayFormattedString = nil;
    self.databaseFormattedString = nil;
    self.textView = nil;
    self.defaultFont = nil;
    [super tearDown];
}

- (void)testInit
{
    VDependencyManager *testDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
    
    XCTAssertNoThrow([[VUserTaggingTextStorage alloc] initWithTextView:nil
                                                           defaultFont:self.defaultFont
                                                       taggingDelegate:nil
                                                     dependencyManager:testDependencyManager], @"should not throw error for nil taggingDelegate or textView fields");
    
    XCTAssertThrows([[VUserTaggingTextStorage alloc] initWithTextView:self.textView
                                                           defaultFont:nil
                                                       taggingDelegate:nil
                                                    dependencyManager:testDependencyManager], @"should throw error for nil defaultFont");
    
    VUserTaggingTextStorage *textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:self.textView
                                                                                 defaultFont:self.defaultFont
                                                                             taggingDelegate:nil
                                                                           dependencyManager:testDependencyManager];
    XCTAssertTrue([self.displayFormattedString isEqualToString:textStorage.string], @"text storage didn't automatically create display-formatted string after init with string");
    XCTAssertTrue([self.defaultFont isEqual:textStorage.defaultFont], @"DefaultFont should be equivalent to passed in defaultFont");
}

- (void)testDatabaseFormattedString
{
    VDependencyManager *testDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];

    //Would love to get the init taken out of here, but how the string is formatted is tied to this init call
    VUserTaggingTextStorage *textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:nil
                                                                                 defaultFont:self.defaultFont
                                                                             taggingDelegate:nil
                                                                           dependencyManager:testDependencyManager];
    
    NSString *resultString = [textStorage databaseFormattedString];
    XCTAssertNil(resultString, @"Database formatted string should return nil when textView is nil");
    
    textStorage = [[VUserTaggingTextStorage alloc] initWithTextView:self.textView
                                                        defaultFont:self.defaultFont
                                                    taggingDelegate:nil
                                                  dependencyManager:testDependencyManager];
    
    resultString = [textStorage databaseFormattedString];
    XCTAssertTrue([resultString isEqualToString:self.databaseFormattedString], @"creation of database formatted string failed");
}

@end
