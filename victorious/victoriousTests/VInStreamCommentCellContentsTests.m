//
//  VInStreamCommentCellContentsTests.m
//  victorious
//
//  Created by Sharif Ahmed on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VInStreamCommentCellContents.h"
#import "VInStreamMediaLink.h"
#import "VComment.h"
#import "VDependencyManager.h"
#import "VDummyModels.h"
#import "OCMock.h"

@interface VInStreamCommentCellContentsTests : XCTestCase

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIFont *usernameFont;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSDictionary *commentTextAttributes;
@property (nonatomic, strong) NSDictionary *highlightedTextAttributes;
@property (nonatomic, strong) VInStreamMediaLink *inStreamMediaLink;
@property (nonatomic, strong) NSString *profileImageUrlString;
@property (nonatomic, strong) VComment *comment1;
@property (nonatomic, strong) VComment *comment2;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInStreamCommentCellContentsTests

- (void)setUp
{
    [super setUp];
    self.username = @"username";
    self.usernameFont = [UIFont systemFontOfSize:13.0f];
    self.commentText = @"comment";
    self.commentTextAttributes = @{ @"commentTextAttribute" : @"attribute" };
    self.highlightedTextAttributes = @{ @"highlightedTextAttributes" : @"attribute" };
    self.inStreamMediaLink = [OCMockObject mockForClass:[VInStreamMediaLink class]];
    self.profileImageUrlString = @"profileImage";
    self.comment1 = [VDummyModels objectWithEntityName:@"Comment" subclass:[VComment class]];
    self.comment1.remoteId = @1;
    self.comment2 = [VDummyModels objectWithEntityName:@"Comment" subclass:[VComment class]];
    self.comment2.remoteId = @2;
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
}

- (void)testClassMethodInit
{
    NSArray *comments = @[ self.comment1, self.comment2 ];
    XCTAssertNoThrow([VInStreamCommentCellContents inStreamCommentsForComments:comments andDependencyManager:self.dependencyManager]);
    
    XCTAssertThrows([VInStreamCommentCellContents inStreamCommentsForComments:nil andDependencyManager:self.dependencyManager]);
    XCTAssertThrows([VInStreamCommentCellContents inStreamCommentsForComments:comments andDependencyManager:nil]);
}

- (void)testClassMethodInitFields
{
    NSArray *comments = @[ self.comment1, self.comment2 ];
    NSArray *contents = [VInStreamCommentCellContents inStreamCommentsForComments:comments andDependencyManager:self.dependencyManager];
    for (NSUInteger i = 0; i < comments.count; i++)
    {
        [((VInStreamCommentCellContents *)contents[i]).comment isEqual:comments[i]];
    }
}

- (void)testInstanceMethodInit
{
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:nil usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:nil commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:nil commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:nil highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:nil inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:nil profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:nil comment:self.comment1]);
    
    XCTAssertThrows([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:nil]);
}

- (void)testInstanceMethodInitFields
{
    VInStreamCommentCellContents *contents = [[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1];
    
    XCTAssertEqual(contents.username, self.username);
    XCTAssertEqual(contents.usernameFont, self.usernameFont);
    XCTAssertEqual(contents.commentText, self.commentText);
    XCTAssertEqual(contents.commentTextAttributes, self.commentTextAttributes);
    XCTAssertEqual(contents.highlightedTextAttributes, self.highlightedTextAttributes);
    XCTAssertEqual(contents.inStreamMediaLink, self.inStreamMediaLink);
    XCTAssertEqual(contents.profileImageUrlString, self.profileImageUrlString);
    XCTAssertEqual(contents.comment, self.comment1);
}

@end
