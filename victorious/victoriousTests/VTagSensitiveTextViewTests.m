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
    
}

- (void)tearDown
{
    self.tagSensitiveTextView = nil;
    [super tearDown];
}

- (void)testNilTagAttributes
{
    XCTAssertThrows([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:nil
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:self], @"should raise assertion for nil tag attributes");
}

- (void)testNilDefaultAttributes
{
    XCTAssertThrows([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:nil
                                                            andTagTapDelegate:self], @"should raise assertion for nil default attributes");
}

- (void)testNilFormattedText
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:nil
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:self], @"should not raise assertion for nil database formatted text");
}

- (void)testNilDelegate
{
    XCTAssertNoThrow([self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                                tagAttributes:self.tagAttributes
                                                            defaultAttributes:self.defaultAttributes
                                                            andTagTapDelegate:nil], @"should not raise assertion for nil delegate");
}

- (void)testAttributedStringSetting
{
    [self.tagSensitiveTextView setupWithDatabaseFormattedText:self.databaseFormattedText
                                                tagAttributes:self.tagAttributes
                                            defaultAttributes:self.defaultAttributes
                                            andTagTapDelegate:self];
    NSLog(@"textview text is %@, displayFormattedString is %@", self.tagSensitiveTextView.attributedText, self.displayFormattedString);
    XCTAssertTrue([self.tagSensitiveTextView.attributedText isEqualToAttributedString:self.displayFormattedString], @"attributed string should be display-formatted in textView");
}

//Just keeps warning from displaying
- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
}

@end
