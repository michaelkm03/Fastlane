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

@property (nonatomic, strong) NSString *urlString;

@end

@implementation VAbstractMediaLinkViewControllerTests

- (void)setUp
{
    [super setUp];
    self.urlString = @"";
}

- (void)testClassMethodInit
{
    XCTAssertThrows([VAbstractMediaLinkViewController newWithMediaUrlString:nil andMediaLinkType:VCommentMediaTypeImage]);
    
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrlString:self.urlString andMediaLinkType:VCommentMediaTypeImage]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrlString:self.urlString andMediaLinkType:VCommentMediaTypeGIF]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrlString:self.urlString andMediaLinkType:VCommentMediaTypeVideo]);
    XCTAssertNotNil([VAbstractMediaLinkViewController newWithMediaUrlString:self.urlString andMediaLinkType:VCommentMediaTypeUnknown]);
}

@end
