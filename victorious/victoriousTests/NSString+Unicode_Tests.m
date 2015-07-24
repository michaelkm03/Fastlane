//
//  NSString+EmojiTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "victorious-Swift.h"

@interface NSString_Unicode_Tests : XCTestCase

@end

@implementation NSString_Unicode_Tests

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
    XCTAssertEqual( @"😄".lengthWithUnicode, 1 );
    XCTAssertEqual( @"😃".lengthWithUnicode, 1 );
    XCTAssertEqual( @"😍".lengthWithUnicode, 1 );
    XCTAssertEqual( @"😜".lengthWithUnicode, 1 );
    XCTAssertEqual( @"💏".lengthWithUnicode, 1 );
    XCTAssertEqual( @"👏".lengthWithUnicode, 1 );
    XCTAssertEqual( @"💆".lengthWithUnicode, 1 );
    XCTAssertEqual( @"👀".lengthWithUnicode, 1 );
    XCTAssertEqual( @"📱📪".lengthWithUnicode, 2 );
    XCTAssertEqual( @"👏😃".lengthWithUnicode, 2 );
    XCTAssertEqual( @"💆😜".lengthWithUnicode, 2 );
    XCTAssertEqual( @"👀👏".lengthWithUnicode, 2 );
    XCTAssertEqual( @"📱📛".lengthWithUnicode, 2 );
    XCTAssertEqual( @"📱📪🍤".lengthWithUnicode, 3 );
    XCTAssertEqual( @"👏😃🍦".lengthWithUnicode, 3 );
    XCTAssertEqual( @"💆😜🌽".lengthWithUnicode, 3 );
    XCTAssertEqual( @"👀👏🗿".lengthWithUnicode, 3 );
    XCTAssertEqual( @"📱📛🇩🇪".lengthWithUnicode, 3 );
}

@end
