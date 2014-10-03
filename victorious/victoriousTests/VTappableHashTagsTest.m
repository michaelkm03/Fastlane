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

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation MockHashTagsDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.layoutManager = [[NSLayoutManager alloc] init];
        self.textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake( 320, 320 )];
        self.textContainer.widthTracksTextView = YES;
        self.textContainer.heightTracksTextView = YES;
        [self.layoutManager addTextContainer:self.textContainer];
        self.textStorage = [[NSTextStorage alloc] init];
        [self.textStorage addLayoutManager:self.layoutManager];
    }
    return self;
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

- (void)runInvalidDelegateTests
{
    XCTAssertFalse( _tappableHashTags.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
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

- (void)testDelegateInvalidNoTextStorage
{
    _delegate.textStorage = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManager
{
    _delegate.layoutManager = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainer
{
    _delegate.textContainer = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainerInLayoutMabager
{
    [[_delegate layoutManager] removeTextContainerAtIndex:0];
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManagerInTextStorage
{
    [[_delegate textStorage] removeLayoutManager:_delegate.layoutManager];
    [self runInvalidDelegateTests];
}

- (void)testDelegateValid
{
    XCTAssertFalse( _tappableHashTags.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
    NSError *error = nil;
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNil( error );
    
    error = nil;
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNil( error );
    
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
}

@end
