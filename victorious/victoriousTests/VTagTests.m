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
#import "VTag.h"
#import "VUserTag.h"
#import "VDummyModels.h"
#import "victorious-Swift.h"

@interface VTagTests : XCTestCase

@property (nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSArray *users;
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
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:@{ } dictionaryOfClassesByTemplateName:@{ }];
    self.users = [VDummyModels createUsers:4];
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
    
    self.randomAttributedString = [[NSMutableAttributedString alloc] initWithString:startString];
    self.randomStringAfterReplacing = resultString;
}

- (void)tearDown
{
    self.users = nil;
    self.userFormatString = nil;
    self.hashtagFormatString = nil;
    self.dependencyManager = nil;
    [super tearDown];
}

- (void)testInit
{
    NSString *displayString = @"display_string";
    NSString *databaseFormattedString = @"database_formatted_string";
    XCTAssertNil([[VTag alloc] initWithDisplayString:nil databaseFormattedString:databaseFormattedString andTagStringAttributes:self.tagStringAttributes], @"should return nil for nil displayString");
    XCTAssertNil([[VTag alloc] initWithDisplayString:displayString databaseFormattedString:nil andTagStringAttributes:self.tagStringAttributes], @"should return nil for nil databaseFormattedString");
    XCTAssertNil([[VTag alloc] initWithDisplayString:displayString databaseFormattedString:databaseFormattedString andTagStringAttributes:nil], @"should return nil for nil tagStringAttributes");

    
    VTag *tag = [[VTag alloc] initWithDisplayString:displayString
                            databaseFormattedString:databaseFormattedString
                             andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag.displayString isEqualToAttributedString:[[NSAttributedString alloc] initWithString:displayString attributes:self.tagStringAttributes]], @"display string should have tagString formatting");
    XCTAssertTrue([tag.databaseFormattedString isEqualToString:databaseFormattedString], @"databaseFormattedString should equal provided databaseFormattedString");
    XCTAssertTrue([tag.tagStringAttributes isEqual:self.tagStringAttributes], @"tagStringAttributes should equal provided tagStringAttributes");
}

- (void)testTagWithUser
{
    VUser *user = [self.users lastObject];
    VTag *tag = [VTag tagWithUser:user andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag isKindOfClass:[VUserTag class]], @"returned tag should be a VUserTag");
    
    VUserTag *userTag = (VUserTag *)tag;
    XCTAssertTrue([userTag.displayString.string isEqualToString:user.name], @"displayString should be the user's name");
    XCTAssertTrue([userTag.remoteId isEqualToNumber:user.remoteId], @"remoteId should be the user's remoteId");
    NSString *userString = [NSString stringWithFormat:self.userFormatString, [user.remoteId stringValue], user.name];
    XCTAssertTrue([userTag.databaseFormattedString isEqualToString:userString], @"databaseFormattedString should be of format @{remoteId:name}");
    XCTAssertThrows([VTag tagWithUser:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithUser:user andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

- (void)testTagWithDatabaseFormattedUserString
{
    VUser *user = [self.users lastObject];
    NSString *userString = [NSString stringWithFormat:self.userFormatString, [user.remoteId stringValue], user.name];
    VTag *tag = [VTag tagWithUserString:userString andTagStringAttributes:self.tagStringAttributes];
    XCTAssertTrue([tag isKindOfClass:[VUserTag class]], @"returned tag should be a VUserTag");
    
    VUserTag *userTag = (VUserTag *)tag;
    XCTAssertTrue([userTag.displayString.string isEqualToString:user.name], @"displayString should be the user's name");
    XCTAssertTrue([userTag.remoteId isEqualToNumber:user.remoteId], @"remoteId should be the user's remoteId");
    XCTAssertTrue([userTag.databaseFormattedString isEqualToString:userString], @"databaseFormattedString should be of format @{remoteId:name}");
    XCTAssertThrows([VTag tagWithUser:nil andTagStringAttributes:self.tagStringAttributes], @"should throw exception for nil user");
    XCTAssertThrows([VTag tagWithUser:user andTagStringAttributes:nil], @"should throw exception for nil tagStringAttributes");
}

@end
