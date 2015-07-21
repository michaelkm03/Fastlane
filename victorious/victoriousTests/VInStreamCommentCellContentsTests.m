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
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDictionary *timestampTextAttributes;
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
    self.creationDate = [NSDate date];
    self.timestampTextAttributes = @{ @"timestampTextAttributes" : @"attribute" };
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
    XCTAssertNoThrow([[VInStreamCommentCellContents alloc] initWithUsername:self.username usernameFont:self.usernameFont commentText:self.commentText commentTextAttributes:self.commentTextAttributes highlightedTextAttributes:self.highlightedTextAttributes creationDate:self.creationDate timestampTextAttributes:self.timestampTextAttributes inStreamMediaLink:self.inStreamMediaLink profileImageUrlString:self.profileImageUrlString comment:self.comment1]);
}

@end
