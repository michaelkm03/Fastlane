//
//  VTagSensitiveTextViewTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTagSensitiveTextView.h"
#import "VDummyModels.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VTagStringFormatter.h"

@interface VTagSensitiveTextViewTests : XCTestCase <VTagSensitiveTextViewDelegate>

@property (nonatomic, strong) VTagSensitiveTextView *tagSensitiveTextView;
@property (nonatomic, strong) NSString *databaseFormattedText;
@property (nonatomic, strong) NSMutableAttributedString *displayFormattedString;
@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, strong) NSDictionary *tagAttributes;
@property (nonatomic, copy) void (^emptyCompletionBlock)(VTagDictionary *, NSAttributedString *);

@end

@implementation VTagSensitiveTextViewTests

- (void)setUp
{
    [super setUp];
    self.tagSensitiveTextView = [[VTagSensitiveTextView alloc] init];
    VUser *user = [[VDummyModels createUsers:1] lastObject];
    VHashtag *hashtag = [[VDummyModels createHashtags:1] lastObject];
    self.databaseFormattedText = [NSString stringWithFormat:@"user is @{%@:%@}, hashtag is #%@", [user.remoteId stringValue], user.name, hashtag.tag];
    self.defaultAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:10.0], @"NSOriginalFont" : [UIFont systemFontOfSize:10.0] };
    self.tagAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont systemFontOfSize:10.0], @"NSOriginalFont" : [UIFont systemFontOfSize:10.0] };
    
    self.displayFormattedString = [[NSMutableAttributedString alloc] initWithString:@"user is " attributes:self.defaultAttributes];
    [self.displayFormattedString appendAttributedString:[VTagStringFormatter delimitedAttributedString:[[NSAttributedString alloc] initWithString:user.name attributes:self.tagAttributes] withDelimiterAttributes:self.defaultAttributes]];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:@", hashtag is " attributes:self.defaultAttributes]];
    [self.displayFormattedString appendAttributedString:[VTagStringFormatter delimitedAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@", hashtag.tag] attributes:self.tagAttributes] withDelimiterAttributes:self.defaultAttributes]];
    
    //An empty completion block to pass into the displayFormattedStringFromDatabaseFormattedText:tagAttributes:defaultAttributes:toCallbackBlock: tests
    self.emptyCompletionBlock = ^(VTagDictionary *d, NSAttributedString *a)
    {
    };
}

- (void)tearDown
{
    self.tagSensitiveTextView = nil;
    [super tearDown];
}

#pragma mark - setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: tests

- (void)testSetupNilTagAttributes
{
    XCTAssertThrows([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:nil
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:self], @"setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: should raise assertion for nil tag attributes");
}

- (void)testSetupNilDefaultAttributes
{
    XCTAssertThrows([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:nil
                                                            andTagTapDelegate:self], @"setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: should raise assertion for nil default attributes");
}

- (void)testSetupNilFormattedText
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:nil
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:self], @"setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: should not raise assertion for nil database formatted text");
}

- (void)testSetupNilDelegate
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:nil], @"setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: should not raise assertion for nil delegate");
}

- (void)testSetupAttributedStringSetting
{
    [self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                tagAttributes:self.tagAttributes
                                            defaultAttributes:self.defaultAttributes
                                            andTagTapDelegate:self];
    XCTAssertTrue([self.tagSensitiveTextView.attributedText isEqualToAttributedString:self.displayFormattedString], @"after setupWithDatabaseFormattedText:tagAttributes:defaultAttributes:andTagTapDelegate: attributed string should be display-formatted in textView");
}

#pragma mark - displayFormattedStringFromDatabaseFormattedText:tagAttributes:defaultAttributes:toCallbackBlock: tests

- (void)testFormatNilTagAttributes
{
    XCTAssertThrows([VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:self.databaseFormattedText
                                                                             tagAttributes:nil
                                                                      andDefaultAttributes:self.defaultAttributes
                                                                           toCallbackBlock:self.emptyCompletionBlock], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:defaultAttributes:toCallbackBlock: should raise assertion for nil tag attributes");
}

- (void)testFormatNilDefaultAttributes
{
    XCTAssertThrows([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:nil
                                                            andTagTapDelegate:self], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:defaultAttributes:toCallbackBlock: should raise assertion for nil default attributes");
}

- (void)testFormatNilFormattedText
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:nil
                                                                 tagAttributes:self.tagAttributes
                                                             defaultAttributes:self.defaultAttributes
                                                             andTagTapDelegate:self], @"should not raise assertion for nil database formatted text");
}

- (void)testFormatNilDelegate
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                 tagAttributes:self.tagAttributes
                                                             defaultAttributes:self.defaultAttributes
                                                             andTagTapDelegate:nil], @"should not raise assertion for nil delegate");
}

- (void)testFormatAttributedStringSetting
{
    [self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                tagAttributes:self.tagAttributes
                                            defaultAttributes:self.defaultAttributes
                                            andTagTapDelegate:self];
    XCTAssertTrue([self.tagSensitiveTextView.attributedText isEqualToAttributedString:self.displayFormattedString], @"attributed string should be display-formatted in textView");
}

//Just keeps warning from displaying
- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
}

@end
