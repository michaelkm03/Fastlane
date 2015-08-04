//
//  VInStreamMediaLinkTests.m
//  victorious
//
//  Created by Sharif Ahmed on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VInStreamMediaLink.h"
#import "VDependencyManager.h"

@interface VInStreamMediaLinkTests : XCTestCase

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) VCommentMediaType mediaType;
@property (nonatomic, strong) NSString *prompt;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInStreamMediaLinkTests

- (void)setUp
{
    [super setUp];
    self.tintColor = [UIColor redColor];
    self.font = [UIFont systemFontOfSize:13.0f];
    self.url = [NSURL URLWithString:@"url"];
    self.icon = [UIImage new];
    self.prompt = @"prompt";
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
}

- (void)testClassMethodInit
{
    XCTAssertNoThrow([VInStreamMediaLink newWithTintColor:self.tintColor font:self.font linkType:self.mediaType url:self.url andDependencyManager:self.dependencyManager]);
    XCTAssertNoThrow([VInStreamMediaLink newWithTintColor:nil font:self.font linkType:self.mediaType url:self.url andDependencyManager:self.dependencyManager]);
    XCTAssertNoThrow([VInStreamMediaLink newWithTintColor:self.tintColor font:nil linkType:self.mediaType url:self.url andDependencyManager:self.dependencyManager]);
    XCTAssertNoThrow([VInStreamMediaLink newWithTintColor:self.tintColor font:self.font linkType:VCommentMediaTypeUnknown url:self.url andDependencyManager:self.dependencyManager]);

    XCTAssertThrows([VInStreamMediaLink newWithTintColor:self.tintColor font:self.font linkType:self.mediaType url:nil andDependencyManager:self.dependencyManager]);
    XCTAssertThrows([VInStreamMediaLink newWithTintColor:self.tintColor font:self.font linkType:self.mediaType url:self.url  andDependencyManager:nil]);
}

- (void)testClassMethodInitFields
{
    VInStreamMediaLink *mediaLink = [VInStreamMediaLink newWithTintColor:self.tintColor
                                                                    font:self.font
                                                                linkType:self.mediaType
                                                                     url:self.url
                                                    andDependencyManager:self.dependencyManager];
    
    XCTAssertEqual(mediaLink.tintColor, self.tintColor);
    XCTAssertEqual(mediaLink.font, self.font);
    XCTAssertEqual(mediaLink.url, self.url);
    XCTAssertEqual(mediaLink.mediaLinkType, self.mediaType);
}

- (void)testInstanceInit
{
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:self.font text:self.prompt icon:self.icon linkType:self.mediaType url:self.url]);
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:nil font:self.font text:self.prompt icon:self.icon linkType:self.mediaType url:self.url]);
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:nil text:self.prompt icon:self.icon linkType:self.mediaType url:self.url]);
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:self.font text:nil icon:self.icon linkType:self.mediaType url:self.url]);
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:self.font text:self.prompt icon:nil linkType:self.mediaType url:self.url]);
    XCTAssertNoThrow([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:self.font text:self.prompt icon:self.icon linkType:VCommentMediaTypeUnknown url:self.url]);
    
    XCTAssertThrows([[VInStreamMediaLink alloc] initWithTintColor:self.tintColor font:self.font text:self.prompt icon:self.icon linkType:self.mediaType url:nil]);
}

- (void)testInstanceInitFields
{
    VInStreamMediaLink *mediaLink = [[VInStreamMediaLink alloc] initWithTintColor:self.tintColor
                                                                             font:self.font
                                                                             text:self.prompt
                                                                             icon:self.icon
                                                                         linkType:self.mediaType
                                                                              url:self.url];
    
    XCTAssertEqual(mediaLink.tintColor, self.tintColor);
    XCTAssertEqual(mediaLink.font, self.font);
    XCTAssertEqual(mediaLink.url, self.url);
    XCTAssertEqual(mediaLink.icon, self.icon);
    XCTAssertEqual(mediaLink.mediaLinkType, self.mediaType);
    XCTAssertEqual(mediaLink.text, self.prompt);
}

@end
