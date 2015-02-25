//
//  VTagTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VDependencyManager.h"
#import "VThemeManager.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VTag.h"
#import "VDummyModels.h"

#warning ADD TESTS FOR REMOTE ID FIELD

@interface VTagTests : XCTestCase

@property (nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSArray *users;
@property (nonatomic) NSArray *hashtags;
@property (nonatomic) NSString *userFormatString;
@property (nonatomic) NSString *hashtagFormatString;
@property (nonatomic) NSMutableAttributedString *randomAttributedString;
@property (nonatomic) NSDictionary *tagStringAttributes;
@property (nonatomic) NSString *randomStringAfterReplacing;

@end

@implementation VTagTests

- (void)setUp
{
    [super setUp];
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:configuration dictionaryOfClassesByTemplateName:nil];
    self.dependencyManager = [[VDependencyManager alloc] init];
    self.users = [VDummyModels createUsers:4];
    self.hashtags = [VDummyModels createHashtags:6];
    self.userFormatString = @"@{%@:%@}";
    self.hashtagFormatString = @"#%@";
    self.tagStringAttributes = @{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont fontWithName:@"helvetica" size:12.0]};
    
    NSString *randomString = @"rand";
    NSString *startString = @"";
    NSString *resultString = @"";
    for (VUser *user in self.users)
    {
        startString = [startString stringByAppendingString:[NSString stringWithFormat:self.userFormatString, [user.remoteId stringValue], user.name]];
        resultString = [resultString stringByAppendingString:user.name];
        startString = [startString stringByAppendingString:randomString];
        resultString = [resultString stringByAppendingString:randomString];
    }
    for (VHashtag *hashtag in self.hashtags)
    {
        NSString *hashtagString = [NSString stringWithFormat:self.hashtagFormatString, hashtag.tag];
        startString = [startString stringByAppendingString:hashtagString];
        resultString = [resultString stringByAppendingString:hashtagString];
        startString = [startString stringByAppendingString:randomString];
        resultString = [resultString stringByAppendingString:randomString];
    }
    
    self.randomAttributedString = [[NSMutableAttributedString alloc] initWithString:startString];
    self.randomStringAfterReplacing = resultString;
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.users = nil;
    self.hashtags = nil;
    self.userFormatString = nil;
    self.hashtagFormatString = nil;
    self.dependencyManager = nil;
    [super tearDown];
}

- (void)testTagWithUser
{
    VUser *user = [self.users lastObject];
    VTag *tag = [VTag tagWithUser:user andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag.displayString.string isEqualToString:user.name], @"displayString should be the user's name");
    NSString *userString = [NSString stringWithFormat:self.userFormatString, [user.remoteId stringValue], user.name];
    XCTAssertTrue([tag.databaseFormattedString isEqualToString:userString], @"databaseFormattedString should be of format @{remoteId:name}");
    XCTAssertThrows([VTag tagWithUser:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithUser:user andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

- (void)testTagWithHashtag
{
    VHashtag *hashtag = [self.hashtags lastObject];
    VTag *tag = [VTag tagWithHashtag:hashtag andTagStringAttributes:self.tagStringAttributes];
    NSString *hashtagString = [NSString stringWithFormat:self.hashtagFormatString, hashtag.tag];
    XCTAssertTrue([tag.displayString.string isEqualToString:hashtagString], @"displayString should be of the format #tag");
    XCTAssertTrue([tag.databaseFormattedString isEqualToString:hashtagString], @"databaseFormatString should be of the format #tag");
    XCTAssertThrows([VTag tagWithHashtag:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithHashtag:hashtag andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

- (void)testTagWithDatabaseFormattedUserString
{
    VUser *user = [self.users lastObject];
    NSString *userString = [NSString stringWithFormat:self.userFormatString, [user.remoteId stringValue], user.name];
    VTag *tag = [VTag tagWithUserString:userString andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag.displayString.string isEqualToString:user.name], @"displayString should be the user's name");
    XCTAssertTrue([tag.databaseFormattedString isEqualToString:userString], @"databaseFormattedString should be of format @{remoteId:name}");
    XCTAssertThrows([VTag tagWithUser:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithUser:user andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

- (void)testTagWithDatabaseFormattedHashtagString
{
    VHashtag *hashtag = [self.hashtags lastObject];
    NSString *hashtagString = [NSString stringWithFormat:self.hashtagFormatString, hashtag.tag];
    VTag *tag = [VTag tagWithHashtagString:hashtagString andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag.displayString.string isEqualToString:hashtagString], @"displayString should be of the format #tag");
    XCTAssertTrue([tag.databaseFormattedString isEqualToString:hashtagString], @"databaseFormatString should be of the format #tag");
    XCTAssertThrows([VTag tagWithHashtag:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithHashtag:hashtag andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

@end
