//
//  VTagStringFormatterTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTagStringFormatter.h"
#import "VTagDictionary.h"
#import "VDummyModels.h"
#import "VTag.h"
#import "victorious-Swift.h"

@interface VTagStringFormatterTests : XCTestCase

@property (nonatomic) NSMutableAttributedString *databaseFormattedString;
@property (nonatomic) NSMutableAttributedString *displayFormattedString;
@property (nonatomic) NSDictionary *defaultStringAttributes;
@property (nonatomic) NSDictionary *tagStringAttributes;
@property (nonatomic) NSString *delimiterString;
@property (nonatomic) NSString *databaseFormattedUser;
@property (nonatomic) NSString *databaseFormattedHashtag;
@property (nonatomic) VUser *user;
@property (nonatomic) VTag *userTag;
@property (nonatomic) VTag *hashtagTag;
@property (nonatomic) NSArray *tags;
@property (nonatomic) VTagDictionary *tagDictionary;

@end

@implementation VTagStringFormatterTests

- (void)setUp
{
    [super setUp];
    UIFont *font = [UIFont fontWithName:@"helvetica" size:10.0];
    self.defaultStringAttributes = @{NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : [UIColor blackColor]};
    self.tagStringAttributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : [UIColor redColor]};
    
    self.user = [[VDummyModels createUsers:1] lastObject];
    
    NSString *userName = self.user.name;
    NSString *hashtagTag = @"tag";
    
    self.databaseFormattedUser = [NSString stringWithFormat:@"@{%@:%@}", self.user.remoteId, userName];
    self.databaseFormattedHashtag = [NSString stringWithFormat:@"#%@", hashtagTag];
    
    self.userTag = [[VTag alloc] initWithAttributedDisplayString:[[NSMutableAttributedString alloc] initWithString:userName attributes:self.tagStringAttributes] databaseFormattedString:self.databaseFormattedUser andTagStringAttributes:self.tagStringAttributes];
    
    self.hashtagTag = [[VTag alloc] initWithAttributedDisplayString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@", hashtagTag] attributes:self.tagStringAttributes] databaseFormattedString:self.databaseFormattedHashtag andTagStringAttributes:self.tagStringAttributes];
    
    self.tags = @[self.userTag, self.hashtagTag];
    
    self.databaseFormattedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"test user : %@, test hashtag : %@", self.databaseFormattedUser, self.databaseFormattedHashtag] attributes:self.defaultStringAttributes];
    
    char cString[] = "\u200B";
    NSData *data = [NSData dataWithBytes:cString length:strlen(cString)];
    self.delimiterString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    self.displayFormattedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"test user : %@", self.delimiterString] attributes:self.defaultStringAttributes];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:userName attributes:self.tagStringAttributes]];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, test hashtag : %@", self.delimiterString, self.delimiterString] attributes:self.defaultStringAttributes]];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@", hashtagTag] attributes:self.tagStringAttributes]];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.delimiterString attributes:self.defaultStringAttributes]];
    
    self.tagDictionary = [[VTagDictionary alloc] init];
    [self.tagDictionary incrementTag:self.userTag];
    [self.tagDictionary incrementTag:self.hashtagTag];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTagDictionaryFromFormattingAttributedStringWithTagStringAttributesAndDefaultStringAttributes
{
    XCTAssertThrows([VTagStringFormatter tagDictionaryFromFormattingAttributedString:nil withTagStringAttributes:self.tagStringAttributes andDefaultStringAttributes:self.defaultStringAttributes], @"tag formatter should throw exception when no attributed string is provided");
    XCTAssertThrows([VTagStringFormatter tagDictionaryFromFormattingAttributedString:self.databaseFormattedString withTagStringAttributes:nil andDefaultStringAttributes:self.defaultStringAttributes], @"tag formatter should throw exception when no tag string attributes are provided");
    XCTAssertThrows([VTagStringFormatter tagDictionaryFromFormattingAttributedString:self.databaseFormattedString withTagStringAttributes:self.tagStringAttributes andDefaultStringAttributes:nil], @"tag formatter should throw exception when no default string attributes are provided");
    
    VTagDictionary *tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:self.databaseFormattedString
                                                                             withTagStringAttributes:self.tagStringAttributes andDefaultStringAttributes:self.defaultStringAttributes];
    XCTAssertEqual([tagDictionary count], (NSUInteger)2, @"returned tag dictionary should contain all tags contained as database-formatted strings in the provided attributed string");
    XCTAssertTrue([self.displayFormattedString isEqualToAttributedString:self.databaseFormattedString], @"formatted string should replace database-formatted tags with display-formatted tags");
    
    tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:self.displayFormattedString
                                                             withTagStringAttributes:self.tagStringAttributes
                                                          andDefaultStringAttributes:self.defaultStringAttributes];
    XCTAssertNotNil(tagDictionary, @"string formatter should return a tagDictionary even if no tags are found during string formatting");
}

- (void)testDatabaseFormattedStringFromAttributedStringWithTags
{
    XCTAssertThrows([VTagStringFormatter databaseFormattedStringFromAttributedString:nil withTags:self.tags], @"string formatting should throw exception if there is no string provided");
    XCTAssertTrue([[VTagStringFormatter databaseFormattedStringFromAttributedString:self.displayFormattedString withTags:nil] isEqualToString:self.displayFormattedString.string], @"string formatting should return passed in string if no tags are provided");
    
    NSString *returnedString = [VTagStringFormatter databaseFormattedStringFromAttributedString:self.displayFormattedString withTags:self.tags];
    XCTAssertTrue([self.databaseFormattedString.string isEqualToString:returnedString], @"database-formatted string should have all display-formatted strings replaced");
}

- (void)testDelimitedAttributedSTringWithDelimiterAttributes
{
    XCTAssertThrows([VTagStringFormatter delimitedAttributedString:nil withDelimiterAttributes:self.tagStringAttributes], @"delimiting formatting should throw exception if no attributed string is provided");
    XCTAssertThrows([VTagStringFormatter delimitedAttributedString:self.displayFormattedString withDelimiterAttributes:nil], @"delimiting formatting should throw exception if no delimiter attributes are provided");
    
    NSAttributedString *returnedString = [VTagStringFormatter delimitedAttributedString:self.databaseFormattedString withDelimiterAttributes:self.defaultStringAttributes];
    
    NSMutableAttributedString *expectedReturnString = [[NSMutableAttributedString alloc] initWithString:self.delimiterString attributes:self.defaultStringAttributes];
    [expectedReturnString appendAttributedString:self.databaseFormattedString];
    [expectedReturnString appendAttributedString:[[NSAttributedString alloc] initWithString:self.delimiterString attributes:self.defaultStringAttributes]];
    
    XCTAssertTrue([returnedString.string isEqualToString:expectedReturnString.string], @"delimiter formatting did not properly append delimiter strings to either side of provided attributed string");
    XCTAssertTrue([returnedString isEqualToAttributedString:expectedReturnString], @"delimiter formatting did not properly add formatting to delimited string");
}

- (void)testDatabaseFormattedStringFromUser
{
    XCTAssertNil([VTagStringFormatter databaseFormattedStringFromUser:nil], @"database formatted string for nil user should be nil");
    XCTAssertTrue([[VTagStringFormatter databaseFormattedStringFromUser:self.user] isEqualToString:self.databaseFormattedUser], @"database formatted string failed to properly format user");
}

- (void)testTagRangesInRangeOfAttributedStringWithTagDictionary
{
    XCTAssertNoThrow([VTagStringFormatter tagRangesInRange:NSMakeRange(1000, 1000) ofAttributedString:self.displayFormattedString withTagDictionary:self.tagDictionary], @"should not raise exception for range with location out of bounds of string");
    XCTAssertNoThrow([VTagStringFormatter tagRangesInRange:NSMakeRange(0, 1000) ofAttributedString:self.displayFormattedString withTagDictionary:self.tagDictionary], @"should not raise exception for range with length out of bounds of string");
    
    //Test by selecting range that just barely encompasses both tags in the attributed string
    NSString *username = self.userTag.displayString.string;
    NSRange usernameRange = [self.displayFormattedString.string rangeOfString:username];
    NSRange adjustedUsernameRange = usernameRange;
    adjustedUsernameRange.location += username.length - 1;
    
    NSRange hashtagRange = [self.displayFormattedString.string rangeOfString:self.hashtagTag.displayString.string];
    NSRange searchRange = NSMakeRange(adjustedUsernameRange.location, hashtagRange.location - adjustedUsernameRange.location + 1);
    
    XCTAssertThrows([VTagStringFormatter tagRangesInRange:searchRange ofAttributedString:nil withTagDictionary:self.tagDictionary], @"should throw exception for nil attributed string");
    XCTAssertNil([VTagStringFormatter tagRangesInRange:searchRange ofAttributedString:self.displayFormattedString withTagDictionary:nil], @"should return nil if no tags are provided for matching");
    XCTAssertNil([VTagStringFormatter tagRangesInRange:searchRange ofAttributedString:self.databaseFormattedString withTagDictionary:self.tagDictionary], @"should return nil if no tags are provided for matching");
    
    NSIndexSet *indexSet = [VTagStringFormatter tagRangesInRange:searchRange
                                              ofAttributedString:self.displayFormattedString
                                               withTagDictionary:self.tagDictionary];
    __block BOOL firstRange = YES;
    __block NSUInteger rangeCount = 0;
    [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop)
    {
        rangeCount++;
        if ( firstRange )
        {
            //1s on either side take delimiting string into account
            XCTAssertTrue(range.location == usernameRange.location - 1 && range.length == usernameRange.length + 2, @"first range in returned index set should represent range of first tag in attributed string");
            firstRange = NO;
        }
        else
        {
            //1s on either side take delimiting string into account
            XCTAssertTrue(range.location == hashtagRange.location - 1 && range.length == hashtagRange.length + 2, @"second range in returned index set should represent range of second tag in attributed string");
        }
        
    }];
    
    XCTAssertTrue(rangeCount == self.tagDictionary.count, @"number of returned tag ranges is incorrect");
}

- (void)testDefaultDependencyManagerTagColorKey
{
    XCTAssertNotNil([VTagStringFormatter defaultDependencyManagerTagColorKey], @"dependency manager tag color key should not be nil");
}

- (void)testDelimiterString
{
    XCTAssertNotNil([VTagStringFormatter delimiterString], @"dependency manager tag color key should not be nil");
}

- (void)testUserRegex
{
    XCTAssertNotNil([VTagStringFormatter userRegex], @"userRegex should not be nil");
}

- (void)testHashtagRegex
{
    XCTAssertNotNil([VTagStringFormatter hashtagRegex], @"hashtagRegex should not be nil");
}

@end
