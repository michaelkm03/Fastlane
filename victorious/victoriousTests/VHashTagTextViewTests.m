//
//  VHashTagTextViewTests.m
//  victorious
//
//  Created by Michael Sena on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VAsyncTestHelper.h"

#import "VHashTagTextView.h"

@interface VHashTagTextViewTests : XCTestCase

@property (nonatomic, strong) VHashTagTextView *textView;

@end

@implementation VHashTagTextViewTests

- (void)setUp
{
    [super setUp];
    self.textView = [[VHashTagTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFindsTags
{
    NSString *simpleHashTagString = @"#hashTag";
    NSMutableAttributedString *attributedSimpleString = [[NSMutableAttributedString alloc] initWithString:simpleHashTagString];
    
    self.textView.attributedText = attributedSimpleString;

    __block BOOL appliedLinkAttribute = NO;
    
    
    [self.textView.attributedText enumerateAttributesInRange:NSMakeRange(0, simpleHashTagString.length)
                                                     options:kNilOptions
                                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         NSArray *allKeys = [attrs allKeys];
         NSLog(@"%@", allKeys);
         [allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
         {
             if ([key isEqualToString:CCHLinkAttributeName])
             {
                 appliedLinkAttribute = YES;
             }
         }];
     }];
    XCTAssert(appliedLinkAttribute);
}

@end
