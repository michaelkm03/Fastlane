//
//  NSString+EmojiTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "victoriousTests-Swift.h"

@interface NSString_EmojiTests : XCTestCase

@end

@implementation NSString_EmojiTests

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
