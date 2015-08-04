//
//  VCommentMediaLinkHelperTests.m
//  victorious
//
//  Created by Sharif Ahmed on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VCommentMediaTypeHelper.h"

@interface VCommentMediaTypeHelperTests : XCTestCase

@end

@implementation VCommentMediaTypeHelperTests

- (void)testMediaType
{
    XCTAssertNoThrow([VCommentMediaTypeHelper mediaTypeForUrl:nil andShouldAutoplay:NO]);
    
    XCTAssertEqual([VCommentMediaTypeHelper mediaTypeForUrl:[NSURL URLWithString:@"test.jpg"] andShouldAutoplay:NO], VCommentMediaTypeImage);
    XCTAssertEqual([VCommentMediaTypeHelper mediaTypeForUrl:[NSURL URLWithString:@"test.jpg"] andShouldAutoplay:YES], VCommentMediaTypeImage);
    XCTAssertEqual([VCommentMediaTypeHelper mediaTypeForUrl:[NSURL URLWithString:@"test.mp4"] andShouldAutoplay:NO], VCommentMediaTypeVideo);
    XCTAssertEqual([VCommentMediaTypeHelper mediaTypeForUrl:[NSURL URLWithString:@"test.mp4"] andShouldAutoplay:YES], VCommentMediaTypeGIF);
}

@end
