//
//  VSequencePermissionstests.m
//  victorious
//
//  Created by Patrick Lynch on 6/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VSequencePermissions.h"

@interface VSequencePermissionstests : XCTestCase

@end

@implementation VSequencePermissionstests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    VSequencePermissions *permissions;
    NSInteger value = 1;
    
    value <<= 0;
    permissions = [[VSequencePermissions alloc] initWithNumber:@(value)];
    
    XCTAssert( permissions.canDelete );
    XCTAssertFalse( permissions.canRemix );
    XCTAssertFalse( permissions.canComment );
    XCTAssertFalse( permissions.canShowVoteCount );
    XCTAssertFalse( permissions.canRepost );
    XCTAssertFalse( permissions.canMeme );
    XCTAssertFalse( permissions.canGIF );
    XCTAssertFalse( permissions.canQuote );
    
    value <<= 1;
    permissions = [[VSequencePermissions alloc] initWithNumber:@(value)];
    
    XCTAssert( permissions.canDelete );
    XCTAssert( permissions.canRemix );
    XCTAssertFalse( permissions.canComment );
    XCTAssertFalse( permissions.canShowVoteCount );
    XCTAssertFalse( permissions.canRepost );
    XCTAssertFalse( permissions.canMeme );
    XCTAssertFalse( permissions.canGIF );
    XCTAssertFalse( permissions.canQuote );
}

@end
