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
#import "VTagStringFormatter.h"
#import "victorious-Swift.h"

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
    NSString *sampleTag = @"tag";
    self.databaseFormattedText = [NSString stringWithFormat:@"user is @{%@:%@}, hashtag is #%@", [user.remoteId stringValue], user.displayName, sampleTag];
    self.defaultAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:10.0], @"NSOriginalFont" : [UIFont systemFontOfSize:10.0] };
    self.tagAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont systemFontOfSize:10.0], @"NSOriginalFont" : [UIFont systemFontOfSize:10.0] };
    
    self.displayFormattedString = [[NSMutableAttributedString alloc] initWithString:@"user is " attributes:self.defaultAttributes];
    [self.displayFormattedString appendAttributedString:[VTagStringFormatter delimitedAttributedString:[[NSAttributedString alloc] initWithString:user.displayName attributes:self.tagAttributes] withDelimiterAttributes:self.defaultAttributes]];
    [self.displayFormattedString appendAttributedString:[[NSAttributedString alloc] initWithString:@", hashtag is " attributes:self.defaultAttributes]];
    [self.displayFormattedString appendAttributedString:[VTagStringFormatter delimitedAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"#%@", sampleTag] attributes:self.tagAttributes] withDelimiterAttributes:self.defaultAttributes]];
    
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
                                                                           toCallbackBlock:self.emptyCompletionBlock], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:andDefaultAttributes:toCallbackBlock: should raise assertion for nil tag attributes");
}

- (void)testFormatNilDefaultAttributes
{
    XCTAssertThrows([VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:self.databaseFormattedText
                                                                             tagAttributes:self.tagAttributes
                                                                      andDefaultAttributes:nil
                                                                           toCallbackBlock:self.emptyCompletionBlock], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:andDefaultAttributes:toCallbackBlock: should raise assertion for nil default attributes");
}

- (void)testFormatNilFormattedText
{
    XCTAssertNoThrow([VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:nil
                                                                              tagAttributes:self.tagAttributes
                                                                       andDefaultAttributes:self.defaultAttributes
                                                                            toCallbackBlock:self.emptyCompletionBlock], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:andDefaultAttributes:toCallbackBlock: should not raise assertion for nil database formatted text");
}

- (void)testFormatNilCallbackBlock
{
    XCTAssertThrows([VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:self.databaseFormattedText
                                                                            tagAttributes:self.tagAttributes
                                                                     andDefaultAttributes:self.defaultAttributes
                                                                          toCallbackBlock:nil], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:andDefaultAttributes:toCallbackBlock: should not raise assertion for nil callbackBlock");
}

- (void)testFormatAttributedStringSetting
{
    [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:self.databaseFormattedText
                                                             tagAttributes:self.tagAttributes
                                                      andDefaultAttributes:self.defaultAttributes
                                                           toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
     {
         XCTAssertTrue([displayFormattedString isEqualToAttributedString:self.displayFormattedString], @"displayFormattedStringFromDatabaseFormattedText:tagAttributes:andDefaultAttributes:toCallbackBlock: attributed string should provide display-formatted string in callback block");
     }];
}

//Just keeps warning from displaying
- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
}

@end
