//
//  VTappableHashTagsTest.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "VTappableHashTags.h"

@interface MockHashTagsDelegate : NSObject <VTappableHashTagsDelegate>

@end

@implementation MockHashTagsDelegate

- (NSTextStorage *)textStorage
{
    return nil;
}
- (NSLayoutManager *)layoutManager
{
    return nil;
}
- (NSTextContainer *)textContainer
{
    return nil;
}

@end

@interface VTappableHashTagsTest : XCTestCase
{
    VTappableHashTags *_tappableHashTags;
    MockHashTagsDelegate *_delegate;
}

@end

@implementation VTappableHashTagsTest

- (void)setUp
{
    [super setUp];
    
    _tappableHashTags = [[VTappableHashTags alloc] init];
    _delegate = [[MockHashTagsDelegate alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDelegate
{
    XCTAssertFalse( _tappableHashTags.hasValidDelegate );
    
    NSError *error = nil;
    XCTAssertFalse( [_tappableHashTags setDelegate:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    
    error = nil;
    XCTAssertFalse( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    
    XCTAssertFalse( [_tappableHashTags setDelegate:_delegate error:nil] );
}

@end
