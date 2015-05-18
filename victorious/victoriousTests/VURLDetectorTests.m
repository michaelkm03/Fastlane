//
//  VURLDetectorTests.m
//  victorious
//
//  Created by Patrick Lynch on 5/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VURLDetector.h"

@interface VURLDetectorTests : XCTestCase

@property (nonatomic, strong) VURLDetector *urlDetector;

@end

@implementation VURLDetectorTests

- (void)setUp
{
    [super setUp];
    
    self.urlDetector = [[VURLDetector alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDetectFromString
{
    NSString *url1 = @"http://www.google.com";
    NSString *url2 = @"https://www.test.net";
    NSString *url3 = @"www.apple.com";
    
    NSString *fullText1 = url1;
    NSString *fullText2 = [NSString stringWithFormat:@"Some text with %@ as the URL #hashtag.", url2];
    NSString *fullText3 = [NSString stringWithFormat:@"%@ %@ %@", url1, url2, url3];
    
    NSArray *urls = [self.urlDetector detectFromString:fullText1];
    NSRange expected = [fullText1 rangeOfString:url1];
    NSRange output = ((NSValue *)urls.firstObject).rangeValue;
    XCTAssert( NSEqualRanges( expected, output ) );
    XCTAssertEqual( urls.count, 1u );
    
    urls = [self.urlDetector detectFromString:fullText2];
    expected = [fullText2 rangeOfString:url2];
    output = ((NSValue *)urls.firstObject).rangeValue;
    XCTAssert( NSEqualRanges( expected, output ) );
    XCTAssertEqual( urls.count, 1u );
    
    urls = [self.urlDetector detectFromString:fullText3];
    for ( NSInteger i = 0; i < 3; i++ )
    {
        NSString *url = @[ url1, url2, url3 ][ i ];
        expected = [fullText3 rangeOfString:url];
        output = ((NSValue *)urls[i]).rangeValue;
        XCTAssert( NSEqualRanges( expected, output ) );
    }
    XCTAssertEqual( urls.count, 3u );
}

@end
