//
//  VAbstractMediaLinkViewControllerTests.m
//  victorious
//
//  Created by Sharif Ahmed on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VAbstractMediaLinkViewController.h"

@interface VAbstractMediaLinkViewControllerTests : XCTestCase

@property (nonatomic, strong) NSURL *url;

@end

@implementation VAbstractMediaLinkViewControllerTests

- (void)setUp
{
    [super setUp];
    self.url = [NSURL URLWithString:@"url"];
}

- (void)testClassMethodInit
{
    XCTAssertThrows([VAbstractMediaLinkViewController newWithMediaUrl:nil andMediaLinkType:VCommentMediaTypeImage]);
    
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrl:self.url andMediaLinkType:VCommentMediaTypeImage]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrl:self.url andMediaLinkType:VCommentMediaTypeGIF]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrl:self.url andMediaLinkType:VCommentMediaTypeVideo]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrl:self.url andMediaLinkType:VCommentMediaTypeUnknown]);
}

@end
